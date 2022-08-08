package icalp50.datacollection;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.dblp.mmdb.Field;
import org.dblp.mmdb.Person;
import org.dblp.mmdb.PersonName;
import org.dblp.mmdb.Publication;
import org.dblp.mmdb.RecordDbInterface;

public class ConferenceTemporalAdjacencyMatrixCreator {
	static Comparator<Person> cmp = (Person o1, Person o2) -> o1.getPrimaryName().name()
			.compareTo(o2.getPrimaryName().name());

	/**
	 * Create the file with all papers of the conference and the two files with the
	 * adjacency lists of the temporal graph considering all collaborations and only
	 * conference collaborations, respectively. All DBLP publications are analyzed
	 * and only the ones corresponding to conference papers and not being exceptions
	 * are considered in order to add lines to the three files. Only the non-empty
	 * elements of the temporal adjacency lists are saved in the files.
	 * 
	 * @param dblp       : the Java interface to the DBLP database
	 * @param acronym    : conference acronym
	 * @param dir        : array of DBLP directories of the conference
	 * @param conf       : array of prefixes of DBLP URLs of the conference
	 * @param fy         : array of first years
	 * @param ly         : array of last years
	 * @param exceptions : array of exceptions
	 */
	public static void create_temporal_adjacency_matrices(RecordDbInterface dblp, String acronym, String[] dir,
			String[] conf, int[] fy, int[] ly, String[] exceptions) {
		Map<String, Integer> key_id = new TreeMap<>();
		Map<Integer, String> id_key = new TreeMap<>();
		try {
			BufferedReader id_key_br = new BufferedReader(
					new FileReader("./conferences/" + acronym + "/id_name_key.txt"));
			String line = id_key_br.readLine();
			while (line != null && line.length() > 0) {
				String[] split_line = line.split("##");
				key_id.put(split_line[5], Integer.parseInt(split_line[1]));
				id_key.put(Integer.parseInt(split_line[1]), split_line[5]);
				line = id_key_br.readLine();
			}
			id_key_br.close();
			int n_authors = id_key.size();
			@SuppressWarnings("unchecked")
			ArrayList<Integer>[][] temporal_adjacency_matrix = new ArrayList[n_authors][n_authors];
			@SuppressWarnings("unchecked")
			ArrayList<Integer>[][] temporal_adjacency_matrix_conf = new ArrayList[n_authors][n_authors];
			for (int a1 = 0; a1 < n_authors; a1++) {
				for (int a2 = a1; a2 < n_authors; a2++) {
					temporal_adjacency_matrix[a1][a2] = new ArrayList<Integer>();
					temporal_adjacency_matrix_conf[a1][a2] = new ArrayList<Integer>();
				}
			}
			Collection<Publication> all_pubs = dblp.getPublications();
			BufferedWriter pub_bw = new BufferedWriter(new FileWriter("./conferences/" + acronym + "/" + "papers.txt"));
			for (Publication pub : all_pubs) {
				String url = "";
				for (Field f : pub.getFields("url")) {
					url = url.concat(f.value());
				}
				String publ_type = pub.getAttributes().get("publtype");
				if (publ_type == null || (!publ_type.equals("informal") && !publ_type.equals("withdrawn"))
						|| url.toUpperCase().contains("eurocrypt/eurocrypt86".toUpperCase())) {
					if (pub.getTag().equals("article") || pub.getTag().equals("inproceedings")) {
						int year = pub.getYear();
						List<PersonName> person_names = pub.getNames();
						for (PersonName pn1 : person_names) {
							Person a1 = pn1.getPerson();
							String k1 = a1.getKey();
							if (key_id.containsKey(k1)) {
								int id1 = key_id.get(k1);
								for (PersonName pn2 : person_names) {
									Person a2 = pn2.getPerson();
									String k2 = a2.getKey();
									if ((!k1.equals(k2) && key_id.containsKey(k2))
											|| (k1.equals(k2) && person_names.size() == 1)) {
										int id2 = key_id.get(k2);
										if (id1 <= id2) {
											temporal_adjacency_matrix[id1 - 1][id2 - 1].add(year);
											for (int c = 0; c < conf.length; c++) {
												boolean containsException = false;
												for (int e = 0; e < exceptions.length; e++) {
													if (url.toUpperCase().contains(exceptions[e].toUpperCase())) {
														containsException = true;
													}
												}
												if (url.toUpperCase()
														.contains(dir[c].toUpperCase() + "/" + conf[c].toUpperCase())
														&& !url.toUpperCase()
																.contains(dir[c].toUpperCase() + "/"
																		+ (conf[c] + "w").toUpperCase())
														&& !url.toUpperCase()
																.contains(dir[c].toUpperCase() + "/"
																		+ (conf[c] + year + "w").toUpperCase())
														&& !containsException) {
													if (fy[c] <= year && ly[c] >= year) {
														temporal_adjacency_matrix_conf[id1 - 1][id2 - 1].add(year);
													}
												}
											}
										}
									}
								}
							}
						}
						if (person_names.size() > 0) {
							for (int c = 0; c < conf.length; c++) {
								boolean containsException = false;
								for (int e = 0; e < exceptions.length; e++) {
									if (url.toUpperCase().contains(exceptions[e].toUpperCase())) {
										containsException = true;
									}
								}
								if (url.toUpperCase().contains(dir[c].toUpperCase() + "/" + conf[c].toUpperCase())
										&& !url.toUpperCase()
												.contains(dir[c].toUpperCase() + "/" + (conf[c] + "w").toUpperCase())
										&& !url.toUpperCase().contains(
												dir[c].toUpperCase() + "/" + (conf[c] + year + "w").toUpperCase())
										&& !containsException) {
									if (fy[c] <= year && ly[c] >= year) {
										String publ_key = pub.getAttributes().get("key");
										ArrayList<Integer> author_ids = new ArrayList<>();
										for (PersonName pn : person_names) {
											Person a = pn.getPerson();
											String k = a.getKey();
											if (key_id.containsKey(k)) {
												int id = key_id.get(k);
												author_ids.add(id);
											}
										}
										pub_bw.write("y##" + year + "##k##" + publ_key + "##a##"
												+ Arrays.toString(author_ids.toArray()) + "\n");
									}
								}
							}
						}
					}
				}
			}
			pub_bw.close();
			BufferedWriter tam_bw = new BufferedWriter(
					new FileWriter("./conferences/" + acronym + "/temporal_adjacency_matrix.txt"));
			BufferedWriter tami_bw = new BufferedWriter(
					new FileWriter("./conferences/" + acronym + "/temporal_adjacency_matrix_conf.txt"));
			for (int a1 = 0; a1 < n_authors; a1++) {
				for (int a2 = a1; a2 < n_authors; a2++) {
					ArrayList<Integer> years = temporal_adjacency_matrix[a1][a2];
					if (years.size() > 0) {
						tam_bw.write("(" + (a1 + 1) + "," + (a2 + 1) + "): " + Arrays.toString(years.toArray()) + "\n");
					}
					years = temporal_adjacency_matrix_conf[a1][a2];
					if (years.size() > 0) {
						tami_bw.write(
								"(" + (a1 + 1) + "," + (a2 + 1) + "): " + Arrays.toString(years.toArray()) + "\n");
					}
				}
			}
			tam_bw.close();
			tami_bw.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * The first argument is the conference acronym, while the other arguments are
	 * grouped into blocks of five values, that is, the DBLP directory, the prefix
	 * of the DBLP file, the first year, and the last year of each edition of the
	 * conference. The last argument is the list of exceptions for the conference
	 * (that is, which strings should not appear in the DBLP URL). For all
	 * conferences, two exceptions are the DBLP directory followed by /, the prefix,
	 * and the letter w, and the DBLP directory followed by /, the prefix, the year,
	 * and the letter w.
	 * 
	 * @param dblp : the Java interface to the DBLP database
	 * @param args : list of arguments for the specific conference
	 */
	public static void main(RecordDbInterface dblp, String[] args) {
		String acronym = args[0];
		int num_arguments_conf = 4;
		int nc = (args.length - 2) / num_arguments_conf;
		String[] dir = new String[nc];
		String[] conf = new String[nc];
		int[] first_year = new int[nc];
		int[] last_year = new int[nc];
		for (int c = 0; c < nc; c++) {
			dir[c] = args[1 + num_arguments_conf * c];
			conf[c] = args[2 + num_arguments_conf * c];
			first_year[c] = Integer.parseInt(args[3 + num_arguments_conf * c]);
			last_year[c] = Integer.parseInt(args[4 + num_arguments_conf * c]);
		}
		String[] exceptions = {};
		if (!args[args.length - 1].equals("ne")) {
			exceptions = args[args.length - 1].split(",");
		}
		create_temporal_adjacency_matrices(dblp, acronym, dir, conf, first_year, last_year, exceptions);
	}
}
