package icalp50.datacollection;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;

public class TemporalGraphCreator {
	/**
	 * Save in the temporal graph file the list of temporal edges (each temporal edge
	 * specifies the two author id, the year, and the number of collaboration in
	 * that year.
	 * 
	 * @param num_nodes : number of conference authors
	 * @param fni       : file containing the temporal adjacency matrix
	 * @param fno       : file on which the temporal graph is saved
	 */
	public static void create_temporal_graph(long num_nodes, String fni, String fno) {
		try {
			BufferedWriter tg_bw = new BufferedWriter(new FileWriter(fno));
			BufferedReader tam_br = new BufferedReader(new FileReader(fni));
			String line = tam_br.readLine();
			while (line != null && line.length() > 0) {
				String[] split_line = line.split(":");
				String uv = split_line[0].substring(1, split_line[0].length() - 1);
				String[] split_uv = uv.split(",");
				int u = Integer.parseInt(split_uv[0].trim());
				int v = Integer.parseInt(split_uv[1].trim());
				String years = split_line[1].substring(2, split_line[1].length() - 1);
				String[] split_years = years.split(",");
				int[] year = new int[split_years.length];
				for (int i = 0; i < year.length; i++) {
					year[i] = Integer.parseInt(split_years[i].trim());
				}
				Arrays.sort(year);
				int current_year = year[0];
				int current_weight = 1;
				int current_i = 1;
				while (current_i < year.length) {
					if (year[current_i] == current_year) {
						current_weight = current_weight + 1;
					} else {
						tg_bw.write(u + "," + v + "," + current_year + "," + current_weight + "\n");
						current_year = year[current_i];
						current_weight = 1;
					}
					current_i = current_i + 1;
				}
				tg_bw.write(u + "," + v + "," + current_year + "," + current_weight + "\n");
				line = tam_br.readLine();
			}
			tg_bw.close();
			tam_br.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Invoke the method for creating the two temporal graph files with all papers
	 * and only with conference papers, respectively.
	 * 
	 * @param conf      : conference acronym
	 * @param num_nodes : number of distinct conference authors
	 */
	public static void create_temporal_graphs(String conf, long num_nodes) {
		create_temporal_graph(num_nodes, "./conferences/" + conf + "/temporal_adjacency_matrix.txt",
				"./conferences/" + conf + "/temporal_graph.txt");
		create_temporal_graph(num_nodes, "./conferences/" + conf + "/temporal_adjacency_matrix_conf.txt",
				"./conferences/" + conf + "/temporal_graph_conf.txt");
	}

	/**
	 * Compute the number of conference authors and invoke the method for creating
	 * temporal graph files.
	 * 
	 * @param conf : conference acronym
	 */
	public static void main(String conf) {
		Path path = Paths.get("./conferences/" + conf + "/id_name_key.txt");
		long num_nodes = 0;
		try {
			num_nodes = Files.lines(path).count();
		} catch (IOException e) {
			e.printStackTrace();
		}
		if (num_nodes > 0) {
			create_temporal_graphs(conf, num_nodes);
		}
	}
}
