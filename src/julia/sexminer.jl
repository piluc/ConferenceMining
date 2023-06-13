"""
   `perc_sex_plot(conf_name::String, dir::String, fo::String)::String`

Generate the plots, for each year in which an edition of the conference has taken place, of the percentage of the number of male authors, the number of female authors, and the number of authors for which the sex is not specified. The first two percentages are with respect to the number of authors for which the sex is known.
"""
function perc_sex_plot(conf_name::String, dir::String, fo::String)::String
    @assert length(conf_name) > 0 "The conference name is empty"
    @assert length(fo) > 0 "The output HTML file name is empty"
    mkpath(path_to_files * "images/" * dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf_name)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25, tickformat=".2%"), yaxis_title="Percentage of authors", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Sex"))
    x_years = range(first_year, last_year, step=1)
    na, nma, nfa, nua = author_sex_evolution(conf_name)
    perc_authors = GenericTrace[]
    trace = scatter(x=x_years, y=nma ./ (na .- nua), mode="lines+markers", line_shape="spline", connectgaps=true, name="Male")
    push!(perc_authors, trace)
    trace = scatter(x=x_years, y=nfa ./ (na .- nua), mode="lines+markers", line_shape="spline", connectgaps=true, name="Female")
    push!(perc_authors, trace)
    trace = scatter(x=x_years, y=nua ./ na, mode="lines+markers", line_shape="spline", connectgaps=true, name="Not known")
    push!(perc_authors, trace)
    p = plot(perc_authors, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * dir * "/" * fo * ".html")
end

