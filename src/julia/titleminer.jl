"""
   `word_cloud(conf_name::String)`

   Generate the wordcloud of the words included in the titles of all the papers published in one edition of the conference (the image is saved into a SVG file).
"""
function word_cloud(conf_name::String)
    wc = wordcloud(
        processtext(open(path_to_files * "titles/" * conf_name * "/all_paper_titles.txt"), stopwords=WordCloud.stopwords_en, maxweight=1, maxnum=300),
        mask=WordCloud.shape(ellipse, 800, 600, color=(0.98, 0.97, 0.99)),
        colors=:plasma,
        angles=-90:90
    )
    paint(wc, path_to_files * "images/" * conf_name * "/wordcloud.svg")
end

"""
   `area_word_cloud(area::String)`

   Generate the wordcloud of the words included in the titles of all the papers published in one edition of a conference of the specified area (the image is aved into a SVG file).
"""
function area_word_cloud(area::String)
    wc = wordcloud(
        processtext(open(path_to_files * "titles/areas/" * area * "/all_paper_titles.txt"), stopwords=WordCloud.stopwords_en, maxweight=1, maxnum=300),
        mask=WordCloud.shape(ellipse, 800, 600, color=(0.98, 0.97, 0.99)),
        colors=:plasma,
        angles=-90:90
    )
    mkpath(path_to_files * "images/areas/" * area)
    paint(wc, path_to_files * "images/areas/" * area * "/wordcloud.svg")
end

"""
   `ngram_evolution_plot(conf_name::String, y_step::Int64, k::Int64, forbidden::Vector{String})::String`
   `ngram_evolution_plot(conf_name::String, y_step::Int64, k::Int64, first_year::Int64, last_year::Int64, forbidden::Vector{String})::String`

Generate the plot showing, for each of the `k` most popular words its evolution, that is, of all the words contained in the titles of the conference papers in a certain interval, what percentage of them are the examined word. If the `first_year` and `last_year` argument are specified, then only the papers in the corresponding interval are considered. The words in `forbidden` are discarded.
"""
function ngram_evolution_plot(conf_name::String, y_step::Int64, k::Int64, forbidden::Vector{String})::String
    first_year::Int64, last_year::Int64 = first_last_year(conf_name)
    ngram_evolution_plot(conf_name, y_step, k, first_year, last_year, forbidden)
end

function ngram_evolution_plot(conf_name::String, y_step::Int64, k::Int64, first_year::Int64, last_year::Int64, forbidden::Vector{String})::String
    words_to_be_searched::Vector{String}, frequencies::Vector{Int64} = conf_word_frequencies(conf_name, k, forbidden)
    first_word::String = words_to_be_searched[findmax(frequencies)[2]]
    sort!(words_to_be_searched)
    ngram_number::Vector{Int64}, d::Dict{String,Vector{Int64}} = word_evolution(conf_name, y_step, k, forbidden)
    layout = Layout(autosize=true, width=800, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true), yaxis_title="Fraction", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, constrain="domain"), xaxis_title="Interval", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Words"), hovermode="x unified")
    x_ni::Vector{String} = []
    for y in first_year:y_step:last_year
        push!(x_ni, string(y) * "-" * string(y + y_step - 1))
    end
    ngram_evol = GenericTrace[]
    for w in 1:length(words_to_be_searched)
        if (words_to_be_searched[w] != first_word)
            trace = scatter(x=x_ni, y=(d[words_to_be_searched[w]] ./ ngram_number), mode="lines+markers", line_shape="spline", name=words_to_be_searched[w], visible="legendonly")
            push!(ngram_evol, trace)
        else
            trace = scatter(x=x_ni, y=(d[first_word] ./ ngram_number), mode="lines+markers", line_shape="spline", name=first_word)
            push!(ngram_evol, trace)
        end
    end
    p = plot(ngram_evol, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * conf_name * "/first_" * string(k) * "_word_evolution_step_" * string(y_step) * ".html")
end

"""
   `ngram_evolution_plot(conf_name::String, y_step::Int64, words_to_be_searched::Vector{String}, forbidden::Vector{String})::String`
   `ngram_evolution_plot(conf_name::String, y_step::Int64, first_year::Int64, last_year::Int64, words_to_be_searched::Vector{String}, forbidden::Vector{String})::String`

Generate the plot showing, for each of the words to be searched, its evolution, that is, of all the words contained in the titles of the conference papers in a certain interval, what percentage of them are the examined word. If the `first_year` and `last_year` argument are specified, then only the papers in the corresponding interval are considered. The words in `forbidden` are discarded.
"""
function ngram_evolution_plot(conf_name::String, y_step::Int64, words_to_be_searched::Vector{String}, forbidden::Vector{String})::String
    first_year::Int64, last_year::Int64 = first_last_year(conf_name)
    ngram_evolution_plot(conf_name, y_step, first_year, last_year, words_to_be_searched, forbidden)
end

function ngram_evolution_plot(conf_name::String, y_step::Int64, first_year::Int64, last_year::Int64, words_to_be_searched::Vector{String}, forbidden::Vector{String})::String
    first_word::String = words_to_be_searched[1]
    ngram_number::Vector{Int64}, d::Dict{String,Vector{Int64}} = word_evolution(conf_name, y_step, 0, forbidden)
    layout = Layout(autosize=true, width=800, height=plot_height, yaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true), yaxis_title="Fraction", xaxis=attr(showline=true, linewidth=2, linecolor="black", mirror=true, constrain="domain"), xaxis_title="Interval", legend=attr(x=1, xanchor="right", y=1.02, yanchor="bottom", orientation="h", title="Words"), hovermode="x unified")
    x_ni::Vector{String} = []
    for y in first_year:y_step:last_year
        push!(x_ni, string(y) * "-" * string(y + y_step - 1))
    end
    ngram_evol = GenericTrace[]
    for w in 1:length(words_to_be_searched)
        if (words_to_be_searched[w] != first_word)
            trace = scatter(x=x_ni, y=(d[words_to_be_searched[w]] ./ ngram_number), mode="lines+markers", line_shape="spline", name=words_to_be_searched[w], visible="legendonly")
            push!(ngram_evol, trace)
        else
            trace = scatter(x=x_ni, y=(d[first_word] ./ ngram_number), mode="lines+markers", line_shape="spline", name=first_word)
            push!(ngram_evol, trace)
        end
    end
    p = plot(ngram_evol, layout, config=PlotConfig(modeBarButtonsToRemove=plot_buttons_to_remove, displaylogo=plot_logo))
    savefig(p, path_to_files * "images/" * conf_name * "/selected_word_evolution_step_" * string(y_step) * ".html")
end

"""
   `one_conference_title_mining(conf_name::String, step::Int64, k::Int64, forbidden::Vector{String})`

Invoke all the functions to produce all the plots relative to the conference whose acronym is `conf_name`. The values of `step` and `k` are used for the computation of the top-k words and the plot of their evolution (the words in `forbidden` are discarded).
"""
function one_conference_title_mining(conf_name::String, step::Int64, k::Int64, forbidden::Vector{String})
    mkpath(path_to_files * "images/" * conf_name)
    get_all_paper_titles(conf_name)
    word_cloud(conf_name)
    ngram_evolution_plot(conf_name, step, k, forbidden)
end