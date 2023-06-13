"""
   `graph_statistics(conf::Array{String})::Vector{Tuple{String,Int64,Int64,Int64,Int64,Float64,Float64,TGStats}}`

Return the number of nodes, the number of edges, the density, the realtive size of the largest connected component of the static graph, and the statistics of the temporal graph, for each conference in `conf`.
"""
function graph_statistics(conf::Array{String})::Vector{Tuple{String,Int64,Int64,Int64,Int64,Float64,Float64,TGStats}}
    @assert length(conf) > 0 "The array of conferences is empty"
    stats::Vector{Tuple{String,Int64,Int64,Int64,Int64,Float64,Float64,TGStats}} = []
    for conf_name in conf
        fy::Int64, ly::Int64 = first_last_year(conf_name)
        n::Int64 = number_authors(conf_name)
        fn::String = path_to_files * "conferences/" * conf_name * "/" * "static_graph.txt"
        g::SimpleGraph{Int64} = read_static_graph(fn, n)
        cc::Array{Array{Int64}} = connected_components(g)
        lcc_index::Int64 = argmax(length.(cc))
        lcc::Array{Int64} = cc[lcc_index]
        lcc_size::Int64 = length(lcc)
        tg_stats::TGStats = get_stats(conf_name)
        push!(stats, (conf_name, fy, ly, n, ne(g), (2 * ne(g)) / (n * (n - 1)), lcc_size / n, tg_stats))
    end
    return stats
end

"""
   `print_graph_stats(conf::Array{String})`

Produce the LaTeX table of the data returned by the `statistics` function. For example, Table 2 of the SIROCCO 2023 paper (apart from the last column) can be produced as follows.

```
Miner.print_graph_stats(Miner.downloaded_conf);
```
"""
function print_graph_stats(conf::Array{String})
    @assert length(conf) > 0 "The array of conferences is empty"
    print("\\begin{tabular}{||l||r|r|r||r|r||}\n\\hline\n Conference & \\#\\ nodes & \\#\\ edges & \\#\\ temporal edges & Density & LCC size\\\\\n\\hline\n\\hline\n")
    stats = graph_statistics(conf)
    for c in 1:lastindex(conf)
        println(uppercase(conf[c]), " & ", stats[c][4], " & ", stats[c][5], " & ", stats[c][8].m, " & ", Base._round_invstep(stats[c][6], 1 / 0.0001, RoundNearest), " & ", Base._round_invstep(stats[c][7], 1 / 0.01, RoundNearest), "\\\\")
        println("\\hline")
    end
    print("\\hline\n\\end{tabular}")
end

