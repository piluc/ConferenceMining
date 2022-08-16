function start_html(io::IOStream, conf_name::String)
    write(io, "<!DOCTYPE html>")
    write(io, "<html xmlns=\"http://www.w3.org/1999/xhtml\">")
    write(io, "<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n<title>" * uppercase(conf_name) * "</title>\n<link type=\"text/css\" rel=\"stylesheet\"  href=\"cmstyle.css\"/>\n</head>\n<body>\n<a id='top'></a>\n<div id=\"container\">\n<div id=\"wrapper\">\n<div id=\"banner\">\n<div id=\"name\" style=\"display: inline-block; margin-top: 10px;\">\n<h1>" * uppercase(conf_name) * " through time</h1>\n<p>A data- and graph-mining analysis</p>\n</div>\n<div id=\"chart\" style=\"display: inline-block;  float: right;\"></div>\n</div>")
    write(io, "<div id=\"nav\">\n<ul>\n<li><a href=\"#intro\">Introduction</a></li>\n<li><a href=\"#data\">Data mining</a></li>\n<li><a href=\"#sex\">Sex analysis</a></li>\n<li><a href=\"#topic\">Topic analysis</a></li>\n<li><a href=\"#graphmining\">Graph mining</a></li>\n<li><a href=\"#centralities\">Centralities</a></li>\n<li><a href=\"#temporalgraph\">Temporal graph</a></li>\n</ul>\n</div>")
    write(io, "<div id=\"page\">\n<div id=\"content\">")
    write(io, "<div id=\"sidebar\">\n<img src=\"pc.jpg\" style=\"width: 190px; margin-left: 12px; margin-right: 12px; margin-top: 12px;\" title=\"photo\" id=\"photo\" alt=\"Pierluigi Crescenzi\"/>\n<p style=\"line-height: 150%\">\n<i class=\"fas fa-map-marker-alt\"></i>\n<a href=\"https://pilucrescenzi.it\">Pierluigi Crescenzi</a><br/>\n<a href=\"https://github.com/piluc/ConferenceMining\">Source code</a><br/>\n<a href=\"https://slides.com/piluc/icalp-50?token=fl3BBJ8j\">Comparative analysis of ICALP</a><br/>\n</p>\n</div>")
    write(io, "<a id=\"intro\"></a><h2>Introduction</h2>\n<p>We present the evolution of the " * uppercase(conf_name) * " conference throughout its history, the ebb and flow in the popularity of some research areas in graph theory, and the centrality of " * uppercase(conf_name) * " authors, as measured by several metrics from network science, amongst other topics.</p>\n")
end

function end_html(io::IOStream)
    write(io, "</div>\n</div>\n</div>\n<div id=\"footer\">\n<a href=\"#top\">&#8648; Back to the top</a>\n</div>\n</div>\n</body>\n</html>")
end

