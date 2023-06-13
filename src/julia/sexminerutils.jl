#####################################################
# SEX MINER UTILITIES
#####################################################
function moving_average(vs::Array{Float64}, n::Int64)::Array{Float64}
    return [sum(@view vs[i:(i+n-1)]) / n for i in 1:(length(vs)-(n-1))]
end

function manual_sex_assignment()::Dict{String,String}
    full_name_sex::Dict{String,String} = Dict{String,String}()
    @assert isfile(path_to_files * "names/full_name_manual.txt") "No file with manual sex assignment"
    fn = path_to_files * "names/full_name_manual.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        full_name_sex[split_line[1]*" "*split_line[3]] = split_line[2]
    end
    return full_name_sex
end

function genderize_sex_assignment()::Dict{String,String}
    first_name_sex::Dict{String,String} = Dict{String,String}()
    fn = path_to_files * "names/first_name_genderize.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, ",")
        if (split_line[2] != "" && parse(Float64, split_line[3]) > 0.5)
            first_name_sex[split_line[1]] = split_line[2]
        end
    end
    return first_name_sex
end

function author_labeling_stats(conf::Array{String})
    akn = author_key_name(conf)
    msa = manual_sex_assignment()
    gsa = genderize_sex_assignment()
    ungenderized = 0
    manually_labeled = 0
    for n in values(akn)
        split_name::Vector{String} = split(n, " ")
        if (get(gsa, split_name[1], "") == "")
            ungenderized = ungenderized + 1
            if (get(msa, n, "") != "")
                manually_labeled = manually_labeled + 1
            end
        end
    end
    return length(akn), ungenderized, manually_labeled
end

"""
   `missing_author_name(conf_name::String, verbose::Bool)::Tuple{Int64,Int64,Int64}`

Create a dictionary with keys full author names and values a string among "female" and "male". The dictionary is initialized by reading the file `full_name_manual.txt` included in the `names` directory. Each line of this file contains the author first name, the sex (as specified above), and the rest of the author full name. A dictionary with keys first author names and values a string representing the answer of genderize.io is then created by reading the file `first_name_genderize.txt` included in the `names` directory. Each line of this file contains a first name, the sex (if specified), the probability, and the count (these are the answer of genderize.io). Successively, for each line in the `id_name.txt` file of the conference, if the author full name is not contained in the full name dictionary and the author first name does not determine the sex of the author because it is not in the first name dictionary or no sex assigned (error), or the probability is less than 1/2 (warning), or it is a one letter name, the number of erros, or warnings, and or one letter first names is increased by one. Return the value of these three variables (if `verbose` is `true`, then all errors, warnings, and single letters are also printed). 
"""
function missing_author_name(conf_name::String, verbose::Bool)
    full_name_sex::Dict{String,String} = manual_sex_assignment()
    if (verbose)
        println("The full name file contains ", length(keys(full_name_sex)), " manually classified full names.")
    end
    fn::String = path_to_files * "names/first_name_genderize.txt"
    first_name_sex::Dict{String,String} = Dict{String,String}()
    for line in eachline(fn)
        split_line::Vector{String} = split(line, ",")
        if (get(first_name_sex, split_line[1], "") != "")
            println("REPEATED FIRST NAME: ", split_line[1])
        end
        first_name_sex[split_line[1]] = line
    end
    if (verbose)
        println("The first name file contains ", length(keys(first_name_sex)), " lines (classified and not classified).")
    end
    fn = path_to_files * "conferences/" * conf_name * "/id_name_key.txt"
    errors::Int64 = 0
    warnings::Int64 = 0
    single_letter::Int64 = 0
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        if (!in(split_line[4], keys(full_name_sex)))
            split_name::Vector{String} = split(split_line[4], " ")
            if (length(split_name[1]) == 2 && split_name[1][2:2] == ".")
                if (verbose)
                    println("SINGLE LETTER: " * split_line[4])
                end
                single_letter = single_letter + 1
            elseif (!in(split_name[1], keys(first_name_sex)))
                if (verbose)
                    println("ERROR: " * split_line[4])
                    # println(split_name[1])
                end
                errors = errors + 1
            else
                sex_line::String = first_name_sex[split_name[1]]
                split_sex_line::Vector{String} = split(sex_line, ",")
                if (split_sex_line[2] == "")
                    if (verbose)
                        println("ERROR: " * split_line[4])
                    end
                    errors = errors + 1
                else
                    prob::Float64 = parse(Float64, split_sex_line[3])
                    if (prob <= 0.5)
                        if (verbose)
                            println("WARNING: " * split_line[4])
                        end
                        warnings = warnings + 1
                    end
                end
            end
        end
    end
    return errors, warnings, single_letter
