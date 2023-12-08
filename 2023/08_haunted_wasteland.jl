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
    println(steps(instructions, graph))
end

function solve2(instructions::String, graph::Graph)
    nodes = graph.nodes |> keys |> filter(n -> endswith(n, 'A')) |> collect
    println(steps!(nodes, instructions, graph))
end

function parse(::Type{Graph}, lines::Vector{String})::Graph
    nodes = Dict{String,Node}()
    for line in lines
        name, paths = split(line, " = ")
        paths = split(strip(paths, ['(', ')']), ", ")
        nodes[name] = (paths[1], paths[2])
    end
    return Graph(nodes)
end

function steps(instructions::String, graph::Graph)::Int
    node = "AAA"
    steps = 0
    for dir in Iterators.cycle(instructions)
        if node == "ZZZ"
            return steps
        end
        steps += 1
        if dir == 'L'
            node = graph.nodes[node][1]
        else
            node = graph.nodes[node][2]
        end
    end
end
function steps!(nodes::AbstractArray{String}, instructions::String, graph::Graph)::Int
    steps = 0
    for dir in Iterators.cycle(instructions)
        if all(n -> endswith(n, 'Z'), nodes)
            return steps
        end
        steps += 1
        for i in eachindex(nodes)
            if dir == 'L'
                nodes[i] = graph.nodes[nodes[i]][1]
            else
                nodes[i] = graph.nodes[nodes[i]][2]
            end
        end
    end
end

solve()
