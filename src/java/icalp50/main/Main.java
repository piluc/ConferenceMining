package icalp50.main;

import org.dblp.mmdb.RecordDbInterface;

import icalp50.datacollection.ConferenceAuthorDataCollector;
import icalp50.datacollection.ConferenceTemporalAdjacencyMatrixCreator;
import icalp50.datacollection.Temporal2Static;
import icalp50.datacollection.TemporalGraphCreator;
import icalp50.datacollection.TemporalGraphSorter;
import icalp50.utilities.Utilities;

public class Main {
	public static String[][] default_arguments_phirst_phase = {
			{ "cav", "conf", "cav", "cav", "1990", "1990", "1", "conf", "cav", "cav", "91", "91", "1", "conf", "cav",
					"cav", "1992", "1992", "1", "conf", "cav", "cav", "93", "99", "1", "conf", "cav", "cav", "2000",
					"2015", "1", "conf", "cav", "cav", "2015", "2015", "2", "conf", "cav", "cav", "2016", "2021", "2" },
			{ "concur", "conf", "concur", "concur", "1984", "1984", "1", "conf", "concur", "concur", "1988", "2021",
					"1" },
			{ "crypto", "conf", "crypto", "crypto", "81", "99", "1", "conf", "crypto", "crypto", "2000", "2012", "1",
					"conf", "crypto", "crypto", "2013", "2015", "2", "conf", "crypto", "crypto", "2016", "2020", "3",
					"conf", "crypto", "crypto", "2021", "2021", "4" },
			{ "csl", "conf", "csl", "csl", "87", "99", "1", "conf", "csl", "csl", "2000", "2018", "1", "conf", "csl",
					"csl", "2020", "2021", "1" },
			{ "disc", "conf", "wdag", "wdag", "87", "97", "1", "conf", "wdag", "disc", "98", "99", "1", "conf", "wdag",
					"disc", "2000", "2021", "1" },
			{ "esa", "conf", "esa", "esa", "93", "99", "1", "conf", "esa", "esa", "2000", "2009", "1", "conf", "esa",
					"esa", "2010", "2010", "2", "conf", "esa", "esa", "2011", "2021", "1" },
			{ "esop", "conf", "esop", "esop", "86", "86", "1", "conf", "esop", "esop", "88", "88", "1", "conf", "esop",
					"esop", "90", "90", "1", "conf", "esop", "esop", "92", "92", "1", "conf", "esop", "esop", "94",
					"94", "1", "conf", "esop", "esop", "96", "96", "1", "conf", "esop", "esop", "98", "99", "1", "conf",
					"esop", "esop", "2000", "2021", "1" },
			{ "eurocrypt", "conf", "eurocrypt", "eurocrypt", "82", "99", "1", "conf", "eurocrypt", "eurocrypt", "2000",
					"2014", "1", "conf", "eurocrypt", "eurocrypt", "2015", "2016", "2", "conf", "eurocrypt",
					"eurocrypt", "2017", "2021", "3" },
			{ "focs", "conf", "focs", "focs", "60", "99", "1", "conf", "focs", "focs", "2000", "2021", "1" },
			{ "icalp", "conf", "icalp", "icalp", "72", "72", "1", "conf", "icalp", "icalp", "74", "74", "1", "conf",
					"icalp", "icalp", "76", "99", "1", "conf", "icalp", "icalp", "2000", "2005", "1", "conf", "icalp",
					"icalp", "2006", "2006", "2", "conf", "icalp", "icalp", "2007", "2007", "1", "conf", "icalp",
					"icalp", "2008", "2015", "2", "conf", "icalp", "icalp", "2016", "2021", "1" },
			{ "lics", "conf", "lics", "lics", "86", "99", "1", "conf", "lics", "lics", "2000", "2013", "1", "conf",
					"csl", "csl", "2014", "2014", "1", "conf", "lics", "lics", "2015", "2021", "1" },
			{ "mfcs", "conf", "mfcs", "mfcs", "73", "99", "1", "conf", "mfcs", "mfcs", "2000", "2013", "1", "conf",
					"mfcs", "mfcs", "2014", "2015", "2", "conf", "mfcs", "mfcs", "2016", "2021", "1" },
			{ "podc", "conf", "podc", "podc", "82", "99", "1", "conf", "podc", "podc", "2000", "2021", "1" },
			{ "popl", "conf", "popl", "popl", "73", "99", "1", "conf", "popl", "popl", "2000", "2017", "1" },
			{ "soda", "conf", "soda", "soda", "90", "99", "1", "conf", "soda", "soda", "2000", "2021", "1" },
			{ "stacs", "conf", "stacs", "stacs", "84", "99", "1", "conf", "stacs", "stacs", "2000", "2021", "1" },
			{ "stoc", "conf", "stoc", "stoc", "69", "92", "1", "conf", "stoc", "stoc", "1993", "2021", "1" },
			{ "tacas", "conf", "tacas", "tacas", "95", "99", "1", "conf", "tacas", "tacas", "2000", "2016", "1", "conf",
					"tacas", "tacas", "2017", "2018", "2", "conf", "tacas", "tacas", "2019", "2019", "3", "conf",
					"tacas", "tacas", "2020", "2021", "2" } };
	public static String[][] default_arguments_second_phase = { { "cav", "cav", "cav", "1990", "2021", "ne" },
			{ "concur", "concur", "concur", "1984", "2021", "ne" },
			{ "crypto", "crypto", "crypto", "1981", "2021", "ne" }, { "csl", "csl", "csl", "1987", "2021", "ne" },
			{ "disc", "wdag", "wdag", "1987", "1997", "wdag", "disc", "1998", "2021", "ne" },
			{ "esa", "esa", "esa", "1993", "2021", "ne" }, { "esop", "esop", "esop", "1986", "2021", "ne" },
			{ "eurocrypt", "eurocrypt", "eurocrypt", "1982", "2021", "ne" },
			{ "focs", "focs", "focs", "1960", "2021", "ne" }, { "icalp", "icalp", "icalp", "1972", "2021", "ne" },
			{ "lics", "lics", "lics", "1986", "2013", "csl", "csl", "2014", "2014", "lics", "lics", "2015", "2021",
					"ne" },
			{ "mfcs", "mfcs", "mfcs", "1972", "2021", "mfcs/mfcs98gs" },
			{ "podc", "podc", "podc", "1982", "2021", "ne" }, { "popl", "popl", "popl", "1973", "2017", "ne" },
			{ "soda", "soda", "soda", "1990", "2021", "ne" }, { "stacs", "stacs", "stacs", "1984", "2021", "ne" },
			{ "stoc", "stoc", "stoc", "1969", "2021", "ne" }, { "tacas", "tacas", "tacas", "1995", "2021", "ne" } };
	public static String[] default_conferences = { "cav", "concur", "crypto", "csl", "disc", "esa", "esop", "eurocrypt",
			"focs", "icalp", "lics", "mfcs", "podc", "popl", "soda", "stacs", "stoc", "tacas" };
	public static int num_default_conf = 18;
	public static int first_year = 1900;
	public static int last_year = 2021;

