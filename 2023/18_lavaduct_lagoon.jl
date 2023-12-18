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

struct Operation
    dir::Direction
    len::Int
    color::Color
end
Base.:(+)(p::Point2, op::Operation)::Point2 = p .+ delta(op.dir) .* op.len

function Base.parse(::Type{Operation}, l::AbstractString)::Operation
    dir, len, color = split(l, ' ')
    return Operation(parse(Direction, dir), parse(Int, len), @view color[2:end-1])
end

mutable struct Polygon
    vertices::Vector{Tuple{Point2,Union{Color,Nothing}}}
    min_x::Int
    min_y::Int
    max_x::Int
    max_y::Int
end

Polygon() = Polygon([((0, 0), nothing)], 0, 0, 0, 0)

Base.last(p::Polygon)::Point2 = last(p.vertices)[1]
Base.isempty(p::Polygon)::Bool = length(p.vertices) <= 1

function linecount(p::Polygon)::Int
    return length(p.vertices) - 1
end
function Base.push!(p::Polygon, o::Operation)
    x, y = last(p) + o
    p.max_x = max(p.max_x, x)
    p.min_x = min(p.min_x, x)
    p.max_y = max(p.max_y, y)
    p.min_y = min(p.min_y, y)
    push!(p.vertices, ((x, y), o.color))
end
function Base.:(∈)(pt::Point2, p::Polygon)
    intersections = 0
    for line in Lines(p)
        if pt ∈ line
            return true
        end
        intersections += isunder(pt, line)
    end
    return intersections % 2 == 1
end

function area(p::Polygon)::Int
    result = Threads.Atomic{Int}(0)
    Threads.@threads for y = p.min_y:p.max_y
        for x = p.min_x:p.max_x
            Threads.atomic_add!(result, Int((x, y) ∈ p))
        end
    end
    return result[]
end

Base.setindex!(m::AbstractMatrix{T}, v::T, (y, x)::Point2) where {T} = m[y, x] = v
function draw(p::Polygon)
    grid = [' ' for _ in p.min_y:p.max_y, _ in p.min_x:p.max_x]
    function togrididx((x, y)::Point2)::Point2
        return (p.max_y - y + 1, x - p.min_x + 1)
    end
    for y = p.min_y:p.max_y
        for x = p.min_x:p.max_x
            if (x, y) ∈ p
                grid[togrididx((x, y))] = '#'
            end
        end
    end
    for line in Lines(p)
        for pt in line
            grid[togrididx(pt)] = 'X'
        end
    end
    println.(String.(eachrow(grid)))
end

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
    v1 = l.p.vertices[i+0][1]
    v2 = l.p.vertices[i+1][1]
    col = l.p.vertices[i+1][2]
    return (Line(v1, v2 .- v1, col), i + 1)
end

struct Line
    o::Point2
    d::Point2
    color::Color
end

Base.min(l::Line)::Point2 = min.(l.o, l.o .+ d)
Base.max(l::Line)::Point2 = max.(l.o, l.o .+ d)

function isunder(pt::Point2, l::Line)::Bool
    if l.d[1] == 0  # line is vetical, ignore those
        return false
    end

    min_x = min(l.o[1], l.o[1] + l.d[1])
    max_x = max(l.o[1], l.o[1] + l.d[1])
    # to avoid column double-counting ignore the right edge of each line
    return min_x <= pt[1] < max_x && l.o[2] >= pt[2]
end
function Base.:(∈)(l::Line, pt::Point2)::Bool
    min_x, min_y = min(l)
    max_x, max_y = max(l)
    return min_x <= pt[1] <= max_x && min_y <= pt[2] <= max_y
end

Base.length(l::Line)::Int = sum(abs.(l.d))
Base.iterate(l::Line) = iterate(l, 0)
function Base.iterate(l::Line, i::Int)::Union{Tuple{Point2,Int},Nothing}
    if i == length(l)
        return nothing
    end
    dir = sign.(l.d)
    return (l.o .+ dir .* i, i + 1)
end


# high level solution

function solve()
    operations = parse.(Operation, readlines())
    solve1(operations)
end

function solve1(ops::AbstractVector{Operation})
    polygon = Polygon()
    for op in ops
        push!(polygon, op)
    end
    # draw(polygon)
    println(area(polygon))
end

solve()