end

"""
   `author_sex_assignment(conf_name::String)::Dict{String,String}`

Return a dictionary with keys full author names and values a string among "female", "male", and "none". The dictionary is initialized by reading the file `full_name_manual.txt` included in the `names` directory. A dictionary with keys first author names and values a string among "female" and "male" is then created by reading the file `first_name_genderize.txt` included in the `names` directory. Successively, for each line in the `id_name.txt` file of the conference, if the author full name is not contained in the full name dictionary, the author first name is used to check whether it is contained in the first name dictionary in order to determine the sex to be associated to the full name of the author (`none` if the first name is not in the dictionary). 
"""
function author_sex_assignment(conf_name::String)::Dict{String,String}
    full_name_sex::Dict{String,String} = manual_sex_assignment()
    first_name_sex::Dict{String,String} = Dict{String,String}()
    fn = path_to_files * "names/first_name_genderize.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, ",")
        if (split_line[2] != "" && parse(Float64, split_line[3]) > 0.5)
            first_name_sex[split_line[1]] = split_line[2]
        end
    end
    conf_full_name_sex::Dict{String,String} = Dict{String,String}()
    fn = path_to_files * "conferences/" * conf_name * "/id_name_key.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        if (get(full_name_sex, split_line[4], "") == "")
            split_name::Vector{String} = split(split_line[4], " ")
            if (get(first_name_sex, split_name[1], "") == "")
                conf_full_name_sex[split_line[4]] = "none"
            else
                conf_full_name_sex[split_line[4]] = first_name_sex[split_name[1]]
            end
        else
            conf_full_name_sex[split_line[4]] = full_name_sex[split_line[4]]
        end
    end
    return conf_full_name_sex
end

function author_sex_assignment(conf::Array{String})::Dict{String,String}
    full_name_sex::Dict{String,String} = Dict{String,String}()
    for c in 1:lastindex(conf)
        sex_assignment = author_sex_assignment(conf[c])
        for n in keys(sex_assignment)
            full_name_sex[n] = sex_assignment[n]
        end
    end
    return full_name_sex
end

"""
   `author_sex_evolution(conf_name::String)::Tuple{Vector{Int64},Vector{Int64},Vector{Int64},Vector{Int64}}`

Return four arrays containing, for each year in which an edition of the conference has taken place, the number of authors, the number of male authors, the number of female authors, and the number of authors for which the sex is not specified. 
"""
function author_sex_evolution(conf_name::String)::Tuple{Vector{Int64},Vector{Int64},Vector{Int64},Vector{Int64}}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/id_name_key.txt") "No file with id, names, and DBLP keys of the authors of the conference "
    fy::Int64, ly::Int64 = first_last_year(conf_name)
    full_name_sex::Dict{String,String} = author_sex_assignment(conf_name)
    id_full_name::Dict{Int64,String} = Dict{Int64,String}()
    fn::String = path_to_files * "conferences/" * conf_name * "/id_name_key.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        id::Int64 = parse(Int64, split_line[2])
        id_full_name[id] = split_line[4]
    end
    authors::Vector{Set{Int64}} = []
    for _ in 1:(ly-fy+1)
        push!(authors, Set{Int64}())
    end
    num_authors::Vector{Int64} = zeros(Int64, ly - fy + 1)
    num_male_authors::Vector{Int64} = zeros(Int64, ly - fy + 1)
    num_female_authors::Vector{Int64} = zeros(Int64, ly - fy + 1)
    num_undetermined_authors::Vector{Int64} = zeros(Int64, ly - fy + 1)
    fn = path_to_files * "conferences/" * conf_name * "/papers.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        year::Int64 = parse(Int64, split_line[2])
        if (year >= fy && year <= ly)
            author::Vector{String} = split(split_line[6][2:prevind(split_line[6], end)], ",")
            for a in 1:lastindex(author)
                id::Int64 = parse(Int64, author[a])
                if (!in(id, authors[year-fy+1]))
                    push!(authors[year-fy+1], id)
                    num_authors[year-fy+1] = num_authors[year-fy+1] + 1
                    if (lowercase(full_name_sex[id_full_name[id]]) == "male")
                        num_male_authors[year-fy+1] = num_male_authors[year-fy+1] + 1
                    elseif (lowercase(full_name_sex[id_full_name[id]]) == "female")
                        num_female_authors[year-fy+1] = num_female_authors[year-fy+1] + 1
                    else
                        num_undetermined_authors[year-fy+1] = num_undetermined_authors[year-fy+1] + 1
                    end
                end
            end
        end
    end
    return num_authors, num_male_authors, num_female_authors, num_undetermined_authors
end