"""
   `densification_log_log_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of edges and the the number of nodes in a log-log scale, for each year in which an edition of at least one conference in `conf` has taken place.
"""
function densification_log_log_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(type="log", showline=true, linewidth=2, linecolor="black", mirror=true, range=[1, 4], scaleratio=1), yaxis_title="Number of edges", xaxis=attr(type="log", showline=true, linewidth=2, linecolor="black", mirror=true, range=[1, 4], constrain="domain"), xaxis_title="Number of nodes", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    densification = GenericTrace[]
    if (first > 0)
        println("Computing densification of ", conf[first])
        nn::Vector{Int64}, ne::Vector{Int64}, _, _, _ = graph_evolution(conf[first], first_year, last_year)
        trace = scatter(x=nn, y=ne, mode="lines+markers", line_shape="spline", name=conf[first])
        push!(densification, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            println("Computing densification of ", conf[c])
            nn, ne, _, _, _ = graph_evolution(conf[c], first_year, last_year)
            trace = scatter(x=nn, y=ne, mode="lines+markers", line_shape="spline", name=conf[c], visible="legendonly")
            push!(densification, trace)
        end
    end
    p = plot(densification, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `diameter_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String, effective::Bool)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the (effective) diameter, for each year in which an edition of at least one conference in `conf` has taken place. For example, the left part of Fig. 7 of the SIROCCO 2023 paper can be generated as follows.

```
Miner.diameter_plot(["disc", "esa", "podc", "sirocco"], 0, "sirocco30", "diameter", false)
```
"""
function diameter_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String, effective::Bool)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Diameter", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    diameter = GenericTrace[]
    if (first > 0)
        println("Computing (effective) diameter evolution of ", conf[first])
        _, _, _, d, ed = graph_evolution(conf[first], first_year, last_year)
        if (effective)
            trace = scatter(x=x_years, y=ed, mode="lines+markers", line_shape="spline", name=conf[first])
        else
            trace = scatter(x=x_years, y=d, mode="lines+markers", line_shape="spline", name=conf[first])
        end
        push!(diameter, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            println("Computing (effective) diameter evolution of ", conf[c])
            _, _, _, d, ed = graph_evolution(conf[c], first_year, last_year)
            if (effective)
                trace = scatter(x=x_years, y=ed, mode="lines+markers", line_shape="spline", name=conf[c], visible="legendonly")
            else
                trace = scatter(x=x_years, y=d, mode="lines+markers", line_shape="spline", name=conf[c], visible="legendonly")
            end
            push!(diameter, trace)
        end
    end
    p = plot(diameter, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `degree_separation_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the average distance between two nodes (also called degrees of separation), for each year in which an edition of at least one conference in `conf` has taken place. For example, the left part of Fig. 7 of the SIROCCO 2023 paper can be generated as follows.

```
Miner.degree_separation_plot(["disc", "esa", "podc", "sirocco"], 0, "sirocco30", "diameter")
```
"""
function degree_separation_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Average distance", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    degree_separation = GenericTrace[]
    if (first > 0)
        println("Computing average distance evolution of ", conf[first])
        _, _, ds, _, _ = graph_evolution(conf[first], first_year, last_year)
        trace = scatter(x=x_years, y=ds, mode="lines+markers", line_shape="spline", name=conf[first])
        push!(degree_separation, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            println("Computing average distance evolution of ", conf[c])
            _, _, ds, _, _ = graph_evolution(conf[c], first_year, last_year)
            trace = scatter(x=x_years, y=ds, mode="lines+markers", line_shape="spline", name=conf[c], visible="legendonly")
            push!(degree_separation, trace)
        end
    end
    p = plot(degree_separation, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `top_k_authors(conf::Array{String}, k::Int64)::Dict{String,Vector{Vector{String}}}`

Return a dictionary that, for each conference in `conf`, has as value the vectors containing the names of the top-k authors with respect to the degree, the closeness, and the betwenness, respectively.
"""
function top_k_authors(conf::Array{String}, k::Int64)::Dict{String,Vector{Vector{String}}}
    @assert length(conf) > 0 "The conference vector is empty"
    @assert k > 0 && k <= 100 "The number of topo authors is out of range"
    top_k_name::Dict{String,Vector{Vector{String}}} = Dict{String,Vector{Vector{String}}}()
    for c in 1:length(conf)
        println("Computing centrality measures of ", conf[c])
        id_name::Dict{Int64,String} = Dict{Int64,String}()
        fn::String = path_to_files * "conferences/" * conf[c] * "/" * "id_name_key.txt"
        for line in eachline(fn)
            split_line::Vector{String} = split(line, "##")
            id::Int64 = parse(Int64, split_line[2])
            id_name[id] = split_line[4]
        end
        top_k_id = top_k_authors(conf[c], k)
        top_k_name[conf[c]] = []
        for m in 1:lastindex(top_k_id)
            top_name::Array{String} = Array{String}(undef, k)
            for a in 1:k
                top_name[a] = id_name[top_k_id[m][a]]
            end
            push!(top_k_name[conf[c]], top_name)
        end
    end
    return top_k_name
end

"""
   `temporal_closeness_plot(conf_name::String, author::Array{Int64}, first::Int64, dir::String, fo::String)`

Generate, for each author whose index is contained in `author`, the plot showing the evolution of its temporal harmonic closeness in the temporal graph associated with `conf_name`.
"""
function temporal_closeness_plot(conf_name::String, author::Array{Int64}, first::Int64, dir::String, fo::String)
    @assert length(author) > 0 "The author vector is empty"
    stats::TGStats = get_stats(conf_name)
    id_name::Dict{Int64,String} = Dict{Int64,String}()
    fn::String = path_to_files * "conferences/" * conf_name * "/id_name_key.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        id::Int64 = parse(Int64, split_line[2])
        id_name[id] = split_line[4]
    end
    layout = Layout(autosize=true, width=600, height=600, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Temporal (harmonic) closeness", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[stats.t_alpha - 1, stats.t_omega + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Author"))
    x_years = range(stats.t_alpha, stats.t_omega, step=1)
    closeness_plotly = GenericTrace[]
    if (first > 0)
        c = closeness_evolution(conf_name, author[first])
        trace = scatter(x=x_years, y=c, mode="lines+markers", line_shape="spline", name=id_name[author[first]])
        push!(closeness_plotly, trace)
    end
    for a in 1:lastindex(author)
        if (a != first)
            c = closeness_evolution(conf_name, author[a])
            trace = scatter(x=x_years, y=c, mode="lines+markers", line_shape="spline", name=id_name[author[a]], visible="legendonly")
            push!(closeness_plotly, trace)
        end
    end
    plot_buttons_to_remove = ["zoom", "pan", "select2d", "lasso2d", "zoomIn2d", "zoomOut2d", "resetScale2d"]
    p = plot(closeness_plotly, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=true))
    savefig(p, path_to_files * "images/" * dir * "/" * fo * ".html")
