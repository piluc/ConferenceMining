#####################################################
# TITLE MINER
#####################################################
"""
   `get_all_paper_titles(conf_name::String)`

Collect the titles of all the papers presented at the conference and save them (in lower case) into the file `all_paper_titles.txt` in the directory `conf_name` included in the directory `titles`. 
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
   `area_paper_titles(area::String)`

Merge the paper tile files of the conferences in `area` into a unique file inside the subdirectory `<area>` of the directory `areas` included in the directory `titles`. All the words in the `forbidden_words` vector are deleted from the titles.
"""
function area_paper_titles(area::String)
    mkpath(path_to_files * "titles/areas/" * area)
    open(path_to_files * "titles/areas/" * area * "/all_paper_titles.txt", "w") do f
        for conf_name in conf_area[area]
            get_all_paper_titles(conf_name)
            fn::String = path_to_files * "titles/" * conf_name * "/all_paper_titles.txt"
            for l in readlines(fn)
                for w in forbidden_words
                    l = replace(l, w => "")
                end
                l = strip(l)
                write(f, l * "\n")
            end
        end
    end
end

"""
   `areas_paper_titles(areas::Dict{String,Vector{String}})`

For each area, merge the paper title files of the conferences in the area into a unique file.
"""
function areas_paper_titles(areas::Dict{String,Vector{String}})
    for area in keys(areas)
        area_paper_titles(area)
    end
end

"""
   `ngram_frequencies(sd::StringDocument, k::Int64)::Dict{String,Int64}`

Return the dictionary with keys the ngrams (that is, words) and values their frequencies of the specified string document (see the documentation of the `TextAnalysis` package).
"""
function ngram_frequencies(sd::StringDocument, k::Int64)::Dict{String,Int64}
    remove_words!(sd, ["via"])
    remove_case!(sd)
    prepare!(sd, strip_punctuation)
    prepare!(sd, strip_stopwords)
    prepare!(sd, strip_articles)
    prepare!(sd, strip_definite_articles)
    prepare!(sd, strip_indefinite_articles)
    prepare!(sd, strip_prepositions)
    return ngrams(sd, k)
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
    d::Dict{String,Int64} = ngram_frequencies(sd, 1)
    w_dict::Dict{String,Int64} = singularized_word_dict(d)
    if (k > 0)
        return top_k_dict_words(w_dict, k, forbidden)
    else
        return top_k_dict_words(w_dict, length(keys(w_dict)), forbidden)
    end
end

"""
   `area_word_frequencies(area::String, k::Int64, forbidden::Vector{String})::Tuple{Vector{String},Vector{Int64}}`

Return two vectors with the top-k words and with their frequencies, respectively, among the words which appear in the titles of all papers included in the area. The words in `forbidden` are discarded.
"""
function area_word_frequencies(area::String, k::Int64)::Tuple{Vector{String},Vector{Int64}}
    fd::FileDocument = FileDocument(path_to_files * "titles/areas/" * area * "/all_paper_titles.txt")
    sd::StringDocument = StringDocument(TextAnalysis.text(fd))
    d::Dict{String,Int64} = ngram_frequencies(sd, 1)
    w_dict::Dict{String,Int64} = Dict{String,Int64}()
    for w in keys(d)
        sw::String = singularize(w)
        w_dict[sw] = get(w_dict, sw, 0) + d[w]
    end
    return top_k_dict_words(w_dict, k, [""])
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
        d::Dict{String,Int64} = ngram_frequencies(sd, 1)
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

# RQ4-2
function word_evolution(area::String, step::Int64, k::Int64, fy::Int64, ly::Int64)::Tuple{Vector{Int64},Dict{String,Vector{Int64}}}
    conf::Array{String} = conf_area[area]
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    words::Vector{String}, _ = area_word_frequencies(area, k)
    sort!(words)
    ngram_number::Vector{Int64} = []
    ngram_evol::Dict{String,Vector{Int64}} = Dict{String,Vector{Int64}}()
    for w in words
        ngram_evol[w] = []
    end
    for y in fy:step:ly
        titles::String = ""
        for yy in y:(y+step-1)
            if (yy >= first_year && yy <= last_year)
                for conf_name in conf
                    fn::String = path_to_files * "conferences/" * conf_name * "/papers/paper_titles_" * string(yy) * ".txt"
                    if isfile(fn)
                        for l in readlines(fn)
                            titles = titles * "\n" * l
                        end
                    end
                end
            end
        end
        sd::StringDocument = StringDocument(titles)
        d::Dict{String,Int64} = ngram_frequencies(sd, 1)
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

function bigram_evolution(area::String, step::Int64, k::Int64, fy::Int64, ly::Int64)::Tuple{Vector{Int64},Dict{String,Vector{Int64}}}
    conf::Array{String} = conf_area[area]
    first_year::Int64, last_year::Int64 = first_last_year(conf)
    bigram_number::Vector{Int64} = []
    bigram_evol::Dict{String,Vector{Int64}} = Dict{String,Vector{Int64}}()
    period::Int64 = 0
    for y in fy:step:ly
        period = period + 1
        titles::String = ""
        for yy in y:(y+step-1)
            if (yy >= first_year && yy <= last_year)
                for conf_name in conf
                    fn::String = path_to_files * "conferences/" * conf_name * "/papers/paper_titles_" * string(yy) * ".txt"
                    if isfile(fn)
                        for l in readlines(fn)
                            titles = titles * "\n" * l
                        end
                    end
                end
            end
        end
        sd::StringDocument = StringDocument(titles)
        d::Dict{String,Int64} = ngram_frequencies(sd, 2)
        w_number::Int64 = 0
        for w in keys(d)
            w_number = w_number + d[w]
        end
        push!(bigram_number, w_number)
        for w in keys(bigram_evol)
            if (get(d, w, "") == "")
                push!(bigram_evol[w], 0)
            end
        end
        for w in keys(d)
            if (get(bigram_evol, w, "") == "")
                bigram_evol[w] = vcat(zeros(Int64, period - 1), [d[w]])
            else
                push!(bigram_evol[w], d[w])
            end
        end
    end
    return bigram_number, bigram_evol
end

function read_icalp_communities()
    fn::String = path_to_files * "icalp/communities.txt"
    author_membership::Dict{String,Tuple{Float64,Float64,Float64,Float64}} = Dict{String,Tuple{Float64,Float64,Float64,Float64}}()
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        author_membership[split_line[1]] = (parse(Float64, split_line[2]), parse(Float64, split_line[3]), parse(Float64, split_line[4]), parse(Float64, split_line[5]))
    end
    return author_membership
end

function icalp_communities(conf_name::String)
    icalp_as = author_name_set("icalp")
    conf_as = author_name_set(conf_name)
    int_as = intersect(icalp_as, conf_as)
    am = read_icalp_communities()
    total = zeros(4)
    den = 0
    for n in int_as
        if (get(am, n, "") != "")
            m = am[n]
            for a in 1:4
                total[a] = total[a] + m[a]
            end
        else
            den = den + 1
            println(n)
        end
    end
    return total ./ (length(int_as) - den)
end
