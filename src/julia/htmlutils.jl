function remove_non_ascii_characters(s::String)::String
    ss::String = replace(s, "à" => "a")
    ss = replace(ss, "á" => "a")
    ss = replace(ss, "á" => "a")
    ss = replace(ss, "â" => "a")
    ss = replace(ss, "ä" => "a")
    ss = replace(ss, "ã" => "a")
    ss = replace(ss, "è" => "e")
    ss = replace(ss, "é" => "e")
    ss = replace(ss, "ê" => "e")
    ss = replace(ss, "ë" => "e")
    ss = replace(ss, "é" => "e")
    ss = replace(ss, "ē" => "i")
    ss = replace(ss, "í" => "i")
    ss = replace(ss, "ì" => "i")
    ss = replace(ss, "ï" => "i")
    ss = replace(ss, "ò" => "o")
    ss = replace(ss, "ó" => "o")
    ss = replace(ss, "ô" => "o")
    ss = replace(ss, "ö" => "o")
    ss = replace(ss, "õ" => "o")
    ss = replace(ss, "ø" => "o")
    ss = replace(ss, "ù" => "u")
    ss = replace(ss, "ü" => "u")
    ss = replace(ss, "ú" => "u")
    ss = replace(ss, "û" => "u")
    #
    ss = replace(ss, "ç" => "n")
    ss = replace(ss, "ñ" => "n")
    ss = replace(ss, "ý" => "y")
    #
    ss = replace(ss, "ß" => "ss")
    #
    ss = replace(ss, "-" => " ")
    ss = replace(ss, "." => "")
    return ss
end

function remove_number_suffix(s::String)::String
    i::Int64 = length(s)
    while (isdigit(s[i]) || s[i] == ' ')
        i = i - 1
    end
    return s[1:i]
end

function start_html(io::IOStream, conf_name::String)
    write(io, "<!DOCTYPE html>")
    write(io, "<html xmlns=\"http://www.w3.org/1999/xhtml\">")
    write(io, "<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n<title>" * uppercase(conf_name) * "</title>\n<link type=\"text/css\" rel=\"stylesheet\"  href=\"cmstyle.css\"/>\n</head>\n<body>\n<a id='top'></a>\n<div id=\"container\">\n<div id=\"wrapper\">\n<div id=\"banner\">\n<div id=\"name\" style=\"display: inline-block; margin-top: 10px;\">\n<h1>" * uppercase(conf_name) * " through time</h1>\n<p>A data- and graph-mining analysis</p>\n</div>\n<div id=\"chart\" style=\"display: inline-block;  float: right;\"></div>\n</div>")
    write(io, "<div id=\"nav\">\n<ul>\n<li><a href=\"#intro\">Introduction</a></li>\n<li><a href=\"#data\">Data mining</a></li>\n<li><a href=\"#sex\">Sex analysis</a></li>\n<li><a href=\"#topic\">Topic analysis</a></li>\n<li><a href=\"#graphmining\">Graph mining</a></li>\n<li><a href=\"#centralities\">Centralities</a></li>\n<li><a href=\"#temporalgraph\">Temporal graph</a></li>\n</ul>\n</div>")
    write(io, "<div id=\"page\">\n<div id=\"content\">")
    write(io, "<div id=\"sidebar\">\n<img src=\"pc.jpg\" style=\"width: 190px; margin-left: 12px; margin-right: 12px; margin-top: 12px;\" title=\"photo\" id=\"photo\" alt=\"Pierluigi Crescenzi\"/>\n<p style=\"line-height: 150%\">\n<i class=\"fas fa-map-marker-alt\"></i>\n<a href=\"https://pilucrescenzi.it\">Pierluigi Crescenzi</a><br/>\n<a href=\"https://github.com/piluc/ConferenceMining\">Source code</a><br/>\n<a href=\"https://slides.com/piluc/icalp-50?token=fl3BBJ8j\">Comparative analysis of ICALP</a><br/>\n</p>\n</div>")
    write(io, "<a id=\"intro\"></a><h2>Introduction</h2>\n<p>We present the evolution of the " * uppercase(conf_name) * " conference throughout its history, the ebb and flow in the popularity of some research areas, and the centrality of " * uppercase(conf_name) * " authors, as measured by several metrics from network science, amongst other topics.</p>\n")
