#####################################################
# TITLE MINER
#####################################################
"""
   `get_all_paper_titles(conf_name::String)`

Collect the titles of all the papers presented at the conference and save them (in loer case) into the file `all_paper_titles.txt` in the directory `conf_name` included in the directory `titles`. 
"""
function get_all_paper_titles(conf_name::String)
    mkpath(path_to_files * "titles/" * conf_name)
    first_year::Int64, last_year::Int64 = first_last_year(conf_name)
    open(path_to_files * "titles/" * conf_name * "/all_paper_titles.txt", "w") do f
        for y in first_year:last_year
            fn::String = path_to_files * "conferences/" * conf_name * "/papers/paper_titles_" * string(y) * ".txt"
            if isfile(fn)
                for l in readlines(fn)
                    write(f, lowercase(l) * "\n")
                end
            end
        end
    end
end

"""
   `get_all_paper_titles(conf::Array{String})`

Invoke the `get_all_paper_titles` for each conference whose acronym is in `conf`. 
"""
function get_all_paper_titles(conf::Array{String})
    for c in conf
        get_all_paper_titles(c)
    end
end

"""
   `merge_paper_titles(conf::Array{String}, area::String)`

Merge the paper tile files of the conferences in `conf` into a unique file inside the subdirectory `<area>` of the directory `areas` included in the directory `titles`.  
"""
function merge_paper_titles(conf::Array{String}, area::String)
    mkpath(path_to_files * "titles/areas/" * area)
    open(path_to_files * "titles/areas/" * area * "/all_paper_titles.txt", "w") do f
        for c in conf
            fn::String = path_to_files * "titles/" * c * "/all_paper_titles.txt"
            for l in readlines(fn)
                write(f, l * "\n")
            end
        end
    end
end

"""
   `ngram_frequencies(sd::StringDocument)::Dict{String,Int64}`

Return the dictionary with keys the ngrams (that is, words) and values their frequencies of the specified string document (see the documentation of the `TextAnalysis` package).
"""
function ngram_frequencies(sd::StringDocument)::Dict{String,Int64}
    remove_words!(sd, ["via"])
    remove_case!(sd)
    prepare!(sd, strip_punctuation)
    prepare!(sd, strip_stopwords)
    prepare!(sd, strip_articles)
    prepare!(sd, strip_definite_articles)
    prepare!(sd, strip_indefinite_articles)
    prepare!(sd, strip_prepositions)
    return ngrams(sd)
end

"""
   `top_k_dict_words(d::Dict{String,Int64}, k::Int64, forbidden::Vector{String})::Tuple{Vector{String},Vector{Int64}}`

Return two vectors with the top-k words and with their frequencies, respectively, among the words included in the dictionary with keys the words and values their frequencies (the words in `forbidden` are discarded).
"""
function top_k_dict_words(d::Dict{String,Int64}, k::Int64, forbidden::Vector{String})::Tuple{Vector{String},Vector{Int64}}
    top_frequency::Vector{Int64} = []
    top_word::Vector{String} = []
    for ngram in keys(d)
        if (!in(ngram, forbidden))
            f::Int64 = d[ngram]
            if (length(top_frequency) < k)
                push!(top_word, ngram)
                push!(top_frequency, f)
            elseif (top_frequency[length(top_frequency)] < f)
                top_frequency[length(top_frequency)] = f
                top_word[length(top_frequency)] = ngram
            end
            j::Int64 = length(top_frequency) - 1
            while (j > 0)
                if (top_frequency[j] < f)
                    top_frequency[j+1] = top_frequency[j]
                    top_word[j+1] = top_word[j]
                    top_frequency[j] = f
                    top_word[j] = ngram
                    j = j - 1
                else
                    j = 0
                end
            end
        end
    end
    return top_word, top_frequency
end

"""
   `singularized_word_dict(d::Dict{String,Int64})::Dict{String,Int64}`

Return the dictionary with keys the words and values their frequencies, where the words are the singularized version of the words included in the input dictionary and the frequencies are the sum of the frequencies in the input dictionary.
"""
function singularized_word_dict(d::Dict{String,Int64})::Dict{String,Int64}
    w_dict::Dict{String,Int64} = Dict{String,Int64}()
    for w in keys(d)
        sw::String = singularize(w)
        w_dict[sw] = get(w_dict, sw, 0) + d[w]
    end
    return w_dict