function author_set_sex_evolution(conf_name::String, step::Int64)::Tuple{Vector{Set{Int64}},Vector{Set{Int64}},Vector{Set{Int64}},Vector{Set{Int64}}}
    @assert isfile(path_to_files * "conferences/" * conf_name * "/id_name_key.txt") "No file with id, names, and DBLP keys of the authors of the conference "
    fy::Int64, ly::Int64 = first_last_year(conf_name)
    full_name_sex::Dict{String,String} = author_sex_assignment(conf_name)
    id_full_name::Dict{Int64,String} = Dict{Int64,String}()
    fn::String = path_to_files * "conferences/" * conf_name * "/id_name_key.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        id::Int64 = parse(Int64, split_line[2])
        id_full_name[id] = split_line[4]
    end
    authors::Vector{Set{Int64}} = []
    male_authors::Vector{Set{Int64}} = []
    female_authors::Vector{Set{Int64}} = []
    undetermined_authors::Vector{Set{Int64}} = []
    for _ in 1:(ly-fy+1)
        push!(authors, Set{Int64}())
        push!(male_authors, Set{Int64}())
        push!(female_authors, Set{Int64}())
        push!(undetermined_authors, Set{Int64}())
    end
    fn = path_to_files * "conferences/" * conf_name * "/papers.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        year::Int64 = parse(Int64, split_line[2])
        if (year >= fy && year <= ly)
            author::Vector{String} = split(split_line[6][2:prevind(split_line[6], end)], ",")
            for a in 1:lastindex(author)
                id::Int64 = parse(Int64, author[a])
                if (!in(id, authors[year-fy+1]))
                    push!(authors[year-fy+1], id)
                    if (lowercase(full_name_sex[id_full_name[id]]) == "male")
                        push!(male_authors[year-fy+1], id)
                    elseif (lowercase(full_name_sex[id_full_name[id]]) == "female")
                        push!(female_authors[year-fy+1], id)
                    else
                        push!(undetermined_authors[year-fy+1], id)
                    end
                end
            end
        end
    end
    cum_authors::Vector{Set{Int64}} = []
    cum_male_authors::Vector{Set{Int64}} = []
    cum_female_authors::Vector{Set{Int64}} = []
    cum_undetermined_authors::Vector{Set{Int64}} = []
    i_cum::Int64 = 0
    for y in 1:step:(ly-fy+1)
        push!(cum_authors, Set{Int64}())
        push!(cum_male_authors, Set{Int64}())
        push!(cum_female_authors, Set{Int64}())
        push!(cum_undetermined_authors, Set{Int64}())
        i_cum = i_cum + 1
        for s in 0:(step-1)
            if (y + s <= ly - fy + 1)
                union!(cum_authors[i_cum], authors[y+s])
                union!(cum_male_authors[i_cum], male_authors[y+s])
                union!(cum_female_authors[i_cum], female_authors[y+s])
                union!(cum_undetermined_authors[i_cum], undetermined_authors[y+s])
            end
        end
    end
    return cum_authors, cum_male_authors, cum_female_authors, cum_undetermined_authors
end

function author_sex_assignment(ns::Set{String})::Tuple{Dict{String,String},Dict{String,String}}
    full_name_sex::Dict{String,String} = manual_sex_assignment()
    first_name_sex::Dict{String,String} = Dict{String,String}()
    fn = path_to_files * "names/first_name_genderize.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, ",")
        if (split_line[2] != "" && parse(Float64, split_line[3]) > 0.5)
            first_name_sex[split_line[1]] = split_line[2]
        end
    end
    genderize_name_sex::Dict{String,String} = Dict{String,String}()
    manual_name_sex::Dict{String,String} = Dict{String,String}()
    for name in ns
        if (get(full_name_sex, name, "") == "")
            split_name::Vector{String} = split(name, " ")
            if (get(first_name_sex, split_name[1], "") == "")
                genderize_name_sex[name] = "none"
            else
                genderize_name_sex[name] = first_name_sex[split_name[1]]
            end
        else
            manual_name_sex[name] = full_name_sex[name]
        end
    end
    return genderize_name_sex, manual_name_sex
end

function unlabeled_author_last_year_age(conf::Array{String})::Dict{String,Tuple{Int64,Int64}}
    asa = author_sex_assignment(conf)
    akn = author_key_name(conf)
    alya = author_last_year_age(conf)
    ualya::Dict{String,Tuple{Int64,Int64}} = Dict{String,Tuple{Int64,Int64}}()
    for key in keys(akn)
        name::String = akn[key]
        if (asa[name] == "none")
            ly::Int64, aa::Int64 = alya[key]
            ualya[name] = (ly, aa)
        end
    end
    return ualya
end
