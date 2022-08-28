#####################################################
# DATA MINER UTILITIES
#####################################################
"""
   `author_key_set(conf_name::String)::Set{String}`

Return the set of the DBLP keys of all authors who have published at least one paper 
in the conference specified by the global acronym `conf_name`.
"""
function author_key_set(conf_name::String)::Set{String}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/id_name_key.txt") "No file with id, names, and DBLP keys of the authors of the conference "
    fn::String = path_to_files * "conferences/" * conf_name * "/" * "id_name_key.txt"
    authors::Set{String} = Set{String}()
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        push!(authors, split_line[6])
    end
    return authors
end

"""
   `author_name_set(conf_name::String)::Set{String}`

Return the set of the full DBLP names of all authors who have published at least one paper in the conference specified by the global acronym `conf_name`.
"""
function author_name_set(conf_name::String)::Set{String}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/id_name_key.txt") "No file with id, names, and DBLP keys of the authors of the conference "
    fn::String = path_to_files * "conferences/" * conf_name * "/" * "id_name_key.txt"
    authors::Set{String} = Set{String}()
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        push!(authors, split_line[4])
    end
    return authors
end

"""
   `number_authors(conf_name::String)::Int64`

Return the total number of authors who have published at least one paper in the conference specified by the global acronym `conf`.
"""
function number_authors(conf_name::String)::Int64
    @assert isfile(path_to_files * "conferences/" * conf_name * "/id_name_key.txt") "No file with id, names, and DBLP keys of the authors of the conference "
    fn::String = path_to_files * "conferences/" * conf_name * "/" * "id_name_key.txt"
    return countlines(fn)
end

"""
   `number_papers(conf_name::String)::Int64`

Return the total number of papers that have been published in the conference specified by the global acronym `conf`.
"""
function number_papers(conf_name::String)::Int64
    @assert isfile(path_to_files * "conferences/" * conf_name * "/papers.txt") "No file with list of papers the conference "
    fn::String = path_to_files * "conferences/" * conf_name * "/papers.txt"
    return countlines(fn)
end

"""
   `first_last_year(conf_name::String)::Tuple{Int64,Int64}`

Return the first and the last year in which an edition of the conference specified by 
the global acronym `conf_name` has taken place.
"""
function first_last_year(conf_name::String)::Tuple{Int64,Int64}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/temporal_graph_conf_sorted.txt") "No file with sorted link stream of the conference " * conf_name
    fn::String = path_to_files * "conferences/" * conf_name * "/temporal_graph_conf_sorted.txt"
    lines::Array{String} = readlines(fn)
    line::String = lines[1]
    split_line::Vector{String} = split(line, ",")
    first_year::Int64 = parse(Int64, split_line[3])
    line = lines[length(lines)]
    split_line = split(line, ",")
    last_year::Int64 = parse(Int64, split_line[3])
    return first_year, last_year
end

function conferences(conf_name::String)::Tuple{Dict{String,Int64},Dict{String,Int64}}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/author_conferences.txt") "No file with list of conferences for each author of the conference "
    f::IOStream = open(path_to_files * "conferences/" * conf_name * "/author_conferences.txt")
    conf_acronym::Dict{String,Int64} = Dict{String,Int64}()
    conf_occurrences::Dict{String,Int64} = Dict{String,Int64}()
    lines::Vector{String} = readlines(f)
    conf_id::Int64 = 1
    for l in lines
        split_l::Vector{SubString{String}} = split(l, "##")
        if (split_l[1] == "i" && length(split_l) > 6)
            println("Error with line ", l)
            return Dict{String,Int64}()
        end
        if (split_l[1] == "y" && length(split_l) > 4)
            println("Error with line ", l)
            return Dict{String,Int64}()
        end
        if (split_l[1] == "y")
            if (get(conf_acronym, split_l[4], 0) == 0)
                conf_acronym[split_l[4]] = conf_id
                conf_occurrences[split_l[4]] = 1
                conf_id = conf_id + 1
            else
                conf_occurrences[split_l[4]] = conf_occurrences[split_l[4]] + 1
            end
        end
    end
    return conf_acronym, conf_occurrences
end


"""
   `missing_years(conf_name::String)::Set{Int64}`

Return the set of years, between the first and the last ones, in which an edition of 
the conference specified by the global acronym `conf_name` has not taken place.
"""
function missing_years(conf_name::String)::Set{Int64}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/temporal_graph_conf_sorted.txt") "No file with sorted link stream of the conference "
    cy, _ = first_last_year(conf_name)
    fn::String = path_to_files * "conferences/" * conf_name * "/" * "temporal_graph_conf_sorted.txt"
    my::Set{Int64} = Set{Int64}()
    for line in eachline(fn)
        split_line::Vector{String} = split(line, ",")
        y::Int64 = parse(Int64, split_line[3])
        if (y != cy)
            if (y != (cy + 1))
                for m in (cy+1):(y-1)
                    push!(my, m)
                end
            end
            cy = y
        end
    end
    return my