end

function start_html(io::IOStream, conf::Array{String}, web_page::BitVector, title::String, sub_title::String)
    conf_list::String = uppercase(conf[1])
    for c in 2:(length(conf)-1)
        conf_list = conf_list * ", " * uppercase(conf[c])
    end
    if (length(conf) == 2)
        conf_list = conf_list * " and " * uppercase(conf[length(conf)])
    end
    if (length(conf) > 2)
        conf_list = conf_list * ", and " * uppercase(conf[length(conf)])
    end
    write(io, "<!DOCTYPE html>")
    write(io, "<html xmlns=\"http://www.w3.org/1999/xhtml\">")
    write(io, "<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n<title>" * title * "</title>\n<link type=\"text/css\" rel=\"stylesheet\"  href=\"cmstyle.css\"/>\n</head>\n<body>\n<a id='top'></a>\n<div id=\"container\">\n<div id=\"wrapper\">\n<div id=\"banner\">\n<div id=\"name\" style=\"display: inline-block; margin-top: 10px;\">\n<h1>" * title * "</h1>\n<p>" * sub_title * "</p>\n</div>\n<div id=\"chart\" style=\"display: inline-block;  float: right;\"></div>\n</div>")
    write(io, "<div id=\"nav\">\n<ul>\n<li><a href=\"#intro\">Introduction</a></li>\n<li><a href=\"#data\">Data mining</a></li>\n<li><a href=\"#sex\">Sex analysis</a></li>\n<li><a href=\"#graphmining\">Graph mining</a></li>\n<li><a href=\"#centralities\">Centralities</a></li>\n<li><a href=\"#temporalgraph\">Temporal graph</a></li>\n</ul>\n</div>")
    write(io, "<div id=\"page\">\n<div id=\"content\">")
    write(io, "<div id=\"sidebar\">\n<img src=\"pc.jpg\" style=\"width: 190px; margin-left: 12px; margin-right: 12px; margin-top: 12px;\" title=\"photo\" id=\"photo\" alt=\"Pierluigi Crescenzi\"/>\n<p style=\"line-height: 150%\">\n<i class=\"fas fa-map-marker-alt\"></i>\n<a href=\"https://pilucrescenzi.it\">Pierluigi Crescenzi</a><br/>\n<a href=\"https://github.com/piluc/ConferenceMining\">Source code</a><br/>\n<a href=\"https://slides.com/piluc/icalp-50?token=fl3BBJ8j\">Comparative analysis of ICALP</a><br/>\n</p>\n</div>")
    write(io, "<a id=\"intro\"></a><h2>Introduction</h2>\n<p>We present a comparative analysis of the evolution  of the following conferences: " * conf_list * ". For each conference, we also provide a link to a web page (if available) presenting the evolution of the conference itself. As already said, we consider the following " * string(length(conf)) * " conferences.\n<ol>")
    for c in 1:length(conf)
        conf_name::String = uppercase(conf[c])
        if (web_page[c])
            conf_name = "<a href=\"../" * conf[c] * "/" * conf[c] * ".html\">" * conf_name * "</a>"
        end
        fy::Int64, _ = first_last_year(conf[c])
        my::Vector{Int64} = collect(missing_years(conf[c]))
        if (length(my) == 0)
            write(io, "<li>" * conf_name * ". First edition in " * string(fy) * ".</li>\n")
        else
            sort!(my)
            my_list::String = string(my[1])
            for y in 2:(length(my)-1)
                my_list = my_list * ", " * string(my[y])
            end
            if (length(my) == 2)
                my_list = my_list * " and " * string(my[length(my)])
            end
            if (length(my) > 2)
                my_list = my_list * ", and " * string(my[length(my)])
            end
            write(io, "<li><a href=\"../" * conf[c] * "/" * conf[c] * ".html\">" * uppercase(conf[c]) * "</a>. First edition in " * string(fy) * ". No edition in " * my_list * ".</li>\n")
        end
    end
    write(io, "</ol></p>\n")
