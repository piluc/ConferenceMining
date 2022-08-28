"""
   `perc_sex_plot(conf_name::String)::String`

Generate the plots, for each year in which an edition of the conference has taken place, of the percentage of the number of male authors, the number of female authors, and the number of authors for which the sex is not specified. The first two percentages are with respect to the number of authors for which the sex is known.
"""
function perc_sex_plot(conf_name::String)::String
    @assert length(conf_name) > 0 "The conference name is empty"
    mkpath(path_to_files * "images/" * conf_name)
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
    savefig(p, path_to_files * "images/" * conf_name * "/perc_sex.html")
end

"""
   `female_male_ratio_plot(conf::Array{String}, first::Int64, fo::String)::String`

Generate the plots, for each conference whose global acronym is in `conf` and for each year in which an edition of the conference has taken place, of the ratio of the number of male authors and the number of female authors.
"""
function female_male_ratio_plot(conf::Array{String}, first::Int64, fo::String)::String
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    layout = Layout(autosize=true, width=plot_width, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, scaleratio=0.25), yaxis_title="Female/male ratio", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, range=[first_year - 1, last_year + 1], constrain="domain"), xaxis_title="Year", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Female/male ratio"))
    x_years = range(first_year, last_year, step=1)
    female_male_ratio = GenericTrace[]
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
    savefig(p, path_to_files * "images/" * conf[first] * "/" * fo * ".html")
end

"""
   `missing_sex_bar_chart(conf::Array{String}, emph::Int64, fo::String)::String`

   Generate, for each conference whose global acronym is contained in `conf`, the plot showing the percentage of authors whose sex has not been determined.
"""
function missing_sex_bar_chart(conf::Array{String}, emph::Int64, fo::String)::String
    @assert length(conf) > 0 "The conference vector is empty"
    @assert emph >= 0 && emph <= length(conf) "The index of the conference to be emphasized is out of range"
    @assert length(fo) > 0 "The HTML file name is empty"
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
    if (emph > 0)
        color_vec[emph_pos] = "red"
    end
    p = plot(bar(x=x_conf, y=y_pma, marker_color=color_vec), layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    if (emph > 0)
        mkpath(path_to_files * "images/" * conf[emph])
        savefig(p, path_to_files * "images/" * conf[emph] * "/" * fo * ".html")
    else
        mkpath(path_to_files * "images/" * conf[1])
        savefig(p, path_to_files * "images/" * conf[1] * "/" * fo * ".html")
    end
end

"""
   `one_conference_sex_mining(conf_name::String, downloaded::Bool)`

Invoke all the functions to produce all the plots relative to the conference whose acronym is `conf_name`. The Boolean flag specifies whether the conferences, which are downloaded by default by running the `ccdm.jar` Java file without arguments, have been downloaded (in that case their directories should be in the same directory of the analyzed conference directory). If this flag is `true`, then the plot the missing sex assignments is also produced.
"""
function one_conference_sex_mining(conf_name::String, downloaded::Bool)
    mkpath(path_to_files * "images/" * conf_name)
    perc_sex_plot(conf_name)
    female_male_ratio_plot([conf_name], 1, conf_name * "/female_male_ratio")
    if (downloaded)
        conf::Vector{String} = vec(downloaded_conf)
        conf_index = findfirst(x -> x == conf_name, conf)
        if (conf_index == nothing)
            pushfirst!(conf, conf_name)
            conf_index = 1
        end
        missing_sex_bar_chart(conf, conf_index, conf_name * "/missing_sex")
    end
end
