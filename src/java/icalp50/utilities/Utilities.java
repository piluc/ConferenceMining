package icalp50.utilities;

import java.io.IOException;

import org.dblp.mmdb.RecordDb;
import org.dblp.mmdb.RecordDbInterface;
import org.xml.sax.SAXException;

public class Utilities {
	public static RecordDbInterface read_xml_file() {
		String dblpXmlFilename = "./data/dblp.xml";
		String dblpDtdFilename = "./data/dblp.dtd";
		System.out.println("building the dblp main memory DB ...");
		long start = System.currentTimeMillis();
		RecordDbInterface dblp = null;
		try {
			dblp = new RecordDb(dblpXmlFilename, dblpDtdFilename, false);
		} catch (final IOException ex) {
			System.err.println("cannot read dblp XML: " + ex.getMessage());
			System.exit(-1);
		} catch (final SAXException ex) {
			System.err.println("cannot parse XML: " + ex.getMessage());
			System.exit(-1);
		}
		long end = System.currentTimeMillis();
		System.out.format("MMDB created in %d seconds ", (end - start) / 1000);
		System.out.format("and ready: %d publs, %d pers\n\n", dblp.numberOfPublications(), dblp.numberOfPersons());
		return dblp;
	}
}
