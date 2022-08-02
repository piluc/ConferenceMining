package icalp50.datacollection;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

public class TemporalGraphSorter {
	class TemporalEdge {
		int u;
		int v;
		int t;
		int w;

		public TemporalEdge(int u, int v, int t, int w) {
			this.u = u;
			this.v = v;
			this.t = t;
			this.w = w;
		}
	}

	class YearCompare implements Comparator<TemporalEdge> {
		public int compare(TemporalEdge te1, TemporalEdge te2) {
			if (te1.t < te2.t)
				return -1;
			if (te1.t > te2.t)
				return 1;
			return 0;
		}
	}

	/**
	 * Save in the output temporal graph file the temporal edges of the input
	 * temporal graph file sorted in non-decreasing order with respect to the year.
	 * 
	 * @param fni : file containing the temporal graph
	 * @param fno : file on which the sorted temporal graph is saved
	 */
	public void sort(String fni, String fno) {
		try {
			ArrayList<TemporalEdge> temporal_edges = new ArrayList<>();
			BufferedReader tg_br = new BufferedReader(new FileReader(fni));
			String line = tg_br.readLine();
			while (line != null && line.length() > 0) {
				String[] split_line = line.split(",");
				int u = Integer.parseInt(split_line[0]);
				int v = Integer.parseInt(split_line[1]);
				int t = Integer.parseInt(split_line[2]);
				int w = Integer.parseInt(split_line[3]);
				TemporalEdge te = new TemporalEdge(u, v, t, w);
				temporal_edges.add(te);
				line = tg_br.readLine();
			}
			tg_br.close();
			Collections.sort(temporal_edges, new YearCompare());
			BufferedWriter tg_bw = new BufferedWriter(new FileWriter(fno));
			for (int i = 0; i < temporal_edges.size(); i++) {
				TemporalEdge te = temporal_edges.get(i);
				tg_bw.write(te.u + "," + te.v + "," + te.t + "," + te.w + "\n");
			}
			tg_bw.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Invoke the sorting method on the two temporal graph files with all papers and
	 * only with conference papers, respectively.
	 * 
	 * @param conf : conference acronym
	 */
	public void sort(String conf) {
		sort("./conferences/" + conf + "/temporal_graph.txt", "./conferences/" + conf + "/temporal_graph_sorted.txt");
		sort("./conferences/" + conf + "/temporal_graph_conf.txt",
				"./conferences/" + conf + "/temporal_graph_conf_sorted.txt");
	}

	/**
	 * Invoke the sorting method.
	 * 
	 * @param conf : conference acronym
	 */
	public static void main(String conf) {
		(new TemporalGraphSorter()).sort(conf);
	}

}