	public static void main(String[] args) {
		if (args.length == 0) {
			System.setProperty("entityExpansionLimit", "10000000");
			RecordDbInterface dblp = Utilities.read_xml_file();
			for (int c = 0; c < num_default_conf; c++) {
				System.out.println("Processing " + default_conferences[c] + "...");
				ConferenceAuthorDataCollector.main(dblp, default_arguments_phirst_phase[c]);
				System.out.println("....first phase concluded");
				ConferenceTemporalAdjacencyMatrixCreator.main(dblp, default_arguments_second_phase[c]);
				System.out.println("....second phase concluded");
				TemporalGraphCreator.main(default_conferences[c]);
				System.out.println("....third phase concluded");
				TemporalGraphSorter.main(default_conferences[c]);
				System.out.println("....fourth phase concluded");
				Temporal2Static.main(default_conferences[c], first_year, last_year);
				System.out.println("....fifth phase concluded");
				System.out.println("done");
			}
		} else {
			int nsp = Integer.parseInt(args[0]);
			if ((args.length - nsp * 4 - 3) % 6 != 0) {
				System.out.println("Error in input format: see the documentation");
			} else {
				String[] fp = new String[args.length - nsp * 4 - 2];
				for (int i = 0; i < fp.length; i++) {
					fp[i] = args[i + 1];
				}
				String[] sp = new String[2 + nsp * 4];
				sp[0] = args[1];
				for (int i = 0; i < nsp; i++) {
					sp[1 + i * 4] = args[fp.length + 1 + i * 4];
					sp[2 + i * 4] = args[fp.length + 2 + i * 4];
					sp[3 + i * 4] = args[fp.length + 3 + i * 4];
					sp[4 + i * 4] = args[fp.length + 4 + i * 4];
				}
				sp[1 + nsp * 4] = args[args.length - 1];
				System.setProperty("entityExpansionLimit", "10000000");
				RecordDbInterface dblp = Utilities.read_xml_file();
				System.out.println("Processing " + args[1] + "...");
				ConferenceAuthorDataCollector.main(dblp, fp);
				System.out.println("....first phase concluded");
				ConferenceTemporalAdjacencyMatrixCreator.main(dblp, sp);
				System.out.println("....second phase concluded");
				TemporalGraphCreator.main(args[1]);
				System.out.println("....third phase concluded");
				TemporalGraphSorter.main(args[1]);
				System.out.println("....fourth phase concluded");
				Temporal2Static.main(args[1], first_year, last_year);
				System.out.println("....fifth phase concluded");
				System.out.println("done");
			}
		}
	}
}