end

function end_html(io::IOStream)
    write(io, "</div>\n</div>\n</div>\n<div id=\"footer\">\n<a href=\"#top\">&#8648; Back to the top</a>\n</div>\n</div>\n</body>\n</html>")
end

function data_mining_html(io::IOStream, conf_name::String, co_author_step::Int64, conf_array::Vector{String})
    paper_year_plot([conf_name], 1, conf_name, "/paper_year")
    cp(path_to_files * "images/" * conf_name * "/paper_year.html", path_to_files * "html/" * conf_name * "/paper_year.html", force=true)
    author_year_plot([conf_name], 1, conf_name, "/author_year")
    cp(path_to_files * "images/" * conf_name * "/author_year.html", path_to_files * "html/" * conf_name * "/author_year.html", force=true)
    coauthorship_plot(conf_name, co_author_step, conf_name, "/co_authorship")
    cp(path_to_files * "images/" * conf_name * "/co_authorship.html", path_to_files * "html/" * conf_name * "/co_authorship.html", force=true)
    perc_new_author_year_plot([conf_name], 1, conf_name, "/perc_new_author_year")
    cp(path_to_files * "images/" * conf_name * "/perc_new_author_year.html", path_to_files * "html/" * conf_name * "/perc_new_author_year.html", force=true)
    if (length(filter(c -> c != conf_name, conf_array)) > 0)
        similarity_indices_plot(filter(c -> c != conf_name, conf_array), [conf_name], conf_name, "/similarity_values")
        conf_index = findfirst(x -> x == conf_name, conf_array)
        if (conf_index === nothing)
            fully_new_new_author_mean_bar_chart([[conf_name]; conf_array], 0, 0, conf_name, "/fully_new_new_author_perc_bar")
        else
            fully_new_new_author_mean_bar_chart(conf_array, 0, 0, conf_name, "/fully_new_new_author_perc_bar")
        end
        cp(path_to_files * "images/" * conf_name * "/fully_new_new_author_perc_bar.html", path_to_files * "html/" * conf_name * "/fully_new_new_author_perc_bar.html", force=true)
        cp(path_to_files * "images/" * conf_name * "/similarity_values.html", path_to_files * "html/" * conf_name * "/similarity_values.html", force=true)
    end
    # 
    write(io, "<a id=\"data\"></a><h2>Data mining</h2>\n<h3>Evolution of paper and author numbers</h3>\n<p>The following picture shows the evolution of the number of " * uppercase(conf_name) * " papers per year.</p>\n<iframe title=\"Evolution of paper number\" src=\"paper_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution of the number of " * uppercase(conf_name) * " authors per year.</p>\n<iframe title=\"Evolution of author number\" src=\"author_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution of the number of co-authors per " * uppercase(conf_name) * " paper. In particular, for each period and for each number k of co-authors, the plot shows the number of " * uppercase(conf_name) * " papers in that period with k authors.</p>\n<iframe title=\"Evolution of co-authorship size\" src=\"co_authorship.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution of the percentage of <i>new</i> distinct authors of the " * uppercase(conf_name) * " papers per year.</p>\n<iframe title=\"Evolution of percentage of new authors\" src=\"perc_new_author_year.html\" width=\"600\" height=\"600\"></iframe>\n")
    if (length(filter(c -> c != conf_name, conf_array)) > 0)
        write(io, "<p>The following picture shows the average percentage of fully new authors and of new authors for " * uppercase(conf_name) * " and other computer science conferences.</p>\n<iframe title=\"Comparison of average percentage of fully new authors and of new authors\" src=\"fully_new_new_author_perc_bar.html\" width=\"600\" height=\"600\"></iframe>\n<h3>Similarity with other conferences</h3>\n<p>Given two sets A and B, the Jaccard index J(A,B) is equal to the ratio between the cardinality of their intersection and the cardinality of their union. The Sorensen-Dice index of similarity is equal to 2J(A,B)/(1+J(A,B)). The following picture shows the Sorensen-Dice index of similarity computed by comparing the set of " * uppercase(conf_name) * " authors with the sets of authors for other computer science conferences.</p>\n<iframe title=\"Sorensen-Dice index of similarity\" src=\"similarity_values.html\" width=\"600\" height=\"600\"></iframe>\n")
    end
