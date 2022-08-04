"""
   `paper_year_plot(conf::Array{String}, first::Int64, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of papers that have been published in the conference, for each year in which an edition of the conference has taken place.
"""
function paper_year_plot(conf::Array{String}, first::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    num_papers = GenericTrace[]
    trace = scatter(x=x_years, y=replace(papers_year(conf[first], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
    push!(num_papers, trace)
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(papers_year(conf[c], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_papers, trace)
        end
    end
    p = plot(num_papers, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `paper_growth_rate_plot(conf::Array{String}, first::Int64, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the growth rate of the number of papers that have been published in the conference, for each year in which an edition of the conference has taken place.
"""
function paper_growth_rate_plot(conf::Array{String}, first::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Growth rate of number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    num_papers = GenericTrace[]
    trace = scatter(x=x_years, y=replace(paper_growth_rate(conf[first], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
    push!(num_papers, trace)
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(paper_growth_rate(conf[c], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_papers, trace)
        end
    end
    p = plot(num_papers, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `author_year_plot(conf::Array{String}, first::Int64, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of authors that have published at least one paper in the conference, for each year in which an edition of the conference has taken place. 
"""
function author_year_plot(conf::Array{String}, first::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of authors", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    num_authors = GenericTrace[]
    trace = scatter(x=x_years, y=replace(authors_year(conf[first], first_year, last_year)[1], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
    push!(num_authors, trace)
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(authors_year(conf[c], first_year, last_year)[1], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_authors, trace)
        end
    end
    p = plot(num_authors, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `author_growth_rate_plot(conf::Array{String}, first::Int64, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the growth rate of the number of authors that have published at least one paper in the conference, for each year in which an edition of the conference has taken place.
"""
function author_growth_rate_plot(conf::Array{String}, first::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Growth rate of number of authors", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    num_papers = GenericTrace[]
    trace = scatter(x=x_years, y=replace(author_growth_rate(conf[first], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
    push!(num_papers, trace)
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(author_growth_rate(conf[c], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_papers, trace)
        end
    end
    p = plot(num_papers, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `perc_new_author_year_plot(conf::Array{String}, first::Int64, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the percentage of new authors that have published at least one paper in the conference, for each year in which an edition of the conference has taken place. The percentage is with respect to the authors that had already published at least one paper in a previous edition of the conference.
"""
function perc_new_author_year_plot(conf::Array{String}, first::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25, tickformat=".2%"), yaxis_title="Percentage of new authors", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_years = range(first_year, last_year, step=1)
    perc_new_authors = GenericTrace[]
    nay::Vector{Int64}, nnay::Vector{Int64} = authors_year(conf[first], first_year, last_year)
    pna::Vector{Float64} = percentage(nay, nnay)
    trace = scatter(x=x_years, y=replace(pna, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
    push!(perc_new_authors, trace)
    for c in 1:length(conf)
        if (c != first)
            nay, nnay = authors_year(conf[c], first_year, last_year)
            pna = percentage(nay, nnay)
            trace = scatter(x=x_years, y=replace(pna, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(perc_new_authors, trace)
        end
    end
    p = plot(perc_new_authors, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `new_author_mean_bar_chart(conf::Array{String}, emph::Int64, output_fn::String)::String`

Generate the bar chart in which, for each conference whose global acronym is contained in `conf`, the corresponding bar shows the average percentage of new authors that have published at least one paper in the conference, over all years in which an edition of the conference has taken place. 
"""
function new_author_mean_bar_chart(conf::Array{String}, emph::Int64, output_fn::String)::String
    nam::Array{Float64} = new_authors_mean(conf)
    namp::Array{Int64} = sortperm(nam)
    emph_pos::Int64 = findfirst(x -> x == emph, namp)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(tickformat=".2%"), yaxis_title="Average percentage of new authors", xaxis_title="Conference")
    x_conf::Vector{String} = []
    y_nam::Vector{Float64} = []
    for i in 1:length(conf)
        push!(x_conf, conf[namp[i]])
        push!(y_nam, nam[namp[i]])
    end
    color_vec = fill("blue", length(conf))
    if (emph > 0)
        color_vec[emph_pos] = "red"
    end
    p = plot(bar(x=x_conf, y=y_nam, marker_color=color_vec), layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `coauthorship_perc_plot(conf::Array{String}, first::Int64, output_fn::String)`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the percentage of the number of papers that have been published in the conference with a specific number of coauthors, between one and the maximum number of co-authors. The maximum number of co-authors is computed over all conferences. 
"""
function coauthorship_perc_plot(conf::Array{String}, first::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    max_nc::Int64 = 0
    for c in 1:length(conf)
        nc::Int64 = number_coauthors_distribution(conf[c], first_year, last_year, last_year - first_year + 1)[1][1]
        if (nc > max_nc)
            max_nc = nc
        end
    end
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25, tickformat=".2%"), yaxis_title="Percentage of number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[0, max_nc + 1], constrain="domain"), xaxis_title="Number of co-authors", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_nc = range(1, max_nc, step=1)
    coauthorship_dist = GenericTrace[]
    dist::Vector{Float64} = number_coauthors_distribution(conf[first], first_year, last_year, last_year - first_year + 1)[2][1] ./ number_papers(conf[first])
    trace = scatter(x=x_nc, y=replace(dist, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
    push!(coauthorship_dist, trace)
    for c in 1:length(conf)
        if (c != first)
            dist = number_coauthors_distribution(conf[c], first_year, last_year, last_year - first_year + 1)[2][1] ./ number_papers(conf[c])
            trace = scatter(x=x_nc, y=replace(dist, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(coauthorship_dist, trace)
        end
    end
    p = plot(coauthorship_dist, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end


"""
   `coauthorship_plot(conf::Array{String}, first::Int64, output_fn::String)`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of papers that have been published in the conference with a specific number of coauthors, between one and the maximum number of co-authors. The maximum number of co-authors is computed over all conferences.  
"""
function coauthorship_plot(conf::Array{String}, first::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    max_nc::Int64 = 0
    for c in 1:length(conf)
        nc::Int64 = number_coauthors_distribution(conf[c], first_year, last_year, last_year - first_year + 1)[1][1]
        if (nc > max_nc)
            max_nc = nc
        end
    end
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[0, max_nc + 1], constrain="domain"), xaxis_title="Number of co-authors", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Conference"))
    x_nc = range(1, max_nc, step=1)
    coauthorship_dist = GenericTrace[]
    dist::Vector{Float64} = number_coauthors_distribution(conf[first], first_year, last_year, last_year - first_year + 1)[2][1]
    trace = scatter(x=x_nc, y=replace(dist, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
    push!(coauthorship_dist, trace)
    for c in 1:length(conf)
        if (c != first)
            dist = number_coauthors_distribution(conf[c], first_year, last_year, last_year - first_year + 1)[2][1]
            trace = scatter(x=x_nc, y=replace(dist, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(coauthorship_dist, trace)
        end
    end
    p = plot(coauthorship_dist, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `coauthorship_plot(conf_name::String, step::Int64, output_fn::String)::String`

Generate, for the conference whose global acronym is `conf_name`, the plot showing the number of papers that have been published in the conference with a specific number of coauthors, between one and the maximum number of co-authors. The papers are grouped in periods specified by the value of `step` (that is, each period contains `step` years), and the maximum number of co-authors is computed over all years. 
"""
function coauthorship_plot(conf_name::String, step::Int64, output_fn::String)::String
    first_year::Int64, last_year::Int64 = first_last_year([conf_name])
    nc::Array{Int64} = number_coauthors_distribution(conf_name, first_year, last_year, last_year - first_year + 1)[1]
    max_nc::Int64 = maximum(nc)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[1, max_nc], constrain="domain"), xaxis_title="Number of co-authors", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Period"))
    x_nc = range(1, max_nc, step=1)
    dist::Vector{Vector{Float64}} = number_coauthors_distribution(conf_name, first_year, last_year, step)[2]
    coauthorship_dist = GenericTrace[]
    period::String = string(first_year) * "-" * string(first_year + step - 1)
    trace = scatter(x=x_nc, y=replace(dist[1], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=period, visible=true)
    push!(coauthorship_dist, trace)
    for p in 2:length(dist)
        period = string(first_year + (p - 1) * step) * "-" * string(first_year + p * step - 1)
        trace = scatter(x=x_nc, y=replace(dist[p], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=period, visible="legendonly")
        push!(coauthorship_dist, trace)
    end
    p = plot(coauthorship_dist, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `similarity_indices_plot(conf1::Array{String}, conf2::Array{String}, output_fn::String)::String`

Generate the heatmap plot showing the Sorensen-Dice similarity index, for any pair of one conference in `conf1` and one conference in `conf2`, with respect to the set of authors who published at least one paper in each of the two conferences. 
"""
function similarity_indices_plot(conf1::Array{String}, conf2::Array{String}, output_fn::String)::String
    sd::Matrix{Float64} = similarity_indices(conf2, conf1)
    layout = Layout(autosize=true, width=plot_width, height=plot_height)
    conf_name1::Vector{String} = []
    for c in 1:length(conf1)
        push!(conf_name1, conf1[c])
    end
    conf_name2::Vector{String} = []
    for c in 1:length(conf2)
        push!(conf_name2, conf2[c])
    end
    p = plot(heatmap(x=conf_name1, y=conf_name2, z=sd), layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_fn * ".html")
end

"""
   `one_conference_data_mining(conf_name::String, downloaded::Bool, co_author_step::Int64)`

Invoke all the functions to produce all the plots relative to the conference whose acronym is `conf_name`. The value of `co_author_step` is used for the computation of the co-authorship size distribution. The Boolean flag specifies whether the conferences, which are downloaded by default by running the `ccdm.jar` Java file without arguments, have been downloaded (in that case their directories should be in the same directory of the analyzed conference directory). If this flag is `true`, then the two plots concerning the average number of new authors and the similariy indices are also produced.
"""
function one_conference_data_mining(conf_name::String, downloaded::Bool, co_author_step::Int64)
    mkpath(path_to_files * "images/" * conf_name)
    paper_year_plot([conf_name], 1, conf_name * "/paper_year")
    paper_growth_rate_plot([conf_name], 1, conf_name * "/paper_growth_rate_year")
    author_year_plot([conf_name], 1, conf_name * "/auhtor_year")
    author_growth_rate_plot([conf_name], 1, conf_name * "/author_growth_rate_year")
    perc_new_author_year_plot([conf_name], 1, conf_name * "/perc_new_author_year")
    coauthorship_plot(conf_name, co_author_step, conf_name * "/co_authorship_" * string(co_author_step) * "_years")
    if (downloaded)
        conf::Vector{String} = vec(downloaded_conf)
        conf_index = findfirst(x -> x == conf_name, conf)
        if (conf_index == nothing)
            pushfirst!(conf, conf_name)
            conf_index = 1
        end
        new_author_mean_bar_chart(pushfirst!(vec(downloaded_conf), conf_name), conf_index, conf_name * "/new_author_perc_bar")
        similarity_indices_plot(vec(downloaded_conf), [conf_name], conf_name * "/similarity_values")
    end
end