end

"""
   `first_last_year(conf::Array{String})::Tuple{Int64,Int64}`

Return the minimum first year and the maximum last year in which an edition of a conference specified by a global acronym contained in the vector `conf` has taken place.
"""
function first_last_year(conf::Array{String})::Tuple{Int64,Int64}
    first_year::Int64 = typemax(Int64)
    last_year::Int64 = 0
    for c in conf
        fy::Int64, ly::Int64 = first_last_year(c)
        if (fy < first_year)
            first_year = fy
        end
        if (ly > last_year)
            last_year = ly
        end
    end
    return first_year, last_year
end

"""
   `papers_year(conf_name::String, first_year::Int64, last_year::Int64)::Vector{Int64}`

Return the vector containing, for each year between the specified first and last year in which an edition of the conference specified by the global acronym `conf_name` has taken place, the number of papers published in this year.
"""
function papers_year(conf_name::String, first_year::Int64, last_year::Int64)::Vector{Int64}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/papers.txt") "No file with list of papers of the conference "
    fn::String = path_to_files * "conferences/" * conf_name * "/papers.txt"
    num_papers::Vector{Int64} = zeros(Int64, last_year - first_year + 1)
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        year::Int64 = parse(Int64, split_line[2])
        if (year >= first_year && year <= last_year)
            num_papers[year-first_year+1] = num_papers[year-first_year+1] + 1
        end
    end
    return num_papers
end

"""
   `growth_rate(v::Vector{Int64})::Vector{Float64}`

Return the vector containing the growth rate of the vector `v`, by considering only values greater than 0. That is, the growth rate at each position whose value is greater than 0 is obtained by dividing the difference of the value in that position and the previous value greater than 0 by the previous value greater than 0 (the growth rate at the first position and at any position whose value is 0 is equal to 0).
"""
function growth_rate(v::Vector{Int64})::Vector{Float64}
    gr::Vector{Float64} = [0.0]
    previous_v::Int64 = v[1]
    for i in 2:length(v)
        if (v[i] > 0)
            push!(gr, (v[i] - previous_v) / previous_v)
            previous_v = v[i]
        else
            push!(gr, 0.0)
        end
    end
    return gr
end

"""
   `paper_growth_rate(conf_name::String, first_year::Int64, last_year::Int64)::Vector{Float64}`

Return the vector containing the growth rate of the number of papers that have been published in the conference, for each year in which an edition of the conference has taken place.
"""
function paper_growth_rate(conf_name::String, first_year::Int64, last_year::Int64)::Vector{Float64}
    return growth_rate(papers_year(conf_name, first_year, last_year))
end

"""
   `authors_year(conf_name::String, first_year::Int64, last_year::Int64)::Tuple{Array{Int64},Array{Int64}}`

Return two vector containing, for each year between the specified first and last year in which an edition of the conference specified by the global acronym `conf_name` has taken place, the number of authors and of new authors, respectively, who published in this year.
"""
function authors_year(conf_name::String, first_year::Int64, last_year::Int64)::Tuple{Array{Int64},Array{Int64}}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/papers.txt") "No file with list of papers of the conference "
    # Compute sets of authors for each year
    authors::Vector{Set{Int64}} = []
    for _ in 1:(last_year-first_year+1)
        push!(authors, Set{Int64}())
    end
    fn::String = path_to_files * "conferences/" * conf_name * "/papers.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        year::Int64 = parse(Int64, split_line[2])
        if (year >= first_year && year <= last_year)
            author::Vector{String} = split(split_line[6][2:prevind(split_line[6], end)], ",")
            for a in 1:length(author)
                id::Int64 = parse(Int64, author[a])
                if (!in(id, authors[year-first_year+1]))
                    push!(authors[year-first_year+1], id)
                end
            end
        end
    end
    # Compute number of authors per year, set of all authors, and
    # number of new authors per year 
    num_authors::Array{Int64} = zeros(Int64, last_year - first_year + 1)
    num_new_authors::Array{Int64} = zeros(Int64, last_year - first_year + 1)
    all_authors::Set{Int64} = Set{Int64}()
    for y in 1:(last_year-first_year+1)
        num_authors[y] = length(authors[y])
        num_new_authors[y] = length(authors[y]) - length(intersect(all_authors, authors[y]))
        union!(all_authors, authors[y])
    end
    return num_authors, num_new_authors
