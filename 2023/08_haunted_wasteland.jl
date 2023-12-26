function solve()
    instructions, _, nodes... = readlines()
    graph = parse(Graph, nodes)
    solve1(instructions, graph)
    solve2(instructions, graph)
end

const Node = Tuple{String,String}

struct Graph
    nodes::Dict{String,Node}
end

function solve1(instructions::String, graph::Graph)
    println(steps("AAA", instructions, graph, n -> n == "ZZZ"))
end

function solve2(instructions::String, graph::Graph)
    nodes = graph.nodes |> keys |> filter(n -> endswith(n, 'A')) |> collect
    cycles = steps.(nodes, instructions, tuple(graph), n -> endswith(n, 'Z'))
    println(lcm(cycles))
end

function Base.parse(::Type{Graph}, lines::Vector{String})::Graph
    nodes = Dict{String,Node}()
    for line in lines
        name, paths = split(line, " = ")
        paths = split(strip(paths, ['(', ')']), ", ")
        nodes[name] = (paths[1], paths[2])
    end
    return Graph(nodes)
end

function steps(node::String, instructions::String, graph::Graph, end_condition::Any)::Int
    steps = 0
    for dir in Iterators.cycle(instructions)
        if end_condition(node)
            return steps
        end
        steps += 1
        node = next(node, dir, graph)
    end
end

function next(node::String, dir::Char, graph::Graph)::String
    graph.nodes[node][dir == 'L' ? 1 : 2]
end
solve()
