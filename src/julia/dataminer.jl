"""
   `author_stats_box_plot(conf::Array{String}, first::Int64, dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the box plot showing the quantiles of the number of authors, for each year in which an edition of the conference has taken place. The box plot is saved in the specified `output_fn` HTML file, within the subdirectory `dir` of the directory `images`.
"""
function author_stats_box_plot(conf::Array{String}, first::Int64, dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    if (first > 0)
        mkpath(path_to_files * "images/" * conf[first])
    else
        mkpath(path_to_files * "images/" * dir)
    end
    layout = Layout(autosize=true, width=2 * plot_width, height=plot_height, yaxis_title="Number of authors per year", showlegend=false)
    num_authors = GenericTrace[]
    if (first > 0)
        first_year, last_year = first_last_year(conf[first])
        trace = PlotlyJS.box(y=replace(authors_year(conf[first], first_year, last_year)[1], 0 => NaN), boxpoints=false, name=uppercase(conf[first]) * " (" * string(first_year) * ")")
        push!(num_authors, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            first_year, last_year = first_last_year(conf[c])
            trace = PlotlyJS.box(y=replace(authors_year(conf[c], first_year, last_year)[1], 0 => NaN), boxpoints=false, name=uppercase(conf[c]) * " (" * string(first_year) * ")")
            push!(num_authors, trace)
        end
    end
    p = PlotlyJS.plot(num_authors, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    if (first > 0)
        savefig(p, path_to_files * "images/" * conf[first] * "/" * output_fn * ".html")
    else
        savefig(p, path_to_files * "images/" * dir * "/" * output_fn * ".html")
    end
end

"""
   `paper_year_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of papers that have been published in the conference, for each year in which an edition of the conference has taken place. For example, Fig. 2 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.paper_year_plot(["icalp", "sirocco", "soda", "stacs"], 0, "sirocco30", "paper_year");
```
"""
function paper_year_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Paper per year"))
    x_years = range(first_year, last_year, step=1)
    num_papers = GenericTrace[]
    if (first > 0)
        trace = scatter(x=x_years, y=replace(papers_year(conf[first], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
        push!(num_papers, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(papers_year(conf[c], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_papers, trace)
        end
    end
    p = plot(num_papers, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `paper_growth_rate_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the growth rate of the number of papers that have been published in the conference, for each year in which an edition of the conference has taken place.
"""
function paper_growth_rate_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Growth rate of number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Growth rate of number of papers"))
    x_years = range(first_year, last_year, step=1)
    num_papers = GenericTrace[]
    if (first > 0)
        trace = scatter(x=x_years, y=replace(paper_growth_rate(conf[first], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
        push!(num_papers, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(paper_growth_rate(conf[c], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_papers, trace)
        end
    end
    p = plot(num_papers, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `author_year_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of authors that have published at least one paper in the conference, for each year in which an edition of the conference has taken place. 
"""
function author_year_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of authors", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Authors per year"))
    x_years = range(first_year, last_year, step=1)
    num_authors = GenericTrace[]
    if (first > 0)
        trace = scatter(x=x_years, y=replace(authors_year(conf[first], first_year, last_year)[1], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
        push!(num_authors, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(authors_year(conf[c], first_year, last_year)[1], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_authors, trace)
        end
    end
    p = plot(num_authors, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `author_growth_rate_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the growth rate of the number of authors that have published at least one paper in the conference, for each year in which an edition of the conference has taken place.
"""
function author_growth_rate_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Growth rate of number of authors", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Author number growth rate"))
    x_years = range(first_year, last_year, step=1)
    num_papers = GenericTrace[]
    if (first > 0)
        trace = scatter(x=x_years, y=replace(author_growth_rate(conf[first], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
        push!(num_papers, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(author_growth_rate(conf[c], first_year, last_year), 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_papers, trace)
        end
    end
    p = plot(num_papers, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `perc_new_author_year_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the percentage of new authors that have published at least one paper in the conference, for each year in which an edition of the conference has taken place. The percentage is with respect to the authors that had already published at least one paper in a previous edition of the conference. For example, the left part of Fig. 4 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.perc_new_author_year_plot(["cav","icalp","sirocco","soda"],0,"sirocco30","perc_new_author_year");
```
"""
function perc_new_author_year_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25, tickformat=".2%"), yaxis_title="Percentage of new authors", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Percentage of new authors per year"))
    x_years = range(first_year, last_year, step=1)
    perc_new_authors = GenericTrace[]
    if (first > 0)
        nay::Vector{Int64}, nnay::Vector{Int64} = authors_year(conf[first], first_year, last_year)
        pna::Vector{Float64} = percentage(nay, nnay)
        trace = scatter(x=x_years, y=replace(pna, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
        push!(perc_new_authors, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            nay, nnay = authors_year(conf[c], first_year, last_year)
            pna = percentage(nay, nnay)
            trace = scatter(x=x_years, y=replace(pna, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(perc_new_authors, trace)
        end
    end
    p = plot(perc_new_authors, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `new_author_mean_bar_chart(conf::Array{String}, emph::Int64, fy::Int64, ly::Int64, output_dir::String, output_fn::String)::String`

Generate the bar chart in which, for each conference whose global acronym is contained in `conf`, the corresponding bar shows the average percentage of new authors that have published at least one paper in the conference, over all years between the year `fy` and the year `ly` (if `fy` is zero, then all editions are considered). For example, the right part of Fig. 4 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.new_author_mean_bar_chart(Miner.downloaded_conf,13,2013,2022,"sirocco30","new_author_mean"); 
"""
function new_author_mean_bar_chart(conf::Array{String}, emph::Int64, fy::Int64, ly::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert emph >= 0 && emph <= length(conf) "The index of the conference to be emphasized is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    nam::Array{Float64} = zeros(length(conf))
    if (fy > 0)
        nam = new_authors_mean(conf, fy, ly)
    else
        nam = new_authors_mean(conf)
    end
    namp::Array{Int64} = sortperm(nam)
    emph_pos::Int64 = 0
    if (emph > 0)
        emph_pos = findfirst(x -> x == emph, namp)
    end
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
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `fully_new_author_mean_bar_chart(conf::Array{String}, emph::Int64, fy::Int64, ly::Int64,output_fn::String)::String`

Generate the bar chart in which, for each conference whose global acronym is contained in `conf`, the corresponding bar shows the average percentage of fully new authors that have published at least one paper in the conference, over all years between the year `fy` and the year `ly` (if `fy` is zero, then all editions are cosidered). 
"""
function fully_new_author_mean_bar_chart(conf::Array{String}, emph::Int64, fy::Int64, ly::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert emph >= 0 && emph <= length(conf) "The index of the conference to be emphasized is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    fnam::Array{Float64} = zeros(length(conf))
    if (fy > 0)
        fnam = fully_new_authors_mean(conf, fy, ly)
    else
        fnam = fully_new_authors_mean(conf)
    end
    fnamp::Array{Int64} = sortperm(fnam)
    emph_pos::Int64 = 0
    if (emph > 0)
        emph_pos = findfirst(x -> x == emph, fnamp)
    end
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(tickformat=".2%"), yaxis_title="Average percentage of fully new authors", xaxis_title="Conference")
    x_conf::Vector{String} = []
    y_fnam::Vector{Float64} = []
    for i in 1:length(conf)
        push!(x_conf, conf[fnamp[i]])
        push!(y_fnam, fnam[fnamp[i]])
    end
    color_vec = fill("blue", length(conf))
    if (emph > 0)
        color_vec[emph_pos] = "red"
    end
    p = plot(bar(x=x_conf, y=y_fnam, marker_color=color_vec), layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `fully_new_new_author_mean_bar_chart(conf::Array{String}, fy::Int64, ly::Int64, output_dir::String, output_fn::String)::String`

Generate the bar chart in which, for each conference whose global acronym is contained in `conf`, the corresponding bars show the average percentage of new and fully new authors that have published at least one paper in the conference, over all years between the year `fy` and the year `ly` (if `fy` is zero, then all editions are considered). For example, Fig. 5 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.fully_new_new_author_mean_bar_chart(Miner.downloaded_conf,2013,2022,"sirocco30","fully_new_new_author_mean");
```
"""
function fully_new_new_author_mean_bar_chart(conf::Array{String}, fy::Int64, ly::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    nam::Array{Float64} = zeros(length(conf))
    if (fy > 0)
        nam = new_authors_mean(conf, fy, ly)
    else
        nam = new_authors_mean(conf)
    end
    fnam::Array{Float64} = zeros(length(conf))
    if (fy > 0)
        fnam = fully_new_authors_mean(conf, fy, ly)
    else
        fnam = fully_new_authors_mean(conf)
    end
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(tickformat=".2%"), yaxis_title="Average percentage of fully new and new authors", xaxis_title="Conference", barmode="stack", showlegend=false)
    x_conf::Vector{String} = []
    y_nam::Vector{Float64} = []
    y_fnam::Vector{Float64} = []
    for i in 1:length(conf)
        push!(x_conf, conf[i])
        push!(y_nam, nam[i] - fnam[i])
        push!(y_fnam, fnam[i])
    end
    p = plot([bar(x=x_conf, y=y_fnam), bar(x=x_conf, y=y_nam)], layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end


"""
   `coauthorship_perc_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the percentage of the number of papers that have been published in the conference with a specific number of coauthors, between one and the maximum number of co-authors. The maximum number of co-authors is computed over all conferences. For example, the left part of Fig. 3 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.coauthorship_perc_plot(["csl","icalp","sirocco","tacas"],0,"tmp","coauthorship_perc");
```
"""
function coauthorship_perc_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    max_nc::Int64 = 0
    for c in 1:length(conf)
        nc::Int64 = number_coauthors_distribution(conf[c], first_year, last_year, last_year - first_year + 1)[1][1]
        if (nc > max_nc)
            max_nc = nc
        end
    end
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[0, 0.5], scaleratio=0.25, tickformat=".2%"), yaxis_title="Percentage of number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[0, max_nc + 1], constrain="domain"), xaxis_title="Number of co-authors", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Percentage of papers per co-authorship number"))
    x_nc = range(1, max_nc, step=1)
    coauthorship_dist = GenericTrace[]
    if (first > 0)
        dist::Vector{Float64} = number_coauthors_distribution(conf[first], first_year, last_year, last_year - first_year + 1)[2][1] ./ number_papers(conf[first])
        trace = scatter(x=x_nc, y=replace(dist, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
        push!(coauthorship_dist, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            dist = number_coauthors_distribution(conf[c], first_year, last_year, last_year - first_year + 1)[2][1] ./ number_papers(conf[c])
            trace = scatter(x=x_nc, y=replace(dist, 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(coauthorship_dist, trace)
        end
    end
    p = plot(coauthorship_dist, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end


"""
   `coauthorship_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the number of papers that have been published in the conference with a specific number of coauthors, between one and the maximum number of co-authors. The maximum number of co-authors is computed over all conferences.  
"""
function coauthorship_plot(conf::Array{String}, first::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert first > 0 && first <= length(conf) "The index of the first conference is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    max_nc::Int64 = 0
    for c in 1:length(conf)
        nc::Int64 = number_coauthors_distribution(conf[c], first_year, last_year, last_year - first_year + 1)[1][1]
        if (nc > max_nc)
            max_nc = nc
        end
    end
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[0, max_nc + 1], constrain="domain"), xaxis_title="Number of co-authors", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Number of papers per co-authorship number"))
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
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `coauthorship_plot(conf_name::String, step::Int64, output_dir::String, output_fn::String)::String`

Generate, for the conference whose global acronym is `conf_name`, the plot showing the number of papers that have been published in the conference with a specific number of coauthors, between one and the maximum number of co-authors. The papers are grouped in periods specified by the value of `step` (that is, each period contains `step` years), and the maximum number of co-authors is computed over all years. For example, the right part of Fig. 3 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.coauthorship_plot("sirocco",8,"sirocco30","coauthorship_year");
```
"""
function coauthorship_plot(conf_name::String, step::Int64, output_dir::String, output_fn::String)::String
    @assert length(conf_name) > 0 "The conference name is empty"
    first_year::Int64, last_year::Int64 = first_last_year([conf_name])
    @assert step > 0 && step <= (last_year - first_year + 1) "The length of the period is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    nc::Array{Int64} = number_coauthors_distribution(conf_name, first_year, last_year, last_year - first_year + 1)[1]
    max_nc::Int64 = maximum(nc)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Number of papers", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[1, max_nc], constrain="domain"), xaxis_title="Number of co-authors", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Period"))
    x_nc = range(1, max_nc, step=1)
    dist::Vector{Vector{Float64}} = number_coauthors_distribution(conf_name, first_year, last_year, step)[2]
    coauthorship_dist = GenericTrace[]
    period::String = string(first_year) * "-" * string(first_year + step - 1)
    trace = scatter(x=x_nc, y=replace(dist[1], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=period, visible=true)
    push!(coauthorship_dist, trace)
    for p in 2:lastindex(dist)
        period = string(first_year + (p - 1) * step) * "-" * string(first_year + p * step - 1)
        trace = scatter(x=x_nc, y=replace(dist[p], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=period, visible="legendonly")
        push!(coauthorship_dist, trace)
    end
    p = plot(coauthorship_dist, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `similarity_indices_plot(conf1::Array{String}, conf2::Array{String}, output_dir::String, output_fn::String)::String`

Generate the heatmap plot showing the Sorensen-Dice similarity index, for any pair of one conference in `conf1` and one conference in `conf2`, with respect to the set of authors who published at least one paper in each of the two conferences. For example, the heatmap shown in Fig. 1 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.similarity_indices_plot(Miner.downloaded_conf, Miner.downloaded_conf, "sirocco30", "sd_heatmap");
```
"""
function similarity_indices_plot(conf1::Array{String}, conf2::Array{String}, output_dir::String, output_fn::String)::String
    @assert length(conf1) > 0 "The first conference vector is empty"
    @assert length(conf2) > 0 "The second conference vector is empty"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
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
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")
end

"""
   `similarity_indices_plot(conf_name::String, conf::Array{String}, dir::String, output_fn::String)::String`

   For each conference whose acronym is in `conf`, generate the plot showing the evolution of the Sorensen-Dice similarity index with `conf_name`, with respect to the set of authors who published at least one paper in each of the two conferences. For example, the right part of Fig. 1 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.similarity_indices_plot("sirocco", deleteat!(copy(vec(Miner.downloaded_conf)),13), "sirocco30", "sd_plot");
```
"""
function similarity_indices_plot(conf_name::String, conf::Array{String}, dir::String, output_fn::String)::String
    @assert length(conf_name) > 0 "The reference conference is not specified"
    @assert length(conf) > 0 "The conference vector is empty"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf_name)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Sorensen-Dice index", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Sorenzen_Dice index per year"))
    x_years = range(first_year, last_year, step=1)
    num_papers = GenericTrace[]
    si = similarity_indices(conf_name, conf)
    for c in 1:length(conf)
        if (c != first)
            trace = scatter(x=x_years, y=replace(si[c, :], 0 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(num_papers, trace)
        end
    end
    p = plot(num_papers, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * dir * "/" * output_fn * ".html")
end

"""
   `author_stats(conf::Array{String})`

For each conference whose acronym is in `conf`, it produces a row of a LaTeX table containing some basic statistics of the conference. For example, Table 1 of the SIROCCO 2023 paper can be generated as follows.
```
Miner.author_stats(Miner.downloaded_conf);
```
"""
function author_stats(conf::Array{String})
    @assert length(conf) > 0 "The conference vector is empty"
    println("\\begin{tabular}{||l||r|r|r|r||r|r|r|r||}")
    println("\\cline{2-9}")
    println("\\multicolumn{1}{c||}{} & \\multicolumn{4}{c||}{Number of authors} & \\multicolumn{4}{c||}{Number of papers}\\\\")
    println("\\hline")
    println("Conference & First & Last & Minimum & Maximum & First & Last & Minimum & Maximum\\\\")
    println("\\hline")
    println("\\hline")
    for c in 1:length(conf)
        first_year, last_year = first_last_year(conf[c])
        print(uppercase(conf[c]) * " (" * string(first_year) * "-" * string(last_year) * ") & ")
        na = authors_year(conf[c], first_year, last_year)[1]
        print(string(na[1]) * " & " * string(na[length(na)]) * " & ")
        minna = typemax(Int64)
        yminna = 0
        maxna = 0
        ymaxna = 0
        for y in 1:lastindex(na)
            if (na[y] > 0)
                if (minna > na[y])
                    minna = na[y]
                    yminna = first_year + (y - 1)
                end
                if (maxna < na[y])
                    maxna = na[y]
                    ymaxna = first_year + (y - 1)
                end
            end
        end
        print(string(minna) * " (" * string(yminna) * ") & ")
        print(string(maxna) * " (" * string(ymaxna) * ") & ")
        np = papers_year(conf[c], first_year, last_year)
        print(string(np[1]) * " & " * string(np[length(np)]) * " & ")
        minnp = typemax(Int64)
        yminnp = 0
        maxnp = 0
        ymaxnp = 0
        for y in 1:lastindex(np)
            if (np[y] > 0)
                if (minnp > np[y])
                    minnp = np[y]
                    yminnp = first_year + (y - 1)
                end
                if (maxnp < np[y])
                    maxnp = np[y]
                    ymaxnp = first_year + (y - 1)
                end
            end
        end
        print(string(minnp) * " (" * string(yminnp) * ") & ")
        println(string(maxnp) * " (" * string(ymaxnp) * ")\\\\")
        println("\\hline")
    end
    println("\\hline")
    println("\\end{tabular}")
end

"""
   `one_conference_data_mining(conf_name::String, downloaded::Bool, co_author_step::Int64)`

Invoke the functions to produce some plots relative to the conference whose acronym is `conf_name`. The value of `co_author_step` is used for the computation of the co-authorship size distribution. If `conf` has length greater than zero, then the plots concerning the average number of (fully) new authors and the similariy indices are also produced. All the plots are saved in the subdirectory `conf_name` of the `images` directory included in the directory `conferencemining`.
"""
function one_conference_data_mining(conf_name::String, conf::Array{String}, co_author_step::Int64)
    fy, ly = first_last_year(conf_name)
    paper_year_plot([conf_name], 1, conf_name, "paper_year")
    paper_growth_rate_plot([conf_name], 1, conf_name, "/paper_growth_rate_year")
    author_year_plot([conf_name], 1, conf_name, "author_year")
    author_growth_rate_plot([conf_name], 1, conf_name, "/author_growth_rate_year")
    perc_new_author_year_plot([conf_name], 1, conf_name, "perc_new_author_year")
    coauthorship_plot(conf_name, co_author_step, conf_name, "co_authorship_" * string(co_author_step) * "_years")
    if (length(conf) > 0)
        similarity_indices_plot(filter(c -> c != conf_name, conf), [conf_name], conf_name, "/similarity_values")
        conf_index = findfirst(x -> x == conf_name, conf)
        if (conf_index === nothing)
            new_author_mean_bar_chart([[conf_name]; conf], 1, fy, ly, conf_name, "new_author_perc_bar")
        else
            new_author_mean_bar_chart(conf, conf_index[2], fy, ly, conf_name, "new_author_perc_bar")
        end
    end
end
