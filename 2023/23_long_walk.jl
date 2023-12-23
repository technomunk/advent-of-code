include("utils.jl")

Map = Matrix{Char}
Path = Vector{Point2}

const PATHS_ARG = "--paths"
const GRAPH_ARG = "--graph"
const MERMAID_ARG = "--mermaid"

function solve()
    map = matrix(readlines())
    graph = build_graph(map)

    if PATHS_ARG ∈ ARGS
        printpath.(Ref(map), paths(map, isdownhill))
    elseif GRAPH_ARG ∈ ARGS
        printgrid(impose(map, graph), repl=graphcolor)
        for (_, (name, _)) in graph.nodes
            println("$name = $(to_char(name))")
        end
    elseif MERMAID_ARG ∈ ARGS
        print_mermaid(graph)
    else
        maximum(length, paths(map, isdownhill)) |> (n -> n - 1) |> println
        longest_path(graph) |> println
    end
end

function paths(map::Map, walkability_test)::Vector{Path}
    start_x::Int = indexin('.', (@view map[1, :]))[1]
    height = size(map)[1]

    paths::Vector{Path} = [[]]
    navigators::Vector{Tuple{Int,Point2}} = [(1, (x=start_x, y=1))]

    while !isempty(navigators)
        navigate!(map, paths, navigators, height, walkability_test)
    end

    return filter!(p -> p[end][1] == height, paths)
end

function navigate!(
    map::Map,
    paths::Vector{Path},
    navigators::Vector{Tuple{Int,Point2}},
    height::Int,
    walkability_test,
)::Nothing
    index, pos = pop!(navigators)
    push!(paths[index], pos)
    if pos.y == height
        return # this navigator has reached the end
    end
    next_steps = neighborcoords(map, pos, test=p -> (p ∉ paths[index]) && walkability_test(map, pos, p))
    if isempty(next_steps)
        return # this navigator has reached a dead end
    end
    # continue with the first step to avoid agressive allocations
    push!(navigators, (index, next_steps[1]))
    for next_step in (@view next_steps[2:end])
        push!(paths, copy(paths[index]))
        push!(navigators, (length(paths), next_step))
    end
    return nothing
end

isnotstone(map::Map, ::Point2, to::Point2) = map[to...] != '#'
function isdownhill(map::Map, from::Point2, to::Point2)::Bool
    dy, dx = to - from
    if dx == 0
        if dy == 1
            return map[to...] ∈ ('.', 'v')
        else
            return map[to...] ∈ ('.', '^')
        end
    elseif dx == 1
        return map[to...] ∈ ('.', '>')
    else
        return map[to...] ∈ ('.', '<')
    end
end

struct Graph
    start::Point2
    finish::Point2
    nodes::Dict{Point2,@NamedTuple{name::String, neighbors::Set{Point2}}}
    edges::Dict{Tuple{Point2,Point2},Int}
    Graph(start::Point2, finish::Point2) = new(start, finish, Dict(start => (name="START", neighbors=Set()), finish => (name="FINISH", neighbors=Set())), Dict())
end
Visitor = @NamedTuple{pos::Point2, from::Point2, dist::Int, prev::Point2}

function Base.push!(graph::Graph, visitor::Visitor)::Graph
    known_dist = distance(graph, visitor.from, visitor.pos)
    if known_dist == visitor.dist
        return graph
    end

    addnode!(graph, visitor.pos)
    addnode!(graph, visitor.from)
    if known_dist != -1
        error("Duplicate edge $visitor, known distance == $known_dist")
    end
    push!(graph.edges, (visitor.from, visitor.pos) => visitor.dist)
    push!(graph.nodes[visitor.from].neighbors, visitor.pos)
    push!(graph.nodes[visitor.pos].neighbors, visitor.from)
    return graph
end
function addnode!(graph::Graph, pos::Point2)::Nothing
    if pos ∈ keys(graph.nodes)
        return nothing
    end
    graph.nodes[pos] = (name="n$(length(graph.nodes) - 1)", neighbors=Set{Point2}())
    return nothing
end

function build_graph(map::Map)::Graph
    start_x = indexin('.', (@view map[1, :]))[1]
    start = (y=1, x=start_x)
    finish_x = indexin('.', (@view map[end, :]))[1]
    finish = (y=size(map)[1], x=finish_x)
    result = Graph(start, finish)

    visited_nodes = Set{Point2}()
    to_visit::Vector{Visitor} = [(pos=start, from=start, dist=0, prev=start)]
    while !isempty(to_visit)
        visit!(map, visited_nodes, result, to_visit)
    end
    return result
