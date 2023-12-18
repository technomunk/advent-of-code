Color = SubString
Point2 = Tuple{Int,Int}

Base.Enums.@enum Direction up down left right
function delta(d::Direction)
    if d == up
        return (0, 1)
    elseif d == down
        return (0, -1)
    elseif d == left
        return (-1, 0)
    else
        return (1, 0)
    end
end

function Base.parse(::Type{Direction}, s::AbstractString)::Direction
    if s == "U"
        return up
    elseif s == "D"
        return down
    elseif s == "L"
        return left
    else
        return right
    end
end
function parsehex(::Type{Direction}, ch::Char)::Direction
    if ch == '3'
        return up
    elseif ch == '1'
        return down
    elseif ch == '2'
        return left
    else
        return right
    end
end

struct Operation
    dir::Direction
    len::Int
end
Base.:(+)(p::Point2, op::Operation)::Point2 = p .+ delta(op.dir) .* op.len

function Base.parse(::Type{Tuple{Operation,SubString}}, l::AbstractString)::Tuple{Operation,SubString}
    dir, len, color = split(l, ' ')
    return Operation(parse(Direction, dir), parse(Int, len)), @view color[2:end-1]
end
function parsehex(::Type{Operation}, l::AbstractString)
    return Operation(parsehex(Direction, l[end]), parse(Int, l[2:end-1], base=16))
end

mutable struct Polygon
    vertices::Vector{Point2}
end

Polygon() = Polygon([(0, 0)])

Base.last(p::Polygon)::Point2 = last(p.vertices)
Base.isempty(p::Polygon)::Bool = length(p.vertices) <= 1

function linecount(p::Polygon)::Int
    return length(p.vertices) - 1
end
function Base.push!(p::Polygon, o::Operation)
    push!(p.vertices, last(p) + o)
end

Line = Tuple{Point2, Point2}

function area(p::Polygon, linearea)
    # https://en.wikipedia.org/wiki/Shoelace_formula
    result = 0.0
    for line in Lines(p)
        result += linearea(line) + length(line) / 2
    end
    return result
end
function counterclockwisearea(l::Line)
    x1, y1 = l[1]
    x2, y2 = l[2]
    return ((x1*y2 - y1*x2) / 2)
end
function clockwisearea(l::Line)
    x2, y2 = l[1]
    x1, y1 = l[2]
    return ((x1*y2 - y1*x2) / 2)
end
Base.length(l::Line)::Int = sum(abs.(l[2] .- l[1]))

struct Lines
    p::Polygon
end
function Base.iterate(l::Lines)::Union{Tuple{Line,Int},Nothing}
    if isempty(l.p)
        return nothing
    end
    return iterate(l, 1)
end
function Base.iterate(l::Lines, i::Int)::Union{Tuple{Line,Int},Nothing}
    if i + 1 > lastindex(l.p.vertices)
        return nothing
    end
    return ((l.p.vertices[i], l.p.vertices[i+1]), i+1)
end

# high level solution

function solve()
    operations = parse.(Tuple{Operation,SubString}, readlines())
    area(operations .|> o -> o[1]) |> println
    area(operations .|> o -> parsehex(Operation, o[2])) |> println
end

function area(ops::AbstractVector{Operation})::Int
    polygon = Polygon()
    for op in ops
        push!(polygon, op)
    end
    return max(area(polygon, counterclockwisearea), area(polygon, clockwisearea)) + 1
end

# println(counterclockwisearea(((1, 6), (3, 1))))
solve()