end

"""
   `author_growth_rate(conf_name::String, first_year::Int64, last_year::Int64)::Vector{Float64}`

Return the vector containing the growth rate of the number of authors that have published at least one paper in the conference, for each year in which an edition of the conference has taken place. The growth rate at each year is obtained by dividing the difference of the number of papers in the year and the number of papers of the previous year by the number of papers in the previous year.
"""
function author_growth_rate(conf_name::String, first_year::Int64, last_year::Int64)::Vector{Float64}
    return growth_rate(authors_year(conf_name, first_year, last_year)[1])
end

"""
   `percentage(x::Array{Int64}, y::Array{Int64})::Array{Float64}`

Return the vector containing the ratio between the two vectors `y` and `x``, by assigning 0 to the positions in which the value of `x` is 0.
"""
function percentage(x::Array{Int64}, y::Array{Int64})::Array{Float64}
    p::Array{Float64} = zeros(length(x))
    for i in 1:length(x)
        if (x[i] > 0)
            p[i] = y[i] / x[i]
        end
    end
    return p
end

"""
   `number_coauthors_distribution(conf_name::String, fy::Int64, ly::Int64, step::Int64)::Tuple{Vector{Int64},Vector{Vector{Int64}}}`

Compute, for each year between the specified first and last year, the number of papers that have been published in the conference with a specific number of coauthors, between one and the maximum number of co-authors. The papers are grouped in periods specified by the value of `step` (that is, each period contains `step` years), and the maximum number of co-authors is computed over all years. 
"""
function number_coauthors_distribution(conf_name::String, fy::Int64, ly::Int64, step::Int64)::Tuple{Vector{Int64},Vector{Vector{Int64}}}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/papers.txt") "No file with list of papers of the conference "
    num_authors::Int64 = number_authors(conf_name)
    num_buckets::Int64 = trunc(Int64, ceil((ly - fy + 1) / step))
    max_nc::Vector{Int64} = zeros(Int64, num_buckets)
    ncd::Matrix{Int64} = zeros(Int64, num_buckets, num_authors)
    fn::String = path_to_files * "conferences/" * conf_name * "/papers.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        year::Int64 = parse(Int64, split_line[2])
        if (year >= fy && year <= ly)
            bucket::Int64 = trunc(Int64, ceil((year - fy + 1) / step))
            author::Vector{String} = split(split_line[6][2:prevind(split_line[6], end)], ",")
            nc::Int64 = length(author)
            if (nc > max_nc[bucket])
                max_nc[bucket] = nc
            end
            ncd[bucket, nc] = ncd[bucket, nc] + 1
        end
    end
    dist::Vector{Vector{Int64}} = []
    for b in 1:num_buckets
        d::Vector{Int64} = zeros(Int64, max_nc[b])
        for nc in 1:max_nc[b]
            d[nc] = ncd[b, nc]
        end
        push!(dist, d)
    end
    return max_nc, dist
end

"""
   `new_authors_mean(conf::Array{String})::Vector{Float64}`

Compute, for each conference specified by a global acronym contained in the vector `conf`, the average number of new authors. 
"""
function new_authors_mean(conf::Array{String})::Vector{Float64}
    nam::Vector{Float64} = zeros(length(conf))
    for c in 1:length(conf)
        first_year::Int64, last_year::Int64 = first_last_year(conf[c:c])
        nay::Vector{Int64}, nnay::Vector{Int64} = authors_year(conf[c], first_year, last_year)
        ny::Int64 = count(x -> x > 0, nay)
        nam[c] = 0.0
        for y in 1:(last_year-first_year+1)
            if (nay[y] > 0)
                nam[c] = nam[c] + nnay[y] / nay[y]
            end
        end
        nam[c] = nam[c] / ny
    end
    return nam
end

"""
   `similarity_indices(conf1::Array{String}, conf2::Array{String})::Matrix{Float64}`

Compute, for each pair of one conference in `conf1` and one conference in `conf2`, the Sorensen-Dice index with respect to the set of authors of the two conferences. 
"""
function similarity_indices(conf1::Array{String}, conf2::Array{String})::Matrix{Float64}
    j::Matrix{Float64} = zeros(length(conf1), length(conf2))
    for c1 in 1:length(conf1)
        for c2 in 1:length(conf2)
            as1::Set{String} = author_key_set(conf1[c1])
            as2::Set{String} = author_key_set(conf2[c2])
            j[c1, c2] = length(intersect(as1, as2)) / length(union(as1, as2))
        end
    end
    return (2 .* j) ./ (1 .+ j)
end