include("utils.jl")

function solve1()
    cmds = split(readlines()[1], ',')
    solve1(cmds)
    solve2(cmds)
end

function solve1(cmds::Vector{T}) where {T<:AbstractString}
    sum(asciihash.(cmds)) |> println
end
function solve2(cmds::Vector{T}) where {T<:AbstractString}
    operations = parse.(Operation, cmds)
    boxes::Vector{Box} = initvector(256, Box)
    for op in operations
        apply!(boxes, op)
    end
    focalpower.(enumerate(boxes)) |> sum |> println
end

function asciihash(s::T)::UInt8 where {T<:AbstractString}
    result = UInt8(0)
    for ch in s
        result = ((result + Int(ch)) * 17) % 256
    end
    return result
end

struct Lens
    label::SubString
    focal_length::Int
end
Box = Vector{Lens}

struct Operation
    lens::Lens
    operator::Char
end

function Base.:(==)(a::Lens, b::Lens)::Bool
    return a.label == b.label
end

function Base.parse(::Type{Operation}, s::T)::Operation where {T<:AbstractString}
    if '=' ∈ s
        operator = '='
        label, focal_length = split(s, '=')
        focal_length = parse(Int, focal_length)
    else
        operator = '-'
        label = @view s[1:end-1]
        focal_length = 0
    end
    return Operation(Lens(label, focal_length), operator)
end

function apply!(boxes::Vector{Box}, op::Operation)
    box_idx = asciihash(op.lens.label) + 1
    box = boxes[box_idx]
    lens_idx = findfirst(l -> l == op.lens, box)
    if op.operator == '-'
        deleteat!(box, lens_idx)
    else
        if isnothing(lens_idx)
            push!(box, op.lens)
        else
            box[lens_idx] = op.lens
        end
    end
end

function focalpower((idx, box)::Tuple{Int, Box})::Int
    if isempty(box) return 0 end
    enumerate(box) .|> (p -> idx * p[1] * p[2].focal_length) |> sum
end

solve1()
