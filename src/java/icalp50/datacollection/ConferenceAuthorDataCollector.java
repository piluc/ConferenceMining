package icalp50.datacollection;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.Map;
import java.util.TreeMap;

import org.dblp.mmdb.Field;
import org.dblp.mmdb.Person;
import org.dblp.mmdb.PersonName;
import org.dblp.mmdb.Publication;
import org.dblp.mmdb.RecordDbInterface;
import org.dblp.mmdb.TableOfContents;

public class ConferenceAuthorDataCollector {
	static Comparator<Person> cmp = (Person o1, Person o2) -> o1.getPrimaryName().name()
			.compareTo(o2.getPrimaryName().name());

	/**
	 * Add titles of specific conference edition to paper titles file (it ignores
	 * prefaces when possible).
	 * 
	 * @param conf          : conference acronym
	 * @param toc           : table of contents of the conference edition
	 * @param year          : year of the conference dition
	 * @param year_paper_pw : writer of the file with all conference paper titles
	 */
	public static void save_titles(String conf, TableOfContents toc, PrintWriter year_paper_pw) {
		try {
			for (Publication publ : toc.getPublications()) {
				if (!publ.getTag().equals("proceedings")) {
					String title = "";
					// The Publication class does not include a getTitle method
					for (Field f : publ.getFields("title")) {
						title = title.concat(f.value());
					}
					year_paper_pw.format("%s\n", title);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(-1);
		}
	}

	/**
	 * For each paper in the conference edition (prefaces are ignored when
	 * possible), collect the paper titles (only journal and conference papers and
	 * only titles with at most three commas) and the conferences of the authors of
	 * the paper (if not already done) and add them in the two corresponding files.
	 * 
	 * @param toc        : table of contents of the conference edition
	 * @param author_id  : dictionary associating author name to integer id
	 * @param id_key     : dictionary associating integer id to DBLP key
	 * @param current_id : next integer id to be assigned
	 * @param paper_pw   : writer of the file with all paper titles of each
	 *                   conference author
	 * @param conf_pw    : writer of the file with all conferences of each
	 *                   conference author
	 * @return : next integer id to be assigned
	 */
	public static int analyse_toc(TableOfContents toc, Map<String, Integer> author_id, Map<Integer, String> id_key,
			int current_id, PrintWriter paper_pw, PrintWriter conf_pw) {
		try {
			for (Publication publ : toc.getPublications()) {
				if (!publ.getTag().equals("proceedings")) {
					for (PersonName personName : publ.getNames()) {
						Person person = personName.getPerson();
						if (!author_id.containsKey(person.getPrimaryName().name())) {
							String name = person.getPrimaryName().name();
							String key = person.getKey();
							author_id.put(name, current_id);
							id_key.put(current_id, key);
							paper_pw.format("i##%d##n##%s##k##%s\n", current_id, name, key);
							conf_pw.format("i##%d##n##%s##k##%s\n", current_id, name, key);
							for (Publication pub : person.getPublications()) {
								String publ_type = pub.getAttributes().get("publtype");
								if (publ_type == null || !publ_type.equals("informal")
										|| !publ_type.equals("withdrawn")) {
									String publ_tag = pub.getTag();
									if (publ_tag.equals("article") || publ_tag.equals("inproceedings")) {
										String title = "";
										for (Field f : pub.getFields("title")) {
											title = title.concat(f.value());
										}
										long count = title.chars().filter(ch -> ch == ',').count();
										if (count <= 3) {
											paper_pw.format("y##%d##t##%s\n", pub.getYear(), title);
										}
										if (publ_tag.equals("inproceedings")) {
											conf_pw.format("y##%d##c##%s\n", pub.getYear(),
													pub.getBooktitle().getTitle());
										}
									}
								}
							}
							current_id = current_id + 1;
						}
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(-1);
		}
		return current_id;
	}

	/**
	 * Create the file with all paper titles of each conference author, the file
	 * with all conferences of each conference author, and the file with the mapping
	 * between integer id and DBLP key. The first argument is the conference
	 * acronym, while the other arguments are grouped into blocks of six values,
	 * that is, the type, the DBLP directory, the acronym, the first suffix, the
	 * last suffix, and the number of parts of each edition of the conference.
	 * 
	 * @param dblp : the Java interface to the DBLP database
	 * @param args : list of arguments for the specific conference
	 */
	public static void main(RecordDbInterface dblp, String[] args) {
		int num_arguments_conf = 6;
		Map<String, Integer> author_id = new TreeMap<>();
		Map<Integer, String> id_key = new TreeMap<>();
		int current_id = 1;
		int nc = args.length / num_arguments_conf;
		String conf = args[0];
		try {
			Path path = Paths.get("./conferences/" + conf + "/papers/");
			Files.createDirectories(path);
			PrintWriter paper_pw = new PrintWriter("./conferences/" + conf + "/author_paper_titles.txt");
			PrintWriter conf_pw = new PrintWriter("./conferences/" + conf + "/author_conferences.txt");
			for (int c = 0; c < nc; c++) {
				String conf_type = args[1 + num_arguments_conf * c];
				String conf_dir = args[2 + num_arguments_conf * c];
				String conf_syn = args[3 + num_arguments_conf * c];
				int first_suffix = Integer.parseInt(args[4 + num_arguments_conf * c]);
				int last_suffix = Integer.parseInt(args[5 + num_arguments_conf * c]);
				int num_parts = Integer.parseInt(args[6 + num_arguments_conf * c]);
				for (int suffix = first_suffix; suffix <= last_suffix; suffix++) {
					String suffixString = "" + suffix;
					if (suffix < 10) {
						suffixString = "0" + suffixString;
					}
					if (num_parts == 1) {
						TableOfContents toc = dblp
								.getToc("db/" + conf_type + "/" + conf_dir + "/" + conf_syn + suffixString + ".bht");
						if (toc != null) {
							int real_year = ((Publication) (toc.getPublications().toArray()[0])).getYear();
							PrintWriter year_paper_pw = new PrintWriter(
									"./conferences/" + conf + "/papers/paper_titles_" + real_year + ".txt");
							save_titles(conf, toc, year_paper_pw);
							current_id = analyse_toc(toc, author_id, id_key, current_id, paper_pw, conf_pw);
							year_paper_pw.close();
						}
					} else {
						TableOfContents toc = dblp
								.getToc("db/" + conf_type + "/" + conf_dir + "/" + conf_syn + suffixString + "-1.bht");
						if (toc != null) {
							int real_year = ((Publication) (toc.getPublications().toArray()[0])).getYear();
							PrintWriter year_paper_pw = new PrintWriter(
									"./conferences/" + conf + "/papers/paper_titles_" + real_year + ".txt");
							for (int p = 1; p <= num_parts; p++) {
								toc = dblp.getToc("db/" + conf_type + "/" + conf_dir + "/" + conf_syn + suffixString + "-" + p
										+ ".bht");
								if (toc != null) {
									save_titles(conf, toc, year_paper_pw);
									current_id = analyse_toc(toc, author_id, id_key, current_id, paper_pw, conf_pw);
								}
							}
							year_paper_pw.close();
						}
					}
				}
			}
			paper_pw.close();
			conf_pw.close();
			BufferedWriter ai_bw = new BufferedWriter(new FileWriter("./conferences/" + conf + "/id_name_key.txt"));
			for (String author_name : author_id.keySet()) {
				int id = author_id.get(author_name);
				ai_bw.write("i##" + id + "##n##" + author_name + "##k##" + id_key.get(id) + "\n");
			}
			ai_bw.close();
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(-1);
		}
	}
}