function data_mining_html(io::IOStream, conf_name::String, co_author_step::Int64, conf_array::Vector{String})
    paper_year_plot([conf_name], 1, conf_name * "/paper_year")
    cp(path_to_files * "images/" * conf_name * "/paper_year.html", path_to_files * "html/" * conf_name * "/paper_year.html", force=true)
    author_year_plot([conf_name], 1, conf_name * "/author_year")
    cp(path_to_files * "images/" * conf_name * "/author_year.html", path_to_files * "html/" * conf_name * "/author_year.html", force=true)
    coauthorship_plot(conf_name, co_author_step, conf_name * "/co_authorship_period")
    cp(path_to_files * "images/" * conf_name * "/co_authorship_period.html", path_to_files * "html/" * conf_name * "/co_authorship_period.html", force=true)
    perc_new_author_year_plot([conf_name], 1, conf_name * "/perc_new_author_year")
    cp(path_to_files * "images/" * conf_name * "/perc_new_author_year.html", path_to_files * "html/" * conf_name * "/perc_new_author_year.html", force=true)
    similarity_indices_plot(filter(c -> c != conf_name, conf_array), [conf_name], conf_name * "/similarity_values")
    conf_index = findfirst(x -> x == conf_name, conf_array)
    if (conf_index === nothing)
        new_author_mean_bar_chart([[conf_name]; conf_array], 1, conf_name * "/new_author_perc_bar")
    else
        new_author_mean_bar_chart(conf_array, conf_index, conf_name * "/new_author_perc_bar")
    end
    cp(path_to_files * "images/" * conf_name * "/new_author_perc_bar.html", path_to_files * "html/" * conf_name * "/new_author_perc_bar.html", force=true)
    cp(path_to_files * "images/" * conf_name * "/similarity_values.html", path_to_files * "html/" * conf_name * "/similarity_values.html", force=true)
    # 
    write(io, "<a id=\"data\"></a><h2>Data mining</h2>\n<h3>Evolution of paper and author numbers</h3>\n<p>The following picture shows the evolution of the number of " * uppercase(conf_name) * " papers per year.</p>\n<iframe title=\"Evolution of paper number\" src=\"paper_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution of the number of " * uppercase(conf_name) * " authors per year.</p>\n<iframe title=\"Evolution of author number\" src=\"author_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution of the number of co-authors per " * uppercase(conf_name) * " paper. In particular, for each period and for each number k of co-authors, the plot shows the number of " * uppercase(conf_name) * " papers in that period with k authors.</p>\n<iframe title=\"Evolution of co-authorship size\" src=\"co_authorship_period.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution of the percentage of <i>new</i> distinct authors of the " * uppercase(conf_name) * " papers per year.</p>\n<iframe title=\"Evolution of percentage of new authors\" src=\"perc_new_author_year.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the average percentage of new authors for " * uppercase(conf_name) * " and other computer science conferences.</p>\n<iframe title=\"Comparison of average percentage of new authors\" src=\"new_author_perc_bar.html\" width=\"600\" height=\"600\"></iframe>\n<h3>Similarity with other conferences</h3>\n<p>Given two sets A and B, the Jaccard index J(A,B) is equal to the ratio between the cardinality of their intersection and the cardinality of their union. The Sorensen-Dice index of similarity is equal to 2J(A,B)/(1+J(A,B)). The following picture shows the Sorensen-Dice index of similarity computed by comparing the set of " * uppercase(conf_name) * " authors with the sets of authors for other computer science conferences.</p>\n<iframe title=\"Sorensen-Dice index of similarity\" src=\"similarity_values.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function sex_analysis_html(io::IOStream, conf_name::String)
    perc_sex_plot(conf_name)
    cp(path_to_files * "images/" * conf_name * "/perc_sex.html", path_to_files * "html/" * conf_name * "/perc_sex.html", force=true)
    # 
    write(io, "<a id=\"sex\"></a><h2>Sex analysis</h2>\n<p>The sex of " * uppercase(conf_name) * " authors has been determined mostly by querying the web service available at <a href=\"https://genderize.io/\"><tt>genderize.io</tt></a> (which is based on first names only), and partly by manually searching the authors on the web. The following picture shows the evolution of the percentages of male and female authors per year (the two percentages are computed with respect to the number of authors for which the sex has been assigned). The percentage of authors with no sex assigned is also shown (with respect to the total number of authors).</p>\n<iframe title=\"Evolution of the percentage of male and female authors\" src=\"perc_sex.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function topic_analysis_html(io::IOStream, conf_name::String, word_step::Int64, word_k::Int64)
    get_all_paper_titles(conf_name)
    word_cloud(conf_name)
    cp(path_to_files * "images/" * conf_name * "/wordcloud.svg", path_to_files * "html/" * conf_name * "/wordcloud.svg", force=true)
    ngram_evolution_plot(conf_name, word_step, word_k)
    cp(path_to_files * "images/" * conf_name * "/first_" * string(word_k) * "_word_evolution_step_" * string(word_step) * ".html", path_to_files * "html/" * conf_name * "/first_word_evolution_period.html", force=true)
    # 
    write(io, "<a id=\"topic\"></a><h2>Topic analysis</h2>\n<p>The following pictures shows the word cloud corresponding to the words contained in the titles of " * uppercase(conf_name) * " papers.</p>\n<img src=\"wordcloud.svg\" alt=\"Cloud of words in titles\" width=\"800\" height=\"600\">\n<p>Of all the words contained in the titles of " * uppercase(conf_name) * " papers in a certain time interval, the following picture shows what fraction of them are one of the most frequent 10 words.</p>\n<iframe title=\"Evolution of top word frequencies\" src=\"first_word_evolution_period.html\" width=\"800\" height=\"600\"></iframe>\n")
end

function graph_mining_html(io::IOStream, conf_name::String)
    nn, ne, density, lcc_perc = statistics([conf_name])
    densification_plot([conf_name], 1, conf_name * "/densification")
    cp(path_to_files * "images/" * conf_name * "/densification.html", path_to_files * "html/" * conf_name * "/densification.html", force=true)
    diameter_plot([conf_name], 1, conf_name * "/diameter")
    cp(path_to_files * "images/" * conf_name * "/diameter.html", path_to_files * "html/" * conf_name * "/diameter.html", force=true)
    degree_separation_plot([conf_name], 1, conf_name * "/degrees_separation")
    cp(path_to_files * "images/" * conf_name * "/degrees_separation.html", path_to_files * "html/" * conf_name * "/degrees_separation.html", force=true)
    # 
    write(io, "<a id=\"graphmining\"></a><h2>Graph mining</h2>\n<p>The static graph (or collaboration graph) of " * uppercase(conf_name) * " is an undirected graph whose nodes are the authors who presented at least one paper at " * uppercase(conf_name) * ", and whose edges (a1,a2) correspond to two authors a1 and a2 who co-authored at least one paper (not necessarily presented at " * uppercase(conf_name) * "). In other words, this graph is the subgraph of the DBLP graph induced by the set of " * uppercase(conf_name) * " authors (for a definition of most of the notions used in this section and in the next one and for a description of the used algorithms, we refer the interested reader to the lecture notes available at <a href=\"https://github.com/piluc/GraphMining\">https://github.com/piluc/GraphMining</a>). The static graph contains " * string(nn) * " nodes and " * string(ne) * " edges. Its density is equal to " * string(Base._round_invstep(density, 1 / 0.0001, RoundNearest)) * " and its largest connected component contains " * string(trunc(Int64, 100 * Base._round_invstep(lcc_perc, 1 / 0.01, RoundNearest))) * "% of all nodes.</p>\n<p>The following picture shows the evolution of the number of edges with respect to the number of nodes (in a log-log scale).</p>\n<iframe title=\"Densification\" src=\"densification.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the diameter of the largest connected component.</p>\n<iframe title=\"Diameter shrinking\" src=\"diameter.html\" width=\"600\" height=\"600\"></iframe>\n<p>The following picture shows the evolution over time of the average distance between two nodes in the largest connected component (that is, the degrees of separation).</p>\n<iframe title=\"Degrees of separation\" src=\"degrees_separation.html\" width=\"600\" height=\"600\"></iframe>\n")
end

function centralities_html(io::IOStream, conf_name::String, centrality_k::Int64)
    d = top_k_authors([conf_name], centrality_k)
    # 
    write(io, "<a id=\"centralities\"></a><h2>Centralities</h2>\n<p>The top-" * string(centrality_k) * " authors are the following.\n<ol>\n<li><b>Degree</b>: ")
    for a in 1:(centrality_k-1)
        write(io, d[conf_name][1][a] * ", ")
    end
    write(io, d[conf_name][1][centrality_k] * ".\n</li>\n<li><b>Closeness</b>: ")
    for a in 1:(centrality_k-1)
        write(io, d[conf_name][2][a] * ", ")
    end
    write(io, d[conf_name][2][centrality_k] * ".\n</li>\n<li><b>Betweenness</b>: ")
    for a in 1:(centrality_k-1)
        write(io, d[conf_name][3][a] * ", ")
    end
    write(io, d[conf_name][3][centrality_k] * ".\n</li>\n</ol>\n</p>\n")
end

function temporal_graph_html(io::IOStream, conf_name::String, closeness_k::Int64, harmonic_k::Int64)
    tki, tkn = top_k_closeness(conf_name, closeness_k, false)
    if (harmonic_k > closeness_k)
        harmonic_k = closeness_k
    end
    closeness_plot(conf_name, tki[1:harmonic_k], "/temporal_harmonic_closeness")
    cp(path_to_files * "images/" * conf_name * "/temporal_harmonic_closeness.html", path_to_files * "html/" * conf_name * "/temporal_harmonic_closeness.html", force=true)    # 
    write(io, "<a id=\"temporalgraph\"></a><h2>Temporal graph</h2>\n<p>The temporal graph has the same set of nodes of the static graph, but the edges (a1,a2,y) correspond to two authors a1 and a2 who co-authored in year y at least one paper (not necessarily presented at " * uppercase(conf_name) * "). The <a href=\"https://www.mdpi.com/1999-4893/13/9/211\">temporal closeness</a> is intuitively the area covered by the plot of the temporal harmonic closeness of an author. For example, in the following figure, the plot of the temporal harmonic closeness of the top-" * string(harmonic_k) * " authors with respect to the temporal closeness are shown.</p>\n<iframe title=\"Example of temporal harmonic closeness evolution\" src=\"temporal_harmonic_closeness.html\" width=\"600\" height=\"600\"></iframe>\n<p>The top-" * string(closeness_k) * " authors with respect to the temporal closeness are ")
    for a in 1:(closeness_k-1)
        write(io, tkn[a] * ", ")
    end
    write(io, tkn[closeness_k] * ".</p>\n")
end

"""
   `conf_web_page(conf_name::String, co_author_step::Int64, conf_array::Vector{String}, word_step::Int64, word_k::Int64, centrality_k::Int64, closeness_k::Int64, harmonic_k::Int64)`

Generate the default HTML page with several data- and graph-mining results. The value of `co_author_step` is used for the computation of the co-authorship size distribution. The vector `conf_array` includes the acronyms of the conferences with which a comparison has to be done. The values of `word_step` and `word_k` are used for the computation of the top words and the plot of their evolution. The values of `centrality_k` and of `closeness_k` are used for the computation of the top authors. The temporal harmonic closeness plot is produced for the top `harmonic_k` authors.
"""
function conf_web_page(conf_name::String, co_author_step::Int64, conf_array::Vector{String}, word_step::Int64, word_k::Int64, centrality_k::Int64, closeness_k::Int64, harmonic_k::Int64)
    mkpath(path_to_files * "html/" * conf_name)
    mkpath(path_to_files * "images/" * conf_name)
    cp(path_to_files * "html/cmstyle.css", path_to_files * "html/" * conf_name * "/cmstyle.css", force=true)
    cp(path_to_files * "html/pc.jpg", path_to_files * "html/" * conf_name * "/pc.jpg", force=true)
    io::IOStream = open(path_to_files * "html/" * conf_name * "/" * conf_name * ".html", "w")
    start_html(io, conf_name)
    data_mining_html(io, conf_name, co_author_step, conf_array)
    sex_analysis_html(io, conf_name)
    topic_analysis_html(io, conf_name, word_step, word_k)
    graph_mining_html(io, conf_name)
    centralities_html(io, conf_name, centrality_k)
    temporal_graph_html(io, conf_name, closeness_k, harmonic_k)
    end_html(io)
    close(io)
end