end

function data_mining_html(io::IOStream, conf::Array{String}, fy::Int64, ly::Int64, html_dir::String)
    paper_year_plot(conf, 1, html_dir, "/paper_year")
    cp(path_to_files * "images/" * html_dir * "/paper_year.html", path_to_files * "html/" * html_dir * "/paper_year.html", force=true)
    author_year_plot(conf, 1, html_dir, "/author_year")
    cp(path_to_files * "images/" * html_dir * "/author_year.html", path_to_files * "html/" * html_dir * "/author_year.html", force=true)
    perc_new_author_year_plot(conf, 1, html_dir, "/perc_new_author_year")
    cp(path_to_files * "images/" * html_dir * "/perc_new_author_year.html", path_to_files * "html/" * html_dir * "/perc_new_author_year.html", force=true)
    fully_new_new_author_mean_bar_chart(conf, fy, ly, html_dir, "/fully_new_new_author_perc_bar")
    cp(path_to_files * "images/" * html_dir * "/fully_new_new_author_perc_bar.html", path_to_files * "html/" * html_dir * "/fully_new_new_author_perc_bar.html", force=true)
    coauthorship_perc_plot(conf, 1, html_dir, "/co_authorship_perc")
    cp(path_to_files * "images/" * html_dir * "/co_authorship_perc.html", path_to_files * "html/" * html_dir * "/co_authorship_perc.html", force=true)
    similarity_indices_plot(conf, conf, html_dir, "/similarity_values")
    cp(path_to_files * "images/" * html_dir * "/similarity_values.html", path_to_files * "html/" * html_dir * "/similarity_values.html", force=true)
    # 
    write(io, "<a id=\"data\"></a><h2>Data mining</h2>\n<h3>Evolution of paper and author numbers</h3>\n<p>The following picture shows, for each conference, the evolution of the number of its papers per year.</p>\n<iframe title=\"Evolution of paper number\" src=\"paper_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows, for each conference, the evolution of the number of its authors per year.</p>\n<iframe title=\"Evolution of author number\" src=\"author_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows, for each conference, the evolution of the percentage of its <i>new</i> distinct authors per year.</p>\n<iframe title=\"Evolution of percentage of new authors\" src=\"perc_new_author_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows, for each conference, the <i>average</i> percentage of fully new authors and of new authors at each year between " * string(fy) * " and " * string(ly) * ".</p>\n<iframe title=\"Comparison of average percentage of fully new authors and of new authors\" src=\"fully_new_new_author_perc_bar.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows, for each conference, the percentage of papers with the specified number of co-authors (in particular, for each number k of co-authors, the plot shows the percentage of papers, over all papers, with k authors).</p>\n<iframe title=\"Percentage of papers with specificic co-authorship size\" src=\"co_authorship_perc.html\" width=\"600\" height=\"600\"></iframe>\n<h3>Similarity between conferences</h3>\n<p>Given two sets A and B, the Jaccard index J(A,B) is equal to the ratio between the cardinality of their intersection and the cardinality of their union. The Sorensen-Dice index of similarity is equal to 2J(A,B)/(1+J(A,B)). The following picture shows the Sorensen-Dice index of similarity computed by comparing, for each pair of conferences C1 and C2, the set of C1's authors with the set of C2's authors.</p>\n<iframe title=\"Sorensen-Dice index of similarity\" src=\"similarity_values.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function sex_analysis_html(io::IOStream, conf_name::String)
    perc_sex_plot(conf_name, conf_name, "perc_sex")
    cp(path_to_files * "images/" * conf_name * "/perc_sex.html", path_to_files * "html/" * conf_name * "/perc_sex.html", force=true)
    # 
    write(io, "<a id=\"sex\"></a><h2>Sex analysis</h2>\n<p>The sex of " * uppercase(conf_name) * " authors has been determined mostly by querying the web service available at <a href=\"https://genderize.io/\"><tt>genderize.io</tt></a> (which is based on first names only), and partly by manually searching the authors on the web. The following picture shows the evolution of the percentages of male and female authors per year (the two percentages are computed with respect to the number of authors for which the sex has been assigned). The percentage of authors with no sex assigned is also shown (with respect to the total number of authors).</p>\n<iframe title=\"Evolution of the percentage of male and female authors\" src=\"perc_sex.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function sex_analysis_html(io::IOStream, conf::Array{String}, html_dir::String)
    missing_sex_bar_chart(conf, 0, false, html_dir, "no_sex_author_perc")
    cp(path_to_files * "images/" * html_dir * "/no_sex_author_perc.html", path_to_files * "html/" * html_dir * "/no_sex_author_perc.html", force=true)
    female_male_ratio_plot(conf, 1, html_dir, "female_male_ratio")
    cp(path_to_files * "images/" * html_dir * "/female_male_ratio.html", path_to_files * "html/" * html_dir * "/female_male_ratio.html", force=true)
    # 
    write(io, "<a id=\"sex\"></a><h2>Sex analysis</h2>\n<p>The sex of the authors has been determined mostly by querying the web service available at <a href=\"https://genderize.io/\"><tt>genderize.io</tt></a> (which is based on first names only), and partly by manually searching the authors on the web. The following picture shows, for each conference, the percentage of authors whose sex has not been determined.</p>\n<iframe title=\"Percentage of authors with no sex determined\" src=\"no_sex_author_perc.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows, for each conference, the evolution of the ratio between the number of female and male authors per year (the two percentages are computed with respect to the number of authors to which the sex has been assigned).</p>\n<iframe title=\"Evolution of the ratio between the number of female and male authors\" src=\"female_male_ratio.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function topic_analysis_html(io::IOStream, conf_name::String, word_step::Int64, word_k::Int64, forbidden::Vector{String})
    get_all_paper_titles(conf_name)
    word_cloud(conf_name, conf_name, "wordcloud")
    cp(path_to_files * "images/" * conf_name * "/wordcloud.png", path_to_files * "html/" * conf_name * "/wordcloud.png", force=true)
    ngram_evolution_plot(conf_name, word_step, word_k, forbidden, conf_name, "/top_word_evolution")
    cp(path_to_files * "images/" * conf_name * "/top_word_evolution.html", path_to_files * "html/" * conf_name * "/top_word_evolution.html", force=true)
    # 
    write(io, "<a id=\"topic\"></a><h2>Topic analysis</h2>\n<p>The following pictures shows the word cloud corresponding to the words contained in the titles of " * uppercase(conf_name) * " papers.</p>\n<img src=\"wordcloud.png\" alt=\"Cloud of words in titles\" width=\"800\" height=\"600\">\n<p>Of all the words contained in the titles of " * uppercase(conf_name) * " papers in a certain time interval, the following picture shows what fraction of them are one of the most frequent 10 words.</p>\n<iframe title=\"Evolution of top word frequencies\" src=\"top_word_evolution.html\" width=\"800\" height=\"600\"></iframe>\n")
end

function graph_mining_html(io::IOStream, conf_name::String)
    _, _, _, nn, ne, density, lcc_perc, _ = graph_statistics([conf_name])[1]
    densification_log_log_plot([conf_name], 1, conf_name, "/densification")
    cp(path_to_files * "images/" * conf_name * "/densification.html", path_to_files * "html/" * conf_name * "/densification.html", force=true)
    diameter_plot([conf_name], 1, conf_name, "/diameter", false)
    cp(path_to_files * "images/" * conf_name * "/diameter.html", path_to_files * "html/" * conf_name * "/diameter.html", force=true)
    diameter_plot([conf_name], 1, conf_name, "/effective_diameter", true)
    cp(path_to_files * "images/" * conf_name * "/effective_diameter.html", path_to_files * "html/" * conf_name * "/effective_diameter.html", force=true)
    degree_separation_plot([conf_name], 1, conf_name, "/degrees_separation")
    cp(path_to_files * "images/" * conf_name * "/degrees_separation.html", path_to_files * "html/" * conf_name * "/degrees_separation.html", force=true)
    # 
    write(io, "<a id=\"graphmining\"></a><h2>Graph mining</h2>\n<p>The static graph (or collaboration graph) of " * uppercase(conf_name) * " is an undirected graph whose nodes are the authors who presented at least one paper at " * uppercase(conf_name) * ", and whose edges (a1,a2) correspond to two authors a1 and a2 who co-authored at least one paper (not necessarily presented at " * uppercase(conf_name) * "). In other words, this graph is the subgraph of the DBLP graph induced by the set of " * uppercase(conf_name) * " authors (for a definition of most of the notions used in this section and in the next one and for a description of the used algorithms, we refer the interested reader to the lecture notes available at <a href=\"https://github.com/piluc/GraphMining\">https://github.com/piluc/GraphMining</a>). The static graph contains " * string(nn) * " nodes and " * string(ne) * " edges. Its density is equal to " * string(Base._round_invstep(density, 1 / 0.0001, RoundNearest)) * " and its largest connected component contains " * string(trunc(Int64, 100 * Base._round_invstep(lcc_perc, 1 / 0.01, RoundNearest))) * "% of all nodes.</p>\n<p>The following picture shows the evolution of the number of edges with respect to the number of nodes (in a log-log scale).</p>\n<iframe title=\"Densification\" src=\"densification.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the diameter of the largest connected component.</p>\n<iframe title=\"Diameter shrinking\" src=\"diameter.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the effective diameter of the largest connected component (the effective diameter is the minimum value such that at least 90% of the pairs of connected nodes are at distance at most this value).</p>\n<iframe title=\"Effective diameter shrinking\" src=\"effective_diameter.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the average distance between two nodes in the largest connected component (that is, the degrees of separation).</p>\n<iframe title=\"Degrees of separation\" src=\"degrees_separation.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function graph_mining_html(io::IOStream, conf::Array{String}, html_dir::String)
    fy, ly = first_last_year(conf)
    nn_ne_d_lcc = graph_statistics(conf)
    densification_log_log_plot(conf, 1, html_dir, "/densification")
    cp(path_to_files * "images/" * html_dir * "/densification.html", path_to_files * "html/" * html_dir * "/densification.html", force=true)
    diameter_plot(conf, 1, html_dir, "/diameter", false)
    cp(path_to_files * "images/" * html_dir * "/diameter.html", path_to_files * "html/" * html_dir * "/diameter.html", force=true)
    diameter_plot(conf, 1, html_dir, "/effective_diameter", true)
    cp(path_to_files * "images/" * html_dir * "/effective_diameter.html", path_to_files * "html/" * html_dir * "/effective_diameter.html", force=true)
    degree_separation_plot(conf, 1, html_dir, "/degrees_separation")
    cp(path_to_files * "images/" * html_dir * "/degrees_separation.html", path_to_files * "html/" * html_dir * "/degrees_separation.html", force=true)
    # 
    write(io, "<a id=\"graphmining\"></a><h2>Graph mining</h2>\n<p>The static graph (or collaboration graph) of a conference is an undirected graph whose nodes are the authors who presented at least one paper at the conference, and whose edges (a1,a2) correspond to two authors a1 and a2 who co-authored at least one paper (not necessarily presented at the conference). In other words, this graph is the subgraph of the DBLP graph induced by the set of the conference's authors (for a definition of most of the notions used in this section and in the next one and for a description of the used algorithms, we refer the interested reader to the lecture notes available at <a href=\"https://github.com/piluc/GraphMining\">https://github.com/piluc/GraphMining</a>). The following table shows, for each conference, the number n of nodes, the number m of edges, the density (that is, 2m/(n(n-1))) and the percentage of nodes included in the largest connected component (in short, LCC) of its static graph.</p>\n<table border=\"1\">\n<tr style=\"background-color: #dddddd\">\n<th style=\"padding: 10px\">Conference</th>\n<th style=\"padding: 10px\">Number of nodes</th>\n<th style=\"padding: 10px\">Number of edges</th>\n<th style=\"padding: 10px\">Density</th>\n<th style=\"padding: 10px\">LCC</th>\n</tr>\n")
    for c in 1:length(conf)
        nn = string(nn_ne_d_lcc[c][4])
        ne = string(nn_ne_d_lcc[c][5])
        d = string(Base._round_invstep(nn_ne_d_lcc[c][6], 1 / 0.0001, RoundNearest))
        lcc = string(trunc(Int64, 100 * Base._round_invstep(nn_ne_d_lcc[c][7], 1 / 0.01, RoundNearest)))
        write(io, "<tr>\n<td style=\"padding: 5px\">" * uppercase(conf[c]) * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * nn * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * ne * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * d * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * lcc * "%</td>\n</tr>\n")
    end
    write(io, "</table>\n<p>The following picture shows the evolution of the number of edges with respect to the number of nodes (in a log-log scale).</p>\n<iframe title=\"Densification\" src=\"densification.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the diameter of the largest connected component.</p>\n<iframe title=\"Diameter shrinking\" src=\"diameter.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the effective diameter of the largest connected component (the effective diameter is the minimum value such that at least 90% of the pairs of connected nodes are at distance at most this value).</p>\n<iframe title=\"Effective diameter shrinking\" src=\"effective_diameter.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the average distance between two nodes in the largest connected component (that is, the degrees of separation).</p>\n<iframe title=\"Degrees of separation\" src=\"degrees_separation.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function centralities_html(io::IOStream, conf_name::String, centrality_k::Int64)
    d = top_k_authors([conf_name], centrality_k)
    # 
    write(io, "<a id=\"centralities\"></a><h2>Centralities</h2>\n<p>The top-" * string(centrality_k) * " authors are the following.\n<ol>\n<li><b>Degree</b>: ")
    for a in 1:(centrality_k-1)
        write(io, remove_number_suffix(d[conf_name][1][a]) * ", ")
    end
    write(io, remove_number_suffix(d[conf_name][1][centrality_k]) * ".\n</li>\n<li><b>Closeness</b>: ")
    for a in 1:(centrality_k-1)
        write(io, remove_number_suffix(d[conf_name][2][a]) * ", ")
    end
    write(io, remove_number_suffix(d[conf_name][2][centrality_k]) * ".\n</li>\n<li><b>Betweenness</b>: ")
    for a in 1:(centrality_k-1)
        write(io, remove_number_suffix(d[conf_name][3][a]) * ", ")
    end
    write(io, remove_number_suffix(d[conf_name][3][centrality_k]) * ".\n</li>\n</ol>\n</p>\n")
end

function centralities_html(io::IOStream, conf::Array{String})
    d = top_k_authors(conf, 1)
    # 
    write(io, "<a id=\"centralities\"></a><h2>Centralities</h2>\n<p>For each author a, the degree of a is the number of a's co-authors, the closeness of a is the average distance from a to  all other authors, and the betweenness of a is the fraction of shortest paths passing through a (all these measures are computed by referring to the largest connected component). The following table shows, for each conference, the top author with respect to the degree, the closeness, and the betweenness measures.</p>\n<table border=\"1\">\n<tr style=\"background-color: #dddddd\">\n<th style=\"padding: 10px\">Conference</th>\n<th style=\"padding: 10px\">Degree</th>\n<th style=\"padding: 10px\">Closeness</th>\n<th style=\"padding: 10px\">Betweenness</th>\n</tr>\n")
    for c in 1:length(conf)
        write(io, "<tr>\n<td style=\"padding: 5px\">" * uppercase(conf[c]) * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * remove_number_suffix(d[conf[c]][1][1]) * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * remove_number_suffix(d[conf[c]][2][1]) * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * remove_number_suffix(d[conf[c]][3][1]) * "</td>\n</tr>\n")
    end
    write(io, "</table>\n<p>")
end

function temporal_graph_html(io::IOStream, conf_name::String, closeness_k::Int64, harmonic_k::Int64)
    tki, tkn = top_k_temporal_closeness(conf_name, closeness_k, false)
    if (harmonic_k > closeness_k)
        harmonic_k = closeness_k
    end
    temporal_closeness_plot(conf_name, tki[1:harmonic_k], 1, conf_name, "/temporal_harmonic_closeness")
    cp(path_to_files * "images/" * conf_name * "/temporal_harmonic_closeness.html", path_to_files * "html/" * conf_name * "/temporal_harmonic_closeness.html", force=true)    # 
    write(io, "<a id=\"temporalgraph\"></a><h2>Temporal graph</h2>\n<p>The temporal graph has the same set of nodes of the static graph, but the edges (a1,a2,y) correspond to two authors a1 and a2 who co-authored in year y at least one paper (not necessarily presented at " * uppercase(conf_name) * "). The <a href=\"https://www.mdpi.com/1999-4893/13/9/211\">temporal closeness</a> is intuitively the area covered by the plot of the temporal harmonic closeness of an author. For example, in the following figure, the plot of the temporal harmonic closeness of the top-" * string(harmonic_k) * " authors with respect to the temporal closeness are shown.</p>\n<iframe title=\"Example of temporal harmonic closeness evolution\" src=\"temporal_harmonic_closeness.html\" width=\"600\" height=\"600\"></iframe>\n<p>The top-" * string(closeness_k) * " authors with respect to the temporal closeness are ")
    for a in 1:(closeness_k-1)
        write(io, remove_number_suffix(tkn[a]) * ", ")
    end
    write(io, remove_number_suffix(tkn[closeness_k]) * ".</p>\n")
end

function temporal_graph_html(io::IOStream, conf::Array{String})
    tkn::Matrix{String} = Array{String,2}(undef, length(conf), 3)
    for c in 1:length(conf)
        top::Vector{String} = top_k_temporal_closeness(conf[c], 3, false)[2]
        tkn[c, 1] = top[1]
        tkn[c, 2] = top[2]
        tkn[c, 3] = top[3]
    end
    write(io, "<a id=\"temporalgraph\"></a><h2>Temporal graph</h2>\n<p>The temporal graph has the same set of nodes of the static graph, but the edges (a1,a2,y) correspond to two authors a1 and a2 who co-authored in year y at least one paper (not necessarily presented at the conference). The <a href=\"https://www.mdpi.com/1999-4893/13/9/211\">temporal closeness</a> is intuitively the area covered by the plot of the temporal harmonic closeness of an author. The following table shows, for each conference, the top three authors with respect to the temporal closeness.</p>\n<table border=\"1\">\n<tr style=\"background-color: #dddddd\">\n<th style=\"padding: 10px\">Conference</th>\n<th style=\"padding: 10px\">First author</th>\n<th style=\"padding: 10px\">Second author</th>\n<th style=\"padding: 10px\">Third author</th>\n</tr>\n")
    for c in 1:length(conf)
        write(io, "<tr>\n<td style=\"padding: 5px\">" * uppercase(conf[c]) * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * remove_number_suffix(tkn[c, 1]) * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * remove_number_suffix(tkn[c, 2]) * "</td>\n<td align=\"right\" style=\"padding: 5px\">" * remove_number_suffix(tkn[c, 3]) * "</td>\n</tr>\n")
    end
    write(io, "</table>\n<p>")
end