end

"""
   `conf_word_frequencies(conf_name::String, k::Int64, forbidden::Vector{String})::Tuple{Vector{String},Vector{Int64}}`

Return two vectors with the top-k words and with their frequencies, respectively, among the words which appear in the titles of all the conference papers. If `k` is zero, then the vectors includes all the words and all their frequencies. The words in `forbidden` are discarded.
"""
function conf_word_frequencies(conf_name::String, k::Int64, forbidden::Vector{String})::Tuple{Vector{String},Vector{Int64}}
    fd::FileDocument = FileDocument(path_to_files * "titles/" * conf_name * "/all_paper_titles.txt")
    sd::StringDocument = StringDocument(TextAnalysis.text(fd))
    d::Dict{String,Int64} = ngram_frequencies(sd)
    w_dict::Dict{String,Int64} = singularized_word_dict(d)
    if (k > 0)
        return top_k_dict_words(w_dict, k, forbidden)
    else
        return top_k_dict_words(w_dict, length(keys(w_dict)), forbidden)
    end
end

"""
   `area_word_frequencies(conf_name::String, k::Int64, forbidden::Vector{String})::Tuple{Vector{String},Vector{Int64}}`

Return two vectors with the top-k words and with their frequencies, respectively, among the words which appear in the titles of all papers included in the area. The words in `forbidden` are discarded.
"""
function area_word_frequencies(area::String, k::Int64, forbidden::Vector{String})::Tuple{Vector{String},Vector{Int64}}
    fd::FileDocument = FileDocument(path_to_files * "titles/areas/" * area * "/all_paper_titles.txt")
    sd::StringDocument = StringDocument(TextAnalysis.text(fd))
    d::Dict{String,Int64} = ngram_frequencies(sd)
    w_dict::Dict{String,Int64} = Dict{String,Int64}()
    for w in keys(d)
        sw::String = singularize(w)
        w_dict[sw] = get(w_dict, sw, 0) + d[w]
    end
    return top_k_dict_words(w_dict, k, forbidden)
end

"""
   `word_evolution(conf_name::String, step::Int64, k::Int64, forbidden::Vector{String})::Tuple{Vector{Int64},Dict{String,Vector{Int64}}}`

Return a vector with the number of words in all the titles of the papers in each interval of length `step` and a dictionary which, for any word among the top-k, has as value the vector of its occurrences in all the titles of the papers in each interval of length `step`. The words in `forbidden` are discarded.
"""
function word_evolution(conf_name::String, step::Int64, k::Int64, forbidden::Vector{String})::Tuple{Vector{Int64},Dict{String,Vector{Int64}}}
    first_year::Int64, last_year::Int64 = first_last_year(conf_name)
    words::Vector{String}, _ = conf_word_frequencies(conf_name, k, forbidden::Vector{String})
    sort!(words)
    ngram_number::Vector{Int64} = []
    ngram_evol::Dict{String,Vector{Int64}} = Dict{String,Vector{Int64}}()
    for w in words
        ngram_evol[w] = []
    end
    for y in first_year:step:last_year
        titles::String = ""
        for yy in y:(y+step-1)
            fn::String = path_to_files * "conferences/" * conf_name * "/papers/paper_titles_" * string(yy) * ".txt"
            if isfile(fn)
                for l in readlines(fn)
                    titles = titles * "\n" * l
                end
            end
        end
        sd::StringDocument = StringDocument(titles)
        d::Dict{String,Int64} = ngram_frequencies(sd)
        w_dict::Dict{String,Int64} = singularized_word_dict(d)
        w_number::Int64 = 0
        for w in keys(w_dict)
            w_number = w_number + w_dict[w]
        end
        push!(ngram_number, w_number)
        for w in words
            f::Int64 = get(w_dict, w, 0)
            push!(ngram_evol[w], f)
        end
    end
    return ngram_number, ngram_evol
end
