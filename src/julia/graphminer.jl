"""
   `statistics(conf::Array{String})::Tuple{Int64, Int64, Float64, Float64}`

Return the number of nodes, the number of edges, the density, and the realtive size of the largest connected component of the static graph, for each conference in `conf`.
"""
function statistics(conf::Array{String})::Tuple{Int64,Int64,Float64,Float64}
    for conf_name in conf
        n::Int64 = number_authors(conf_name)
        fn::String = path_to_files * "conferences/" * conf_name * "/" * "static_graph.txt"
        g::SimpleGraph{Int64} = read_static_graph(fn, n)
        cc::Array{Array{Int64}} = connected_components(g)
        lcc_index::Int64 = argmax(length.(cc))
        lcc::Array{Int64} = cc[lcc_index]
        lcc_size::Int64 = length(lcc)
        return n, ne(g), (2 * ne(g)) / (n * (n - 1)), lcc_size / n
    end
end

"""
   `densification_plot(conf::Array{String}, first::Int64, fo::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of edges and the the number of nodes in a log-log scale, for each year in which an edition of at least one conference in `conf` has taken place.
"""
function densification_plot(conf::Array{String}, first::Int64, fo::String)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(type="log", showline=true, linewidth=2, linecolor="black", mirror=true, range=[1, 4], scaleratio=1), yaxis_title="Number of edges", xaxis=attr(type="log", showline=true, linewidth=2, linecolor="black", mirror=true, range=[1, 4], constrain="domain"), xaxis_title="Number of nodes", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    densification = GenericTrace[]
    println("Analysing ", conf[first])
    nn::Vector{Int64}, ne::Vector{Int64}, _, _ = graph_evolution(conf[first], first_year, last_year)
    trace = scatter(x=nn, y=ne, mode="lines+markers", line_shape="spline", name=conf[first])
    push!(densification, trace)
    for c in 1:length(conf)
        if (c != first)
            println("Analysing ", conf[c])
            nn, ne, _, _ = graph_evolution(conf[c], first_year, last_year)
            trace = scatter(x=nn, y=ne, mode="lines+markers", line_shape="spline", name=conf[c], visible="legendonly")
            push!(densification, trace)
        end
    end
    p = plot(densification, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * fo * ".html")
end

