"""
   `conf_web_page(conf_name::String, co_author_step::Int64, conf_array::Vector{String}, word_step::Int64, word_k::Int64, forbidden::Vector{String}, centrality_k::Int64, closeness_k::Int64, harmonic_k::Int64)`

Generate the default HTML page with several data- and graph-mining results concerning the conference `conf_name`. The value of `co_author_step` is used for the computation of the co-authorship size distribution. The vector `conf_array` includes the acronyms of the conferences with which a comparison has to be done. The values of `word_step` and `word_k` are used for the computation of the top words and the plot of their evolution (the words in `forbidden` are discarded). The values of `centrality_k` and of `closeness_k` are used for the computation of the top authors. The temporal harmonic closeness plot is produced for the top `harmonic_k` authors.
"""
function conf_web_page(conf_name::String, co_author_step::Int64, conf_array::Vector{String}, word_step::Int64, word_k::Int64, forbidden::Vector{String}, centrality_k::Int64, closeness_k::Int64, harmonic_k::Int64)
    @assert length(conf_name) > 0 "The conference name is empty"
    @assert co_author_step > 0 "The coauthorship step is not positive"
    mkpath(path_to_files * "html/" * conf_name)
    mkpath(path_to_files * "images/" * conf_name)
    cp("res/cmstyle.css", path_to_files * "html/" * conf_name * "/cmstyle.css", force=true)
    cp("res/pc.jpg", path_to_files * "html/" * conf_name * "/pc.jpg", force=true)
    io::IOStream = open(path_to_files * "html/" * conf_name * "/" * conf_name * ".html", "w")
    start_html(io, conf_name)
    data_mining_html(io, conf_name, co_author_step, conf_array)
    sex_analysis_html(io, conf_name)
    topic_analysis_html(io, conf_name, word_step, word_k, forbidden)
    graph_mining_html(io, conf_name)
    centralities_html(io, conf_name, centrality_k)
    temporal_graph_html(io, conf_name, closeness_k, harmonic_k)
    end_html(io)
    close(io)
end

"""
   `conf_web_page(conf::Array{String}, web_page::BitVector, fy::Int64, ly::Int64, html_dir::String, title::String, sub_title::String, co_author_step::Int64)`

Generate a comparative analysis web page of the conferences in `conf` (by using `title` and `sub_title` for the title and the sub-title of the page): the web page is saved in the directory `html_dir`. The vector `web_page` of Boolean values specifies whether the web page of each conference is available. The two values `fy` and `ly` specify the time interval for the computation of fully new and new authors.
"""
function conf_web_page(conf::Array{String}, web_page::BitVector, fy::Int64, ly::Int64, html_dir::String, title::String, sub_title::String)
    mkpath(path_to_files * "html/" * html_dir)
    cp("res/cmstyle.css", path_to_files * "html/" * html_dir * "/cmstyle.css", force=true)
    cp("res/pc.jpg", path_to_files * "html/" * html_dir * "/pc.jpg", force=true)
    io::IOStream = open(path_to_files * "html/" * html_dir * "/index.html", "w")
    start_html(io, conf, web_page, title, sub_title)
    data_mining_html(io, conf, fy, ly, html_dir)
    sex_analysis_html(io, conf, html_dir)
    graph_mining_html(io, conf, html_dir)
    centralities_html(io, conf)
    temporal_graph_html(io, conf)
    end_html(io)
    close(io)
end
