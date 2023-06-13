#####################################################
# STATIC GRAPH MINER
#####################################################
"""
   `read_static_graph(fn::String, n::Int64)::SimpleGraph{Int64}`

Return the graph stored in the file `fn` with `n` nodes (the file format is the one used by the Java code).
"""
function read_static_graph(fn::String, n::Int64)::SimpleGraph{Int64}
    g::SimpleGraph{Int64} = SimpleGraph{Int64}(n)
    for l in eachline(fn)
        split_l::Vector{SubString{String}} = split(l, ",")
        u::Int64 = parse(Int64, split_l[1])
        v::Int64 = parse(Int64, split_l[2])
        add_edge!(g, u, v)
    end
    return g
end

"""
   `lcc_subgraph(g::SimpleGraph{Int64})::SimpleGraph{Int64}`

Return the subgraph of `g` induced by the nodes in its largest connected component.
"""
function lcc_subgraph(g::SimpleGraph{Int64})::SimpleGraph{Int64}
    cc::Array{Array{Int64}} = connected_components(g)
    lcc_index::Int64 = argmax(length.(cc))
    return induced_subgraph(g, cc[lcc_index])[1]
end

"""
   `degrees_of_separation(g::SimpleGraph{Int64})::Float64`

Return the average distance between the nodes in the largest connected component of the graph `g`.
"""
function degrees_of_separation(g::SimpleGraph{Int64})::Float64
    if (nv(g) > 0)
        g = lcc_subgraph(g)
        if (nv(g) > 1)
            s::Int64 = 0
            for x::Int64 in vertices(g)
                d::Array{Int64} = gdistances(g, x)
                s = s + sum(d)
            end
            return s / (nv(g) * (nv(g) - 1))
        else
            return 0
        end
    else
        return 0
    end
end

"""
   `diameter_ifub(g::SimpleGraph{Int64})::Int64`

Return the diameter of the largest connected component of the graph `g`.
"""
function diameter_ifub(g::SimpleGraph{Int64})::Int64
    if (nv(g) > 0)
        g = lcc_subgraph(g)
        if (nv(g) > 1)
            _, u = findmax(degree_centrality(g, normalize=false))
            d::Array{Int64} = gdistances(g, u)
            node_index::Array{Int64} = sortperm(d, alg=RadixSort, rev=true)
            c::Int64, i::Int64, L::Int64, U::Int64 = 1, d[node_index[1]], 0, nv(g)
            while (L < U)
                U, L = nv(g), Base.max(L, maximum(gdistances(g, node_index[c])))
                c = c + 1
                if (d[node_index[c]] == i - 1)
                    U, i = 2 * (i - 1), i - 1
                end
            end
            return L
        else
            return 0
        end
    else
        return 0
    end
end

"""
   `graph_evolution(conf_name::String, first_year::Int64, last_year::Int64)::Tuple{Array{Int64},Array{Int64},Array{Float64},Array{Int64},Array{Int64}}`

Return four vectors containing the evolution of the number of nodes, of the number of edges, of the diameter of the largest connected component, and of the average distance of the largest connected component, respeticely, of the graph corresponding to the conference `conf_name`.
"""
function graph_evolution(conf_name::String, first_year::Int64, last_year::Int64)::Tuple{Array{Int64},Array{Int64},Array{Float64},Array{Int64},Array{Int64}}
    fn::String = path_to_files * "conferences/" * conf_name * "/" * "temporal_graph_sorted.txt"
    num_nodes::Array{Int64} = zeros(Int64, last_year - first_year + 1)
    num_edges::Array{Int64} = zeros(Int64, last_year - first_year + 1)
    degree_separation::Array{Float64} = zeros(Float64, last_year - first_year + 1)
    diameter::Array{Int64} = zeros(Int64, last_year - first_year + 1)
    e_diameter::Array{Int64} = zeros(Int64, last_year - first_year + 1)
    g::SimpleGraph{Int64} = SimpleGraph{Int64}()
    id_node::Dict{Int64,Int64} = Dict{Int64,Int64}()
    current_year::Int64 = first_year
    f::IOStream = open(fn)
    lines::Vector{String} = readlines(f)
    for l in lines
        split_l::Vector{SubString{String}} = split(l, ",")
        u::Int64 = parse(Int64, split_l[1])
        v::Int64 = parse(Int64, split_l[2])
        y::Int64 = parse(Int64, split_l[3])
        if (y <= last_year)
            if (y <= current_year)
                if (get(id_node, u, 0) == 0)
                    add_vertex!(g)
                    id_node[u] = nv(g)
                end
                if (get(id_node, v, 0) == 0)
                    add_vertex!(g)
                    id_node[v] = nv(g)
                end
                if (u != v)
                    add_edge!(g, id_node[u], id_node[v])
                end
            else
                num_nodes[current_year-first_year+1] = nv(g)
                num_edges[current_year-first_year+1] = ne(g)
                degree_separation[current_year-first_year+1] = degrees_of_separation(g)
                diameter[current_year-first_year+1] = diameter_ifub(g)
                e_diameter[current_year-first_year+1] = effective_diameter(g)
                current_year = y
                if (get(id_node, u, 0) == 0)
                    add_vertex!(g)
                    id_node[u] = nv(g)
                end
                if (get(id_node, v, 0) == 0)
                    add_vertex!(g)
                    id_node[v] = nv(g)
                end
                if (u != v)
                    add_edge!(g, id_node[u], id_node[v])
                end
            end
        end
    end
    num_nodes[current_year-first_year+1] = nv(g)
    num_edges[current_year-first_year+1] = ne(g)
    degree_separation[current_year-first_year+1] = degrees_of_separation(g)
    diameter[current_year-first_year+1] = diameter_ifub(g)
    e_diameter[current_year-first_year+1] = effective_diameter(g)
    return num_nodes, num_edges, degree_separation, diameter, e_diameter