end
function visit!(map::Map, visited_nodes::Set{Point2}, graph::Graph, to_visit::Vector{Visitor})::Nothing
    visitor = pop!(to_visit)
    push!(visited_nodes, visitor.pos)
    if visitor.pos == graph.finish
        push!(graph, visitor)
        return nothing  # reached the end
    end

    neighbors = neighborcoords(map, visitor.pos, test=p -> (p != visitor.prev) && (map[p...] != '#'))
    if length(neighbors) == 1
        neighbor = neighbors[1]
        if neighbor ∈ keys(graph.nodes)
            push!(graph, (pos=neighbor, from=visitor.from, dist=visitor.dist + 1, prev=visitor.pos))
            return nothing
        end
        push!(to_visit, (pos=neighbor, from=visitor.from, dist=visitor.dist + 1, prev=visitor.pos))
        return nothing
    end

    push!(graph, visitor)
    for neighbor in neighbors
        push!(to_visit, (pos=neighbor, from=visitor.pos, dist=1, prev=visitor.pos))
    end
    return nothing
end

distance(graph::Graph, a::Point2, b::Point2)::Int = get(graph.edges, (a, b), get(graph.edges, (b, a), -1))
function distance(graph::Graph, path::Path)::Int
    result = 0
    for (a, b) in zip(path[1:end-1], path[2:end])
        result += distance(graph, a, b)
    end
    return result
end

function longest_path(graph::Graph)::Int
    paths::Vector{Path} = [[]]
    navigators::Vector{Tuple{Int,Point2}} = [(1, graph.start)]

    while !isempty(navigators)
        navigate!(graph, paths, navigators)
    end

    filter!(p -> p[end] == graph.finish, paths)
    return maximum(p -> distance(graph, p), paths)
end
function navigate!(graph::Graph, paths::Vector{Path}, navigators::Vector{Tuple{Int,Point2}})::Nothing
    index, pos = pop!(navigators)
    push!(paths[index], pos)
    if pos == graph.finish
        return # this navigator has reached the end
    end
    next_steps = filter!(n -> n ∉ paths[index], collect(graph.nodes[pos].neighbors))
    if isempty(next_steps)
        return # this navigator has reached a dead end
    end
    push!(navigators, (index, next_steps[1]))
    for next_step in (@view next_steps[2:end])
        push!(paths, copy(paths[index]))
        push!(navigators, (length(paths), next_step))
    end
    return nothing
end

function impose!(map::Map, path::Path)::Map
    for (i, pos) in enumerate(path)
        map[pos...] = Char(i % 10 + 48)
    end
    return map
end
function impose!(map::Map, graph::Graph)::Map
    for (pos, (name, _)) in graph.nodes
        map[pos...] = to_char(name)
    end
    return map
end
impose(map::Map, path::Union{Path,Graph})::Map = impose!(copy(map), path)

const NODE_NAMES = "abcdefghijklmonpqrstuvwxyz"
function to_char(name::String)::Char
    if startswith(name, "n")
        n = parse(Int, name[2:end])
        if n < length(NODE_NAMES)
            return NODE_NAMES[n]
        end
        return NODE_NAMES[n%length(NODE_NAMES)+1]
    end
    return name[1]
end

function print_mermaid(graph::Graph)
    println("graph TD")
    seen_edges = Set{Tuple{Point2,Point2}}()
    for (pos, (name, neighbors)) in sort!(collect(graph.nodes), lt=(a, b) -> a[2][1] < b[2][1])
        for neighbor in neighbors
            if (pos, neighbor) ∈ seen_edges
                continue
            end
            dist = distance(graph, pos, neighbor)
            println("  $name <-->|$dist| $(graph.nodes[neighbor].name)")
            push!(seen_edges, (neighbor, pos))
        end
    end
end

# ANSI graphic rendetion codes
const COLOR_FG_GRAY = "90"
const COLOR_FG_WHITE = "37"
const COLOR_FG_GREEN = "32"
const COLOR_FG_BLACK = "30"
const COLOR_FG_DEFAULT = "39"

const COLOR_BG_WHITE = "47"
const COLOR_BG_GRAY = "100"
const COLOR_BG_DEFAULT = "49"

function color(ch::Char)::String
    if ch == '#'
        return "\e[$(COLOR_BG_GRAY)m "
    elseif ch ∈ ".v^><"
        return "\e[$(COLOR_BG_DEFAULT)m$ch"
    end
    return "\e[$COLOR_FG_GREEN;$(COLOR_BG_DEFAULT)m$ch"
end
function graphcolor(ch::Char)::String
    if ch == '#'
        return "\e[$(COLOR_BG_GRAY)m "
    elseif ch ∈ ".v^><"
        return "\e[$(COLOR_BG_DEFAULT)m "
    end
    return "\e[$COLOR_FG_GREEN;$(COLOR_BG_DEFAULT)m$ch"
end

function printpath(map::Map, path::Path)
    printgrid(impose(map, path), repl=color)
    println("\e[0m")
end

function printgraph(graph::Graph)
    for (pos, (name, neighbors)) in graph.nodes
        println("$(name) $pos : $(join(graph.nodes[n].name for n in neighbors))")
    end
    for ((from, to), d) in graph.edges
        println("$(graph.nodes[from].name) <--> $(graph.nodes[to].name) : $d")
    end
end
solve()