end

"""
   `top_k_temporal_closeness(conf_name::String, k::Int64, verbose::Bool)::Tuple{Array{Int64}, Vector{String}}`

Print the the top-k authors of the conference `conf_name` with respect to the temporal closeness.
"""
function top_k_temporal_closeness(conf_name::String, k::Int64, verbose::Bool)::Tuple{Array{Int64},Vector{String}}
    @assert k > 0 "The number of authors to be returned is not positive"
    println("Computing temporal closeness of ", conf_name)
    id_name::Dict{Int64,String}, c::Array{Float64} = closeness(conf_name, verbose)
    top_k_indices::Array{Int64} = sortperm(c, rev=true)[1:k]
    top_k_names::Vector{String} = []
    for a in 1:k
        push!(top_k_names, id_name[top_k_indices[a]])
    end
    return top_k_indices, top_k_names
end

"""
   `temporal_closeness_distances(conf::Array{String}, k::Int64)::Matrix{Float64}`

Compute the intersection between the sets of the top-k nodes with respect to the temporal closeness. For example, Table 3 of the SIROCCO 2023 paper can be generated by using the result of the following instruction.

```
inter = Miner.temporal_closeness_distances(Miner.downloaded_conf, 50);
```
"""
function temporal_closeness_distances(conf::Array{String}, k::Int64)::Matrix{Float64}
    @assert length(conf) > 0 "The conference array is empty"
    @assert k > 0 "The number of authors to be analysed is not positive"
    dist::Matrix{Float64} = zeros(length(conf), length(conf))
    tknm::Array{Set{String}} = Array{Set{String}}(undef, length(conf))
    for c in 1:lastindex(conf)
        _, tkn = top_k_temporal_closeness(conf[c], k, false)
        tknm[c] = Set{String}(tkn)
    end
    for c1 in 1:lastindex(conf)
        for c2 in (c1+1):lastindex(conf)
            dist[c1, c2] = length(intersect(tknm[c1], tknm[c2]))
        end
    end
    return dist
end


"""
   `one_conference_graph_mining(conf_name::String, k::Int64)`

Invoke some functions to produce some plots relative to the conference whose acronym is `conf_name`. The value of `k` is used for the computation of the top-k authors. The temporal harmonic closeness plot is produced for the top two authors.
"""
function one_conference_graph_mining(conf_name::String, k::Int64)
    @assert k > 0 "The number of authors to be returned is not positive"
    mkpath(path_to_files * "images/" * conf_name)
    fy, ly = first_last_year(conf_name)
    nn, ne, density, lcc_perc = graph_statistics([conf_name])[1]
    println(conf_name, " ", nn, " ", ne, " ", Base._round_invstep(density, 1 / 0.0001, RoundNearest), " ", Base._round_invstep(lcc_perc, 1 / 0.01, RoundNearest))
    densification_log_log_plot([conf_name], 1, conf_name, "/densification")
    diameter_plot([conf_name], 1, conf_name, "/diameter", false)
    diameter_plot([conf_name], 1, conf_name, "/effective_diameter", true)
    degree_separation_plot([conf_name], 1, conf_name, "/degrees_separation")
    d = top_k_authors([conf_name], k)
    println("Degre")
    println(d[conf_name][1])
    println("Closeness")
    println(d[conf_name][2])
    println("Betweeness")
    println(d[conf_name][3])
    tki, tkn = top_k_temporal_closeness(conf_name, k, false)
    temporal_closeness_plot(conf_name, tki[1:2], 0, conf_name, "/temporal_harmonic_closeness")
    println(tkn)
end