end

"""
   `top_k_authors(conf_name::String, k::Int64)::Tuple{Vector{Int64}, Vector{Int64}, Vector{Int64}}`

Return three vectors containing the indices of the top-k authors of the conference `conf_name` with respect to the degree, the closeness, and the betwenness, respectively.
"""
function top_k_authors(conf_name::String, k::Int64)::Tuple{Vector{Int64},Vector{Int64},Vector{Int64}}
    fn::String = path_to_files * "conferences/" * conf_name * "/" * "static_graph.txt"
    g::SimpleGraph{Int64} = read_static_graph(fn, number_authors(conf_name))
    cc::Array{Array{Int64}} = connected_components(g)
    lcc_index::Int64 = argmax(length.(cc))
    g, id_map = induced_subgraph(g, cc[lcc_index])
    d::Array{Float64} = degree_centrality(g)
    c::Array{Float64} = closeness_centrality(g)
    b::Array{Float64} = betweenness_centrality(g)
    top_d = partialsortperm(d, 1:k, rev=true)
    top_c = partialsortperm(c, 1:k, rev=true)
    top_b = partialsortperm(b, 1:k, rev=true)
    return id_map[top_d], id_map[top_c], id_map[top_b]
end

"""
   `effective_diameter(g::SimpleGraph{Int64})::Int64`

Return the effective diameter of the largest connected component of the graph `g`.
"""
function effective_diameter(g::SimpleGraph{Int64})::Int64
    if (nv(g) > 0)
        g = lcc_subgraph(g)
        if (nv(g) > 1)
            dist_freq::Array{Int64} = zeros(Int64, nv(g))
            for u in 1:nv(g)
                d::Array{Int64} = gdistances(g, u)
                for v in 1:nv(g)
                    dist_freq[d[v]+1] = dist_freq[d[v]+1] + 1
                end
            end
            num_pairs::Int64 = 0
            current_dist::Int64 = 0
            while (num_pairs < 0.9 * nv(g) * nv(g))
                current_dist = current_dist + 1
                num_pairs = num_pairs + dist_freq[current_dist]
            end
            return current_dist - 1
        else
            return 0
        end
    else
        return 0
    end
end

function lin_reg(conf::Array{String})
    for c in 1:lastindex(conf)
        fy::Int64, ly::Int64 = first_last_year(conf[c])
        nn, ne, _, _ = Main.Miner.graph_evolution(conf[c], fy, ly)
        lnn = log.(nn)
        push!(lnn, 0.0)
        lne = log.(ne)
        push!(lne, 0.0)
        data = DataFrame(X=lnn, Y=lne)
        ols = lm(@formula(Y ~ X), data)
        println(conf[c], " & ", ols.model.pp.beta0[2], " & ", r2(ols))
    end
end

#####################################################
# TEMPORAL GRAPH MINER
#####################################################
function parse_line(line::String)
    uvtd = split(line, ",")
    u = parse(Int64, uvtd[1])
    v = parse(Int64, uvtd[2])
    t = parse(Int64, uvtd[3])
    return u, v, t, 1
end

struct TGStats
    n::Int64
    m::Int64
    t_alpha::Int64
    t_omega::Int64
    T::Dict{Int64,Int64}
end

function get_stats(conf_name::String)::TGStats
    time_occurrences::Dict{Int64,Int64} = Dict{Int64,Int64}()
    min_time::Int64 = typemax(Int64)
    max_time::Int64 = -1
    max_node::Int64 = -1
    num_lines::Int64 = 0
    for line in eachline(path_to_files * "conferences/" * conf_name * "/temporal_graph_sorted.txt")
        num_lines = num_lines + 1
        u, v, t, _ = parse_line(line)
        max_node = Base.max(max_node, u, v)
        min_time = Base.min(min_time, t)
        max_time = Base.max(max_time, t)
        to = get(time_occurrences, t, 0)
        time_occurrences[t] = to + 1
    end
    return TGStats(max_node, num_lines, min_time, max_time, time_occurrences)
end

function print_stats(stats::TGStats)
    println("Number of nodes: ", stats.n)
    println("Number of edges: ", stats.m)
    println("First time instant: ", stats.t_alpha)
    println("Last time instant: ", stats.t_omega)
    println("Time horizon length: ", (stats.t_omega - stats.t_alpha))
    println("Number of distinct time instants: ", length(keys(stats.T)))
end

mutable struct Interval
    r::Int64
    l1::Int64
    s1::Int64
    l2::Int64
    s2::Int64
    function Interval(ri::Int64, l1i::Int64, s1i::Int64, l2i::Int64, s2i::Int64)
        return new(ri, l1i, s1i, l2i, s2i)
    end
end

function get_last(interval::Interval)::Array{Int64}
    result::Array{Int64} = [interval.l1, interval.s1]
    if (interval.l2 < interval.l1)
        result[1] = interval.l2
        result[2] = interval.s2
    end
    return result
end

function max(interval::Interval)::Array{Int64}
    result::Array{Int64} = [interval.l1, interval.s1]
    if (interval.s2 > interval.s1)
        result[1] = interval.l2
        result[2] = interval.s2
    end
    return result
end

function min(interval::Interval)::Array{Int64}
    result::Array{Int64} = [interval.l1, interval.s1]
    if (interval.s2 < interval.s1)
        result[1] = interval.l2
        result[2] = interval.s2
    end
    return result
end

function set(interval::Interval, r::Int64, l1::Int64, s1::Int64, l2::Int64, s2::Int64)
    interval.r = r
    interval.l1 = l1
    interval.s1 = s1
    interval.l2 = l2
    interval.s2 = s2
end

function set_max(interval, l::Int64, r::Int64, s::Int64)
    interval.r = r
    if (interval.s1 > interval.s2)
        interval.l1 = l
        interval.s1 = s
    else
        interval.l2 = l
        interval.s2 = s
    end
end

function set_min(interval, l::Int64)
    if (interval.s1 < interval.s2)
        interval.l1 = l
    else
        interval.l2 = l
    end
end

function get_closeness_contribution(interval::Interval, t_omega::Int64)::Float64
    delta::Float64 = 0.0
    if (interval.s1 < typemax(Int64) && interval.s2 < typemax(Int64))
        if (interval.r <= t_omega + 1)
            if (interval.s1 < interval.s2)
                delta = log((interval.r - interval.s1 + 1) / (interval.r - interval.s2 + 1))
            elseif (interval.s1 > interval.s2)
                delta = log((interval.r - interval.s2 + 1) / (interval.r - interval.s1 + 1))
            end
        end
    end
    return delta
end

function to_string(interval::Interval)
    return "{[" * string(interval.l1) * "," * string(interval.r) * ")," * string(interval.s1) * "}, {[" * string(interval.l2) * "," * string(interval.r) * ")," * string(interval.s2) * "}"
end

function ssbp_eat(file_name::String, is_directed::Bool, source::Int64, num_nodes::Int64, t_alpha::Int64, t_omega::Int64)::Array{Int64}
    eat::Array{Int64} = fill(-1, num_nodes)
    eat[source] = t_alpha
    for line in eachline(file_name)
        u, v, t, lambda = parse_line(line)
        if (t >= t_alpha && t <= t_omega)
            if (eat[u] >= 0 && t >= eat[u])
                if (eat[v] < 0 || (t + lambda) < eat[v])
                    eat[v] = t + lambda
                end
            end
            if (!is_directed && eat[v] >= 0 && t >= eat[v])
                if (eat[u] < 0 || (t + lambda) < eat[u])
                    eat[u] = t + lambda
                end
            end
        end
    end
    return eat .- t_alpha
end

"""
   `closeness_evolution(conf_name::String, source::Int64)::Array{Float64}`

Return the temporal harmonic closeness evolution of the author with index `source` in the temporal graph associated with the conference `conf_name`.
"""
function closeness_evolution(conf_name::String, source::Int64)::Array{Float64}
    fn::String = path_to_files * "conferences/" * conf_name * "/temporal_graph_sorted.txt"
    stats::TGStats = get_stats(conf_name)
    is_directed::Bool = false
    c_t::Array{Float64} = zeros(stats.t_omega - stats.t_alpha + 1)
    for t in stats.t_alpha:stats.t_omega
        dist::Vector{Int64} = ssbp_eat(fn, is_directed, source, stats.n, t, stats.t_omega)
        for u in 1:stats.n
            if (dist[u] > 0)
                c_t[t-stats.t_alpha+1] = c_t[t-stats.t_alpha+1] + (1 / (stats.n - 1)) * (1 / dist[u])
            end
        end
    end
    return c_t
end

function init_intervals(n::Int64, t_omega::Int64)::Array{Interval}
    node_interval::Array{Interval} = []
    for _ in 1:n
        push!(node_interval, Interval(t_omega + 2, t_omega + 1, typemax(Int64), t_omega + 1, typemax(Int64)))
    end
    return node_interval
end

function closeness_contribution(fn::String, stats::TGStats, s::Int64, directed::Bool)::Array{Float64}
    node_interval::Array{Interval} = init_intervals(stats.n, stats.t_omega)
    closeness::Array{Float64} = zeros(stats.n)
    edges::Vector{String} = readlines(fn)
    for e in length(edges):-1:1
        line = edges[e]
        u::Int64, v::Int64, t::Int64, _ = parse_line(line)
        if (t >= stats.t_alpha && t <= stats.t_omega)
            set(node_interval[s], t + 1, t, t, t, t)
            rtu::Array{Int64} = min(node_interval[u])
            _rtu::Array{Int64} = max(node_interval[u])
            rtv::Array{Int64} = min(node_interval[v])
            _rtv::Array{Int64} = max(node_interval[v])
            if (rtu[2] > t && rtv[2] > t)
                if (!directed && rtu[1] < rtv[1])
                    closeness[v] = closeness[v] + get_closeness_contribution(node_interval[v], stats.t_omega)
                    set_max(node_interval[v], rtu[1], rtv[1], t)
                elseif (rtu[1] > rtv[1])
                    closeness[u] = closeness[u] + get_closeness_contribution(node_interval[u], stats.t_omega)
                    set_max(node_interval[u], rtv[1], rtu[1], t)
                end
            elseif (rtu[2] > t && rtv[2] == t)
                if (!directed && rtu[1] < rtv[1])
                    set_min(node_interval[v], rtu[1])
                elseif (rtu[1] > _rtv[1])
                    closeness[u] = closeness[u] + get_closeness_contribution(node_interval[u], stats.t_omega)
                    set_max(node_interval[u], _rtv[1], rtu[1], t)
                end
            elseif (rtu[2] == t && rtv[2] > t)
                if (rtv[1] < rtu[1])
                    set_min(node_interval[u], rtv[1])
                elseif (!directed && rtv[1] > _rtu[1])
                    closeness[v] = closeness[v] + get_closeness_contribution(node_interval[v], stats.t_omega)
                    set_max(node_interval[v], _rtu[1], rtv[1], t)
                end
            elseif (rtu[2] == t && rtv[2] == t)
                if (rtu[1] > _rtv[1])
                    set_min(node_interval[u], _rtv[1])
                elseif (!directed && rtv[1] > _rtu[1])
                    set_min(node_interval[v], _rtu[1])
                end
            end
        end
    end
    for u in 1:stats.n
        if (u != s)
            closeness[u] = closeness[u] + get_closeness_contribution(node_interval[u], stats.t_omega)
            last::Array{Int64} = get_last(node_interval[u])
            if (last[1] > stats.t_alpha && last[2] < typemax(Int64))
                closeness[u] = closeness[u] + log((last[1] - stats.t_alpha + 1) / (last[1] - last[2] + 1))
            end
        end
    end
    return closeness
end

function closeness(conf_name::String, directed::Bool, verbose::Bool)::Array{Float64}
    stats::TGStats = get_stats(conf_name)
    if (verbose)
        print_stats(stats)
    end
    fn::String = path_to_files * "conferences/" * conf_name * "/temporal_graph_sorted.txt"
    c::Array{Float64} = zeros(stats.n)
    for s in 1:stats.n
        cs::Array{Float64} = closeness_contribution(fn, stats, s, directed)
        c = c + cs
        if (s % 500 == 0 && verbose)
            println(s, " visits done...")
        end
    end
    return c ./ ((stats.n - 1) * (stats.t_omega - stats.t_alpha))
end

function closeness(conf_name::String, verbose::Bool)::Tuple{Dict{Int64,String},Array{Float64}}
    id_name::Dict{Int64,String} = Dict{Int64,String}()
    fn::String = path_to_files * "conferences/" * conf_name * "/id_name_key.txt"
    for line in eachline(fn)
        split_line::Vector{String} = split(line, "##")
        id::Int64 = parse(Int64, split_line[2])
        id_name[id] = split_line[4]
    end
    return id_name, closeness(conf_name, false, verbose)
end