"""
   `female_male_ratio_plot(conf::Array{String}, first::Int64, dir::String, fo::String)::String`

Generate the plots, for each conference whose global acronym is in `conf` and for each year in which an edition of the conference has taken place, of the ratio of the number of female authors and the number of male authors. 
"""
function female_male_ratio_plot(conf::Array{String}, first::Int64, dir::String, fo::String)::String
    @assert length(conf) > 0 "The conference name array is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference to be plot is out of range"
    @assert length(fo) > 0 "The output HTML file name is empty"
    mkpath(path_to_files * "images/" * dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Female/male ratio", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Female/male ratio"))
    x_years = range(first_year, last_year, step=1)
    female_male_ratio = GenericTrace[]
    if (first > 0)
        _, nma, nfa, _ = author_sex_evolution(conf[first])
        to_be_plot::Array{Float64} = zeros(last_year - first_year + 1)
        fy::Int64, ly::Int64 = first_last_year(conf[first])
        i_plot::Int64 = 1
        for _ in first_year:(fy-1)
            to_be_plot[i_plot] = -1
            i_plot = i_plot + 1
        end
        for y in fy:ly
            if (nma[y-fy+1] == 0 && nfa[y-fy+1] == 0)
                to_be_plot[i_plot] = -1
            elseif (nma[y-fy+1] == 0 && nfa[y-fy+1] > 0)
                to_be_plot[i_plot] = 1
            else
                to_be_plot[i_plot] = nfa[y-fy+1] / nma[y-fy+1]
            end
            i_plot = i_plot + 1
        end
        for _ in (ly+1):last_year
            to_be_plot[i_plot] = -1
            i_plot = i_plot + 1
        end
        trace = scatter(x=x_years, y=replace(to_be_plot, -1 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=conf[first])
        push!(female_male_ratio, trace)
    end
    for c in 1:length(conf)
        if (c != first)
            _, nma, nfa, _ = author_sex_evolution(conf[c])
            to_be_plot = zeros(last_year - first_year + 1)
            fy, ly = first_last_year(conf[c])
            i_plot = 1
            for _ in first_year:(fy-1)
                to_be_plot[i_plot] = -1
                i_plot = i_plot + 1
            end
            for y in fy:ly
                if (nma[y-fy+1] == 0 && nfa[y-fy+1] == 0)
                    to_be_plot[i_plot] = -1
                elseif (nma[y-fy+1] == 0 && nfa[y-fy+1] > 0)
                    to_be_plot[i_plot] = 1
                else
                    to_be_plot[i_plot] = nfa[y-fy+1] / nma[y-fy+1]
                end
                i_plot = i_plot + 1
            end
            for _ in (ly+1):last_year
                to_be_plot[i_plot] = -1
                i_plot = i_plot + 1
            end
            trace = scatter(x=x_years, y=replace(to_be_plot, -1 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=conf[c], visible="legendonly")
            push!(female_male_ratio, trace)
        end
    end
    p = plot(female_male_ratio, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * dir * "/" * fo * ".html")
end

"""
   `female_perc_plot(conf::Array{String}, first::Int64, fo::String)::String`

Generate the plots, for each conference whose global acronym is in `conf` and for each year in which an edition of the conference has taken place, of the percentage of female authors. For example, the right part of Fig. 6 of the SIROCCO 2023 paper can be genereted as follows.

```
Miner.female_perc_plot(["crypto", "disc", "sirocco", "soda"], 0, "sirocco30", "female_perc")
```
"""
function female_perc_plot(conf::Array{String}, first::Int64, dir::String, fo::String)::String
    @assert length(conf) > 0 "The conference name array is empty"
    @assert first >= 0 && first <= length(conf) "The index of the first conference to be plot is out of range"
    @assert length(fo) > 0 "The output HTML file name is empty"
    mkpath(path_to_files * "images/" * dir)
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=900, height=plot_height, yaxis=attr(range=[0, 0.4], tickformat=".2%", showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Female percentage", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Female percentage"))
    x_years = range(first_year, last_year, step=1)
    female_perc = GenericTrace[]
    if (first > 0)
        na, nma, nfa, nua = author_sex_evolution(conf[first])
        to_be_plot::Array{Float64} = zeros(last_year - first_year + 1)
        fy::Int64, ly::Int64 = first_last_year(conf[first])
        i_plot::Int64 = 1
        for _ in first_year:(fy-1)
            to_be_plot[i_plot] = -1
            i_plot = i_plot + 1
        end
        for y in fy:ly
            if (na[y-fy+1] == 0 && nfa[y-fy+1] == 0)
                to_be_plot[i_plot] = -1
            elseif (na[y-fy+1] == 0 && nfa[y-fy+1] > 0)
                println("ERROR: female authors with no authors")
                exit(-1)
            else
                to_be_plot[i_plot] = nfa[y-fy+1] / (na[y-fy+1] - nua[y-fy+1])
            end
            i_plot = i_plot + 1
        end
        for _ in (ly+1):last_year
            to_be_plot[i_plot] = -1
            i_plot = i_plot + 1
        end
        trace = scatter(x=x_years, y=replace(to_be_plot, -1 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[first]))
        push!(female_perc, trace)
    end
    for c in 1:lastindex(conf)
        if (c != first)
            na, nma, nfa, nua = author_sex_evolution(conf[c])
            to_be_plot = zeros(last_year - first_year + 1)
            fy, ly = first_last_year(conf[c])
            i_plot = 1
            for _ in first_year:(fy-1)
                to_be_plot[i_plot] = -1
                i_plot = i_plot + 1
            end
            for y in fy:ly
                if (na[y-fy+1] == 0 && nfa[y-fy+1] == 0)
                    to_be_plot[i_plot] = -1
                elseif (na[y-fy+1] == 0 && nfa[y-fy+1] > 0)
                    println("ERROR: female authors with no authors")
                    exit(-1)
                else
                    to_be_plot[i_plot] = nfa[y-fy+1] / (na[y-fy+1] - nua[y-fy+1])
                end
                i_plot = i_plot + 1
            end
            for _ in (ly+1):last_year
                to_be_plot[i_plot] = -1
                i_plot = i_plot + 1
            end
            trace = scatter(x=x_years, y=replace(to_be_plot, -1 => NaN), mode="lines+markers", line_shape="spline", connectgaps=true, name=uppercase(conf[c]), visible="legendonly")
            push!(female_perc, trace)
        end
    end
    p = plot(female_perc, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * dir * "/" * fo * ".html")
end

"""
   `missing_sex_bar_chart(conf::Array{String}, emph::Int64, same_color::Bool, output_dir::String, output_fn::String)::String`

Generate, for each conference whose global acronym is contained in `conf`, the plot showing the percentage of authors whose sex has not been determined. For example, the left part of Fig. 6 of the SIROCCO 2023 paper can be generated as follows.

```
```
"""
function missing_sex_bar_chart(conf::Array{String}, emph::Int64, same_color::Bool, output_dir::String, output_fn::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert emph >= 0 && emph <= length(conf) "The index of the conference to be emphasized is out of range"
    @assert length(output_fn) > 0 "The HTML file name is empty"
    mkpath(path_to_files * "images/" * output_dir)
    pma::Array{Float64} = zeros(length(conf))
    for c in 1:length(conf)
        sa::Dict{String,String} = author_sex_assignment(conf[c])
        pma[c] = count(x -> sa[x] == "none", collect(keys(sa))) / length(keys(sa))
    end
    pmap::Array{Int64} = sortperm(pma)
    emph_pos::Int64 = 0
    if (emph > 0 && emph <= length(conf))
        emph_pos = findfirst(x -> x == emph, pmap)
    end
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(tickformat=".2%"), yaxis_title="Percentage of authors with no sex assigned", xaxis_title="Conference")
    x_conf::Vector{String} = []
    y_pma::Vector{Float64} = []
    for i in 1:length(conf)
        push!(x_conf, conf[pmap[i]])
        push!(y_pma, pma[pmap[i]])
    end
    color_vec = fill("blue", length(conf))
    if (emph > 0 && !same_color)
        color_vec[emph_pos] = "red"
    end
    p = plot(bar(x=x_conf, y=y_pma, marker_color=color_vec), layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * output_dir * "/" * output_fn * ".html")

end

"""
   `one_conference_sex_mining(conf_name::String, conf::Array{String})`

Invoke some functions to produce some plots relative to the conference whose acronym is `conf_name`. If the length of `conf` is greater than zero, then  the missing sex assignment plot is also produced.
"""
function one_conference_sex_mining(conf_name::String, conf::Array{String})
    @assert length(conf_name) > 0 "The conference name is empty"
    mkpath(path_to_files * "images/" * conf_name)
    perc_sex_plot(conf_name, conf_name, "sex_percs_year")
    female_perc_plot([conf_name], 1, conf_name, "female_perc")
    if (length(Miner.downloaded_conf) > 0)
        conf_index = findfirst(x -> x == conf_name, conf)
        if (conf_index === nothing)
            pushfirst!(conf, conf_name)
            conf_index = 1
        end
        female_perc_plot(conf, 0, conf_name, "female_perc")
        missing_sex_bar_chart(conf, conf_index[2], false, conf_name, "missing_sex")
    end
end
