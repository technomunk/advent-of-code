Base.Enums.@enum Pulse LOW HIGH

abstract type Node end

mutable struct FlipFlop <: Node
    outputs::Vector{String}
    state::Pulse
    FlipFlop(outputs::Vector{String}) = new(outputs, LOW)
end
struct Conjunction <: Node
    outputs::Vector{String}
    state::Dict{String,Pulse}
    Conjunction(outputs::Vector{String}) = new(outputs, Dict{String,Pulse}())
end
struct Broadcast <: Node
    outputs::Vector{String}
end
mutable struct Receiver <: Node
    outputs::Vector{String}
    low_pulses::Int
    Receiver() = new([], 0)
end

Network = Dict{String,Node}

inverse(p::Pulse)::Pulse = p == HIGH ? LOW : HIGH
eq(val) = x -> x == val

function recv!(node::FlipFlop, pulse::Pulse, sender::String)::Union{Pulse,Nothing}
    if pulse == HIGH
        return nothing
    end

    node.state = inverse(node.state)
    return node.state
end
function recv!(node::Conjunction, pulse::Pulse, sender::String)::Pulse
    node.state[sender] = pulse
    if all(eq(HIGH), values(node.state))
        return LOW
    end
    return HIGH
end
recv!(node::Broadcast, pulse::Pulse, sender::String)::Pulse = pulse
function recv!(node::Receiver, pulse::Pulse, sender::String)::Nothing
    if pulse == LOW
        node.low_pulses += 1
    end
    return nothing
end

reset!(node::FlipFlop) = node.state = LOW
function reset!(node::Conjunction)
    for name in keys(node.state)
        node.state[name] = LOW
    end
end
reset!(node::Receiver) = node.low_pulses = 0
reset!(::Node) = nothing

function Base.parse(::Type{Network}, lines::AbstractVector{String})::Network
    result = Network("button" => Broadcast(["broadcaster"]))
    for line in lines
        name, outputs = split(line, " -> ")
        outputs = convert(Vector{String}, split(outputs, ", "))
        if name == "broadcaster"
            result["broadcaster"] = Broadcast(outputs)
        elseif startswith(name, '%')
            result[name[2:end]] = FlipFlop(outputs)
        elseif startswith(name, '&')
            result[name[2:end]] = Conjunction(outputs)
        else
            result[name] = Receiver()
        end
    end

    for (name, node) in result
        for output_name in node.outputs
            if output_name ∉ keys(result)
                result[output_name] = Receiver()
            end
            output_node = result[output_name]
            if isa(output_node, Conjunction)
                output_node.state[name] = LOW
            end
        end
    end
    return result
end

function send!(network::Network, pulse::Pulse)::Tuple{Int,Int}
    counts = Dict{Pulse,Int}(HIGH => 0, LOW => 0)
    queue = Vector{Tuple{Pulse,String}}()
    push!(queue, (pulse, "button"))

    while !isempty(queue)
        pulse, sender_name = popfirst!(queue)
        for recvr_name in network[sender_name].outputs
            counts[pulse] += 1
            next_pulse = recv!(network[recvr_name], pulse, sender_name)
            if !isnothing(next_pulse)
                push!(queue, (next_pulse, recvr_name))
            end
        end
    end
    return counts[LOW], counts[HIGH]
end

function reset!(network::Network)::Network
    reset!.(values(network))
    return network
end

function presses!(network::Network)::Int
    count = 0
    while network["rx"].low_pulses == 0
        send!(network, LOW)
        count += 1
        if count % 100_000 == 0
            print("\rrunning count: $count")
        end
    end
    println()
    return count
end

function sendn!(network::Network, pulse::Pulse, n::Int)::Tuple{Int,Int}
    counts = 0, 0
    for _ = 1:n
        counts = counts .+ send!(network, pulse)
    end
    return counts
end

function inputs(name::String, network::Network)::Vector{String}
    if isa(network[name], Conjunction)
        return collect(keys(network[name].state))
    end
    inputs = Vector{String}()
    for (input_name, node) in network
        if name ∈ node.outputs
            push!(inputs, input_name)
        end
    end
    return inputs
end

function printmermaid(network::Network)
    println("graph TD")
    for (key, val) in network
        if isa(val, Conjunction)
            println("  $key{$key}")
        elseif isa(val, FlipFlop)
            println("  $key([$key])")
        end
    end

    for (key, val) in network
        for output in val.outputs
            println("  $key-->$output")
        end
    end
end

function cycleof!(network::Network, node::Conjunction)::Int
    seen_high = Dict{String,Bool}(key => false for key in keys(node.state))
    cycles = Dict{String,Int}()
    send_count = 0
    while length(cycles) != length(seen_high)
        send!(network, LOW)
        send_count += 1
        for (key, val) in node.state
            if !seen_high[key] && val == HIGH
                seen_high[key] = true
            elseif seen_high[key] && val == LOW && key ∉ keys(cycles)
                cycles[key] = send_count
            end
        end
    end
    return values(cycles) |> maximum
end

# High level solution
function solve()
    network = parse(Network, readlines())
    sendn!(network, LOW, 1000) |> prod |> println
    reset!(network)
    cycles = Vector{Int}()
    for n in ["mh", "zz", "cm", "kd"]
        push!(cycles, cycleof!(network, network[n]))
        reset!(network)
    end
    println(lcm(cycles))
end


solve()