"""
   `diameter_plot(conf::Array{String}, first::Int64, fo::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the diameter, for each year in which an edition of at least one conference in `conf` has taken place.
"""
function diameter_plot(conf::Array{String}, first::Int64, fo::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Diameter", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    diameter = GenericTrace[]
    println("Analysing ", conf[first])
    _, _, _, d = graph_evolution(conf[first], first_year, last_year)
    trace = scatter(x=x_years, y=d, mode="lines+markers", line_shape="spline", name=conf[first])
    push!(diameter, trace)
    for c in 1:length(conf)
        if (c != first)
            println("Analysing ", conf[c])
            _, _, _, d = graph_evolution(conf[c], first_year, last_year)
            trace = scatter(x=x_years, y=d, mode="lines+markers", line_shape="spline", name=conf[c], visible="legendonly")
            push!(diameter, trace)
        end
    end
    p = plot(diameter, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * fo * ".html")
end

"""
   `degree_separation_plot(conf::Array{String}, first::Int64, fo::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the average distance between two nodes (also called degrees of separation), for each year in which an edition of at least one conference in `conf` has taken place.
"""
function degree_separation_plot(conf::Array{String}, first::Int64, fo::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Average distance", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    degree_separation = GenericTrace[]
    println("Analysing ", conf[first])
    _, _, ds, _ = graph_evolution(conf[first], first_year, last_year)
    trace = scatter(x=x_years, y=ds, mode="lines+markers", line_shape="spline", name=conf[first])
    push!(degree_separation, trace)
    for c in 1:length(conf)
        if (c != first)
            println("Analysing ", conf[c])
            _, _, ds, _ = graph_evolution(conf[c], first_year, last_year)
            trace = scatter(x=x_years, y=ds, mode="lines+markers", line_shape="spline", name=conf[c], visible="legendonly")
            push!(degree_separation, trace)
        end
    end
    p = plot(degree_separation, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * fo * ".html")
end

"""
   `top_k_authors(conf::Array{String}, k::Int64)::Dict{String,Vector{Vector{String}}}`

Return a dictionary that, for each conference in `conf`, has as value the vectors containing the names of the top-k authors with respect to the degree, the closeness, and the betwenness, respectively.
"""
function top_k_authors(conf::Array{String}, k::Int64)::Dict{String,Vector{Vector{String}}}
    top_k_name::Dict{String,Vector{Vector{String}}} = Dict{String,Vector{Vector{String}}}()
    for c in 1:length(conf)
        println("Analysing ", conf[c])
        id_name::Dict{Int64,String} = Dict{Int64,String}()
        fn::String = path_to_files * "conferences/" * conf[c] * "/" * "id_name_key.txt"
        for line in eachline(fn)
            split_line::Vector{String} = split(line, "##")
            id::Int64 = parse(Int64, split_line[2])
            id_name[id] = split_line[4]
        end
        top_k_id = top_k_authors(conf[c], k)
        top_k_name[conf[c]] = []
        for m in 1:length(top_k_id)
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
   `closeness_plot(conf_name::String, author::Array{Int64}, fo::String)`

Generate, for each author whose index is contained in `author`, the plot showing the evolution of its temporal harmonic closeness in the temporal graph associated with `conf_name`.
"""
function closeness_plot(conf_name::String, author::Array{Int64}, fo::String)
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
    c = closeness_evolution(conf_name, author[1])
    trace = scatter(x=x_years, y=c, mode="lines+markers", line_shape="spline", name=id_name[author[1]])
    push!(closeness_plotly, trace)
    for a in 2:length(author)
        c = closeness_evolution(conf_name, author[a])
        trace = scatter(x=x_years, y=c, mode="lines+markers", line_shape="spline", name=id_name[author[a]], visible="legendonly")
        push!(closeness_plotly, trace)
    end
    plot_buttons_to_remove = ["zoom", "pan", "select2d", "lasso2d", "zoomIn2d", "zoomOut2d", "resetScale2d"]
    p = plot(closeness_plotly, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=true))
    savefig(p, path_to_files * "images/" * conf_name * "/" * fo * ".html")
end

"""
   `top_k_closeness(conf_name::String, k::Int64, verbose::Bool)::Tuple{Array{Int64}, Vector{String}}`

Print the the top-k authors of the conference `conf_name` with respect to the temporal closeness.
"""
function top_k_closeness(conf_name::String, k::Int64, verbose::Bool)::Tuple{Array{Int64},Vector{String}}
    id_name::Dict{Int64,String}, c::Array{Float64} = closeness(conf_name, verbose)
    top_k_indices::Array{Int64} = sortperm(c, rev=true)[1:k]
    top_k_names::Vector{String} = []
    for a in 1:k
        push!(top_k_names, id_name[top_k_indices[a]])
    end
    return top_k_indices, top_k_names
end


"""
   `one_conference_graph_mining(conf_name::String, k::Int64)`

Invoke all the functions to produce all the plots relative to the conference whose acronym is `conf_name`. The value of `k` is used for the computation of the top-k authors. The temporal harmonic closeness plot is produced for the top two authors.
"""
function one_conference_graph_mining(conf_name::String, k::Int64)
    mkpath(path_to_files * "images/" * conf_name)
    nn, ne, density, lcc_perc = statistics([conf_name])
    println(conf_name, " ", nn, " ", ne, " ", Base._round_invstep(density, 1 / 0.0001, RoundNearest), " ", Base._round_invstep(lcc_perc, 1 / 0.01, RoundNearest))
    densification_plot([conf_name], 1, conf_name * "/densification")
    diameter_plot([conf_name], 1, conf_name * "/diameter")
    degree_separation_plot([conf_name], 1, conf_name * "/degrees_separation")
    d = top_k_authors([conf_name], k)
    println("Degre")
    println(d[conf_name][1])
    println("Closeness")
    println(d[conf_name][2])
    println("Betweeness")
    println(d[conf_name][3])
    tki, tkn = top_k_closeness(conf_name, k, false)
    closeness_plot(conf_name, tki[1:2], "/temporal_harmonic_closeness")
    println(tkn)
end