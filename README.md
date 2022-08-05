# Introduction

This repository includes and explains the code used for the comparative analysis presented at the exhibition on the history of ICALP in Paris, 2022, and for the analysis of the CONCUR conference.

## Table of contents

1. [Data collection code](#datacollection)
    1. [Using the `ccdm.jar` file](#ccdm.jar)
    2. [Collecting authors and their publications, and paper titles](#authorspubs)
        1. [Class `ConferenceAuthorDataCollector.java`](#ConferenceAuthorDataCollector)
    3. [Collecting papers and temporal adjacency matrices](#paperstemporal)
        1. [Class `ConferenceTemporalAdjacencyMatrixCreator.java`](#ConferenceTemporalAdjacencyMatrixCreator)
    4. [Creating the temporal graphs](#temporal)
        1. [Class `TemporalGraphCreator.java`](#TemporalGraphCreator)
    5. [Creating the static graphs](#static)
        1. [Class `Temporal2Static.java`](#Temporal2Static)
2. [Data and graph mining code](#datamining)

# Data collection (Java)<a name="datacollection"></a>

The data collection software has been developed in Java, mostly because this allowed us to take advantage of the Java library available on the DBLP web site (we used the DBLP XML file dated March 20, 2022). In particular, we make use of the Java library [mmdb-2019-04-29.jar](https://dblp.org/src/mmdb-2019-04-29.jar). You can see examples of the usage of this code in the class `Main.java`.

## Using the `ccdm.jar` file<a name="ccdm.jar"></a>

By default the code collects the data of the following eighteen theoretical computer science conferences (up to the 2021 edition).

1.  CAV: *International Conference on Computer Aided Verification*.

2.  CONCUR: *International Conference on Concurrency Theory*.

3.  CRYPTO: *Annual International Cryptology Conference*.

4.  CSL: *Annual Conference for Computer Science Logic*.

5.  DISC: *International Symposium on Distributed Computing*.

6.  ESA: *European Symposium on Algorithms*.

7.  ESOP: *European Symposium on Programming*.

8.  EUROCRYPT: *International Conference on the Theory and Application of Cryptographic Techniques*.

9.  FOCS: *IEEE Annual Symposium on Foundations of Computer Science*.

10. ICALP: *International Colloquium on Automata, Languages and Programming*.

11. LICS: *ACM/IEEE Symposium on Logic in Computer Science*.

12. MFCS: *International Symposium on Mathematical Foundations of Computer Science*.

13. PODC: *ACM SIGACT-SIGOPS Symposium on Principles of Distributed Computing*.

14. POPL: *ACM-SIGACT Symposium on Principles of Programming Languages*.

15. SODA: *ACM-SIAM Symposium on Discrete Algorithms*.

16. STACS: *Symposium on Theoretical Aspects of Computer Science*.

17. STOC: *Symposium on the Theory of Computing*.

18. TACAS: *International Conference on Tools and Algorithms for Construction and Analysis of Systems*.

To this aim, once the files `dblp.xml` and `dblp.dtd` (which are available at the DBLP web site) have been downloaded and saved in
directory `data`, it is sufficient to execute the following command:

`java -jar ccdm.jar`

In order to collect the data for another conference, then the necessary arguments have to be passed to the Java executable archive. For example, in order to collect the data of the conference *Fun with Algorithms*, we can execute the following command:

`java -jar ccdm.jar 1 fun conf fun fun 2007 2021 1 fun fun 2007 2021 ne`

(indeed, the first edition of this conference has been in 1998, but only a selection of the presented papers at the the first three editions has been published in three different journals). As it will be explained in the following, the list of arguments starts with an integer and the conference acronym, it continues with a series of blocks of six arguments each and with a series of blocks of four arguments each, and it ends with one final argument. The integer at the beginning of the arguments indicates how many blocks of four arguments are present (in the above example, we have one block of six arguments, that is, `conf fun fun 2007 2021 1` and one block of four arguments, that is, `fun fun 2007 2021`).

Note that the execution of the above two commands may require a few minutes (mostly because of the time necessary to process the XML file). Once the execution terminates, a directory conferences should have been created containing one directory for each conference, including all the data necessary for performing the [data and graph mining](#datamining).

## Collecting authors and their publications, and paper titles<a name="authorspubs"></a>

### Class `ConferenceAuthorDataCollector.java`<a name="ConferenceAuthorDataCollector"></a>

The input of the `main` method of this class is the global conference acronym followed by a sequence of groups of six arguments, each specifying the type, the DBLP directory, the acronym, the first year, the last year, and the number of parts of each edition of the considered conference. Indeed, the typical address of the table of contents of the edition of a conference starts with the prefix `https://dblp.org/db/`, followed by the type of the conference publication. For example, the *ACM-SIGACT Symposium on Principles of Programming Languages* has been published as conference proceedings until the 2017 edition. Successively, it has been published as a journal (in particular, the *Proceedings of the ACM on Programming Languages* journal). Hence, until 2017 the type of this conference has been `conf`, while afterwards it has become `journals`. The address of the table of contents continues with the name of the DBLP directory containing the table of contents of the conference. This directory can change from one year to the other, mostly because of the joint editions with other conferences. For example, the 2014 edition of the *ACM/IEEE Symposium on Logic in Computer Science* has been a joint edition with the *Annual Conference for Computer Science Logic*. For this reason, the address of the table of contents of the former conference continues with `csl`, instead of with `lics`, as in the other editions. The address continues with the acronym of the conference concatenated with the year of the edition and, if multiple parts are present, the part number (separated by a dash). First note that the acronym of the conference can change: for example, the *International Symposium on Distributed Computing* was originally named *Workshop on Distributed Algorithms*. For this reason, its acronym has been `wdag` until the 1997 edition, and it became `disc` afterwards. Secondly, note that in many cases the year is indicated by the last two digits until the 1999 edition of a conference, and by the four digits afterwards (there are also cases in which these two different representations alternate in the period before 1999). Finally, the proceedings of some editions of a conference are split into two or more parts (for instance, this is true in the case of the *International Colloquium on Automata, Languages and Programming* whenever the edition was split into three tracks. The simplest list of arguments that have to be passed to this class is, for example, the one to gather the data concerning the *ACM SIGACT-SIGOPS Symposium on Principles of Distributed Computing*. In this case, the list is simply the following one:

`podc conf podc podc 82 99 1 conf podc podc 2000 2021 1`

Indeed, this conference has been held every year starting from 1982, it never changed its name, its editions have never been joint with other conferences. On the other hand, one of the longest list of arguments that have to be passed to this class is the one to gather the data concerning the *International Colloquium on Automata, Languages and Programming*. In this case, the list is the following one:

`icalp conf icalp icalp 72 72 1 conf icalp icalp 74 74 1 conf icalp icalp 76 99 1 conf icalp icalp 2000 2005 1 conf icalp icalp 2006 2006 2 conf icalp icalp 2007 2007 1 conf icalp icalp 2008 2015 2 conf icalp icalp 2016 2021 1`

Indeed, there was no edition in 1973 and in 1975, while in 2006 and from 2008 to 2015 there were two parts of the proceedings, and the conference never changed its name.

Executing this class produces three text files, that is, `id_name_key.txt`, `author_paper_titles.txt`, and `author_conferences.txt` (see the `data` folder). The first one contains the list of the authors who presented at least one paper at the conference: for each author, the corresponding line contains the id, the first and last name, and the DBLP key of the author, separated by `##`. For example, a line corresponding to Pierluigi Crescenzi might be the following one:

`i##1820##n##Pierluigi Crescenzi##k##homepages/c/PCrescenzi`

The second text file contains the title of *all* papers (co)authored by one of the authors included in the `id_name_key.txt` file and published on a journal or presented at a conference (informal publications, such as `arxiv` papers, are not considered). For each author, there is a line containing the id, the first and last name, and the DBLP key of the author, such as before. Successively, for each publication, there is a line containing the year and the title of the publication itself, such as the following one:

`y##1999##t##Max NP-completeness Made Easy.`

Finally, the third text file contains the name of the conferences at which each author presented a paper (once again, informal publications are not considered). For each author, there is a line containing the id, the first and last name, and the DBLP key of the author, such as before. Successively, for each conference, there is a line containing the year and the name of the conference itself, such as the following one:

`y##1998##c##STOC`

It has to be noted that in this file, unfortunately, the same conference appears with slightly different names (sometimes even due to typographic errors), and that the number of different conferences can be quite high. For example, in the case of the *International Colloquium on Automata, Languages and Programming*, this file contains 6378 different conference names.

Finally, the execution of this class creates, within the directory named with the global conference acronym, the directory `papers`. Within this directory, for each year in which there was an edition of the conference, the class creates a file containing all the titles of the papers presented at that edition.

## Collecting papers and temporal adjacency matrices<a name="paperstemporal"></a>

### Class `ConferenceTemporalAdjacencyMatrixCreator.java`<a name="ConferenceTemporalAdjacencyMatrixCreator"></a>

The first input of the `main` method of this class is the conference acronym, while the next inputs are grouped into blocks of five values, that is, the DBLP directory, the prefix of the DBLP file, the first year, and the last year of each edition of the conference. The last input is the list of exceptions (separated by comma) for the conference (that is, the strings that should not appear in the DBLP URL): if there are no exceptions, then this input should be equal to `ne`. Note that, for all conferences, two exceptions are the DBLP directory followed by `/`, the prefix, and the letter `w`, and the DBLP directory followed by `/`, the prefix, the year, and the letter `w`. Executing this class produces the three text files `papers.txt`, `temporal_adjacency_matrix.txt`, and `temporal_adjacency_matrix_conf.txt` (which are all written in the directory whose name is the global acronym of the conference). The first file contains the list of the papers presented at the conference (the satellite workshops are not considered): for each paper, the corresponding line contains the year, the DBLP key of the paper, and the list of ids of the authors (the ids refer to the file `id_name_key.txt` created in the previous step). For example, the line corresponding to the paper *Online Load Balancing Made Simple: Greedy Strikes Back* by Pierluigi Crescenzi et al is the following one:

`y##2003##k##conf/icalp/CrescenziGNPU03##a##[1820, 635, 1821, 1822, 1823]`

The second file contains the temporal adjacency matrix of the authors collected in the previous step, by considering all papers published on a journal or presented at a conference (informal publications, such as `arxiv` papers, are not considered). For each pair of authors who coauthored at least one paper, the corresponding line contains the ids of the two authors and the multi-list of the years in which they coauthored a paper (it is a multi-list since two authors might have coauthored more than one paper in the same year). For example, the line corresponding to Pierluigi Crescenzi and Luca Trevisan (whose ids with respect to the *International Colloquium on Automata, Languages and Programming* are 1820 and 1557, respectively) is the following one:

`(1557,1820): [1995, 1994, 1996, 2017, 1994, 2001, 1996, 2000, 1999, 1999]`

(note that the two authors coauthored two papers in 1994, 1996, and 1999).

The third file contains the temporal adjacency matrix of the authors collected in the previous step, by considering only papers presented at the conference. The format is the same as in the previous file. For example, the line corresponding to Pierluigi Crescenzi and Giorgio Gambosi (whose ids with respect to the *International Colloquium on Automata, Languages and Programming* are 1820 and 635, respectively) is the following one:

`(635,1820): [2003]`

## Creating the temporal graphs<a name="temporal"></a>

From now on, we will not need anymore the file `dblp.xml`, and we will make use of the text files generated in the previous two steps.

### Class `TemporalGraphCreator.java`<a name="TemporalGraphCreator"></a>

The input of the `main` method of this class is the acronym of the conference. Executing this class produces the two text files `temporal_graph.txt` and `temporal_graph_conf.txt` containing the two temporal graphs induced by the authors collected in the previous step, by considering all papers published on a journal or presented at a conference (informal publications, such as `arxiv` papers, are not considered), and only papers presented at the conference, respectively. Each temporal graph is a list of temporal edges (*u*,*v*,*t*,*w*), where *u* and *v* are the ids of two authors, *t* is the year in which they coauthored at least one paper, and *w* is the number of papers they coauthored in year *t*. For example the first file with respect to the *International Colloquium on Automata, Languages and Programming* contains the line

`268,1820,1998,3`

since Pierluigi Crescenzi and Christos H. Papadimitriou (whose ids are 1820 and 268, respectively) coauthored three papers in 1998. The second file with respect to the *International Colloquium on Automata, Languages and Programming*, instead, contains the line

`635,1820,2003,1`

since Pierluigi Crescenzi and Giorgio Gambosi co-presented one paper at ICALP in 2003.

A sorted version of the previous two files (with respect to the year) can be obtained by executing the class `TemporalGraphSorter.java`. The input of the `main` method of this class is the acronym of the conference and which produces the two files `temporal_graph_sorted.txt` and `temporal_graph_conf_sorted.txt`. With respect to the *International Colloquium on Automata, Languages and Programming*, for example, the first temporal edge in the first file is dated 1959 and corresponds to a paper coauthored by Dana S. Scott and Michael O. Rabin (who have both published a paper in the *International Colloquium on Automata, Languages and Programming*), while the first temporal edge in the second file is dated, clearly, 1972.

## Creating the static graphs<a name="static"></a>

### Class `Temporal2Static.java`<a name="Temporal2Static"></a>

The input of the `main` method of this class is the acronym of the conference and the first and the last year to be considered. Executing this class produces the static version of the two temporal graphs generated in the previous step. In particular, it produces the two text files `static_graph.txt` and `static_graph_conf.txt` containing the two weighted graphs in which there is an edge (*u*,*v*) with weight *w* if and only *w* is the sum of the weights of all temporal edges between *u* and *v* in the corresponding temporal graph. Each weighted graph is a list of weighted edges (*u*,*v*,*w*). For example, with respect to the *International Colloquium on Automata, Languages and Programming*), the first file contains the line

`1820,3744,22`

since Pierluigi Crescenzi and Andrea Marino (whose ids are 1820 and 3744, respectively) coauthored 22 papers.

# Data and graph mining (Julia)<a name="datamining"></a>

The data and graph mining software has been developed in Julia. The documentation of the functions included in the code is available at [http://www.pilucrescenzi.it/miner/docs/](http://www.pilucrescenzi.it/miner/docs/). In order to execute the code, the Julia REPL has to be launched starting from the directory containing the directory `conferencemining` which has to contain the `src` directory including the Julia code files. In the REPL, the following command has to be executed (of course all directory names can be changed):

`include("conferencemining/src/Miner.jl")`

(see the code in `Miner.jl` for the required packages). Once the module `Miner` has been included, the following commands can be used in order to generate the plots for the CONCUR conference (see the documentation for the meaning of the arguments, which, of course, can be changed for other conferences).

1. Basic data mining plots.

`Miner.one_conference_data_mining("concur", true, 10)`

2. Sex analysis.

`Miner.one_conference_sex_mining("concur", true)`
