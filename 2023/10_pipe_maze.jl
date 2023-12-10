function solve()
    network = readlines()
    start = findcoord(network, 'S')
    pipe = walkpipe(network, start)
    # part 1
    println(div(length(pipe), 2))
    # part 2
    println(enclosedarea(network, pipe))
end

Network = Vector{String}
Coord = Tuple{Int,Int}
mutable struct Agent
    last::Coord
    current::Coord
end

function walkpipe(network::Network, start::Coord)::Set{Coord}
    n, _ = neighbors(network, start)
    pipe = Set([start, n])
    agent = Agent(start, n)
    while agent.current != start
        step!(agent, network)
        push!(pipe, agent.current)
    end
    return pipe
end

function enclosedarea(network::Network, pipe::Set{Coord})::Int
    area = 0
    horizontal_pipe_counts = zeros(length(network[1]))
    start_pipe = startpipe(network)

    # each piece that does not belong to a pipe underneath odd number
    # of horizontal pipes is enclosed by the pipe
    for y in eachindex(network)
        for x in eachindex(network[y])
            if (x, y) ∈ pipe
                if iscarhor(getpipe(network, (x, y)), start_pipe)
                    horizontal_pipe_counts[x] += 1
                end
            else
                if horizontal_pipe_counts[x] % 2 == 1
                    area += 1
                end
            end
        end
    end
    return area
end

function step!(agent::Agent, network::Network)
    ns = neighbors(network, agent.current) |> filter(p -> p != agent.last)
    agent.last = agent.current
    agent.current = ns[1]
end


function findcoord(network::Network, ch::Char)::Coord
    for (y, s) in enumerate(network)
        x = findfirst(ch, s)
        if !isnothing(x)
            return (x, y)
        end
    end
end
function startpipe(network::Network)::Char
    start = findcoord(network, 'S')
    ns = neighbors(network, start) .|> (n -> n .- start)
    rns = reverse(ns)
    for (pipe, offset) in OFFSETS
        if offset == ns || offset == rns
            return pipe
        end
    end
end

function neighbors(network::Network, pos::Coord)::Tuple{Coord,Coord}
    pipe = getpipe(network, pos)
    if pipe == 'S'
        return startneighbors(network, pos)
    end
    offsets = OFFSETS[pipe]
    return (pos .+ offsets[1], pos .+ offsets[2])
end
function startneighbors(network::Network, pos::Coord)::Tuple{Coord, Coord}
    result = Vector{Coord}()
    for y in pos[2]-1:pos[2]+1
        for x in pos[1]-1:pos[1]+1
            pipe = getpipe(network, (x, y))
            if pipe == 'S' || pipe == '.'
                continue
            end
            ns = neighbors(network, (x, y))
            if ns[1] == pos || ns[2] == pos
                push!(result, (x, y))
            end
        end
    end
    return Tuple(result)
end

function getpipe(network::Network, pos::Coord)::Char
    return network[pos[2]][pos[1]]
end

const OFFSETS = Dict{Char,Tuple{Coord,Coord}}(
    '|' => ((0, -1), (0, 1)),
    '-' => ((-1, 0), (1, 0)),
    'L' => ((0, -1), (1, 0)),
    'J' => ((0, -1), (-1, 0)),
    '7' => ((-1, 0), (0, 1)),
    'F' => ((1, 0), (0, 1)),
)

const CARDINAL_HORIZONTAL = "-LF"

function iscarhor(pipe::Char, start_pipe::Char)::Bool
    if pipe == 'S'
        pipe = start_pipe
    end
    pipe ∈ CARDINAL_HORIZONTAL
end

solve()
