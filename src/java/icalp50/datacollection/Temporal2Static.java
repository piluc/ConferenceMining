package icalp50.datacollection;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Temporal2Static {
	/**
	 * Save in the static graph file the list of edges corresponding to the input
	 * temporal graph file (each edge specifies the two author id and the number of
	 * collaborations between the first and the last year).
	 * 
	 * @param fni        : file containing the temporal graph
	 * @param fno        : file on which the static graph is saved
	 * @param n          : number of authors
	 * @param first_year : first year to be considered
	 * @param last_year  : last year to be considered
	 */
	public static void temporal_to_static(String fni, String fno, int n, int first_year, int last_year) {
		try {
			int[][] weights = new int[n][n];
			for (int u = 0; u < n; u++) {
				for (int v = 0; v < n; v++) {
					weights[u][v] = 0;
				}
			}
			BufferedReader tg_br = new BufferedReader(new FileReader(fni));
			String line = tg_br.readLine();
			while (line != null && line.length() > 0) {
				String[] split_line = line.split(",");
				int t = Integer.parseInt(split_line[2]);
				if (t >= first_year && t <= last_year) {
					int u = Integer.parseInt(split_line[0]);
					int v = Integer.parseInt(split_line[1]);
					int w = Integer.parseInt(split_line[3]);
					if (u < v) {
						weights[u - 1][v - 1] = weights[u - 1][v - 1] + w;
					} else if (v < u) {
						weights[v - 1][u - 1] = weights[v - 1][u - 1] + w;
					}
				}
				line = tg_br.readLine();
			}
			tg_br.close();
			BufferedWriter sg_bw = new BufferedWriter(new FileWriter(fno));
			for (int u = 0; u < n; u++) {
				for (int v = u + 1; v < n; v++) {
					if (weights[u][v] > 0) {
						sg_bw.write((u + 1) + "," + (v + 1) + "," + weights[u][v] + "\n");
					}
				}
			}
			sg_bw.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Invoke the method for creating the two static graph files with all papers and
	 * only with conference papers, respectively.
	 * 
	 * @param conf      : conference acronym
	 * @param num_nodes : number of authors
	 * @param fy        : first year to be considered
	 * @param ly        : last year to be considered
	 */
	public static void temporal_to_static(String conf, int num_nodes, int fy, int ly) {
		temporal_to_static("./conferences/" + conf + "/temporal_graph_sorted.txt",
				"./conferences/" + conf + "/static_graph.txt", num_nodes, fy, ly);
		temporal_to_static("./conferences/" + conf + "/temporal_graph_conf_sorted.txt",
				"./conferences/" + conf + "/static_graph_conf.txt", num_nodes, fy, ly);
	}

	/**
	 * Compute number of authors and invoke method to create static graph.
	 * 
	 * @param conf : conference acronym
	 * @param fy   : first year to be considered
	 * @param ly   : last year to be considered
	 */
	public static void main(String conf, int fy, int ly) {
		Path path = Paths.get("./conferences/" + conf + "/id_name_key.txt");
		long num_nodes = 0;
		try {
			num_nodes = Files.lines(path).count();
		} catch (IOException e) {
			e.printStackTrace();
		}
		temporal_to_static(conf, (int) num_nodes, fy, ly);
	}
}
