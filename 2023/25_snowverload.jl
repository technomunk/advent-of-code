VertexLabel = String

struct Graph
    vertices::Dict{VertexLabel,Set{VertexLabel}}
end

function solve()
    graph = parse(Graph, readlines())
    if length(ARGS) < 3
        println("// Use graphviz to find the 3 edges to cut:")
        print_dot(graph)
    else
        cut_edges!(graph, ARGS)
        a, b = subgraphs(graph)
        println(length(a) * length(b))
    end
end

Graph() = Graph(Dict())
function Base.parse(::Type{Graph}, lines::Vector{String})::Graph
    vertices = Dict{VertexLabel,Set{VertexLabel}}()
    for line in lines
        vertex, neighbors = split(line, ": ")
        for neighbor in split(neighbors)
            neighbor_set = get!(vertices, vertex, Set())
            push!(neighbor_set, neighbor)
            neighbor_set = get!(vertices, neighbor, Set())
            push!(neighbor_set, vertex)
        end
    end
    return Graph(vertices)
end

function edges(graph::Graph)::Vector{Tuple{VertexLabel,VertexLabel}}
    result = Set{Tuple{VertexLabel,VertexLabel}}()
    for (vertex, neighbors) in graph.vertices, neighbor in neighbors
        a, b = extrema((vertex, neighbor))
        push!(result, (a, b))
    end
    return collect(result)
end

function print_dot(graph::Graph)
    println("graph {")
    for (a, b) in edges(graph)
        println("  $a -- $b")
    end
    println("}")
end

function cut_edges!(graph::Graph, edges::Vector{String})::Graph
    for edge in edges
        a, b = split(edge, '-')
        cut_edge!(graph, (String(a), String(b)))
    end
    return graph
end

function cut_edge!(graph::Graph, (a,b)::Tuple{String,String})
    delete!(graph.vertices[a], b)
    delete!(graph.vertices[b], a)
end

function subgraphs(graph::Graph)::Tuple{Graph,Graph}
    first, state = iterate(graph.vertices)
    rest = Base.rest(graph.vertices, state)

    a = Graph()
    push!(a, first)

    deferred_vertices = collect(rest)
    next_deferred = []
    a_complete = false
    while !a_complete
        a_complete = true
        empty!(next_deferred)
        for (vertex, neighbors) in deferred_vertices
            if vertex ∈ a || any(n ∈ a for n in neighbors)
                push!(a, vertex => neighbors)
                a_complete = false
            else
                push!(next_deferred, vertex => neighbors)
            end
        end
        empty!(deferred_vertices)
        append!(deferred_vertices, next_deferred)
    end

    b = Graph()
    for vtx in deferred_vertices
        push!(b, vtx)
    end
    return a, b
end

function Base.push!(graph::Graph, (vertex, neighbors)::Pair{VertexLabel,Set{VertexLabel}})
    for neighbor in neighbors
        neighbor_set = get!(graph.vertices, vertex, Set())
        push!(neighbor_set, neighbor)
        neighbor_set = get!(graph.vertices, neighbor, Set())
        push!(neighbor_set, vertex)
    end
end
Base.:(∈)(vtx::VertexLabel, graph::Graph) = vtx ∈ keys(graph.vertices)

Base.length(graph::Graph)::Int = length(graph.vertices)

solve()
