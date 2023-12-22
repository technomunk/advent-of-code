include("utils.jl")

HeightMap = Matrix{Int}
mutable struct Brick
    x::UnitRange{Int}
    y::UnitRange{Int}
    z::UnitRange{Int}

    Brick(ranges::Vector{UnitRange{Int}}) = new(ranges[1], ranges[2], ranges[3])
    Brick(x::UnitRange{Int},y::UnitRange{Int},z::UnitRange{Int}) = new(x, y, z)
end

function solve()
    bricks = parse.(Brick, readlines())
    drop!(bricks)
    neighborhood = calc_neighborhood(bricks)
    # part 1
    count(x -> isredundant(neighborhood, x), eachindex(bricks)) |> println
    # part 2
    chainlength.(Ref(neighborhood), eachindex(bricks)) |> sum |> println
end

max_x(brick::Brick)::Int = brick.x[end]
max_y(brick::Brick)::Int = brick.y[end]

Base.isless(a::Brick, b::Brick) = a.z < b.z

intersects(a::UnitRange, b::UnitRange)::Bool = a[end] ∈ b || a[1] ∈ b || b[1] ∈ a || b[end] ∈ a
intersects(a::Brick, b::Brick)::Bool = all(intersects.(a, b))

Base.broadcastable(b::Brick) = b.x, b.y, b.z

Base.to_index(m::Matrix, b::Brick) = CartesianIndices((b.y + 1, b.x + 1))
Base.to_index(s::Array{Any,3}, b::Brick) = CartesianIndices((b.z + 1, b.y + 1, b.x + 1))
function Base.:(+)(r::UnitRange{T}, v::T)::UnitRange{T} where {T<:Real}
    r[1]+v:r[end]+v
end
function Base.:(-)(r::UnitRange{T}, v::T)::UnitRange{T} where {T<:Real}
    r[1]-v:r[end]-v
end

function Base.parse(::Type{Brick}, s::AbstractString)::Brick
    mins, maxs = split(s, '~')
    mins = parse.(Int, split(mins, ','))
    maxs = parse.(Int, split(maxs, ','))
    return zip(mins, maxs) .|> (mm -> mm[1]:mm[2]) |> Brick
end

function drop!(bricks::AbstractVector{Brick})
    sort!(bricks)
    # assume 0-indexed ranges
    height = maximum(max_y, bricks) + 1
    width = maximum(max_x, bricks) + 1
    height_map = zeros(Int, height, width)
    for brick in bricks
        drop!(height_map, brick)
    end
end

function drop!(heights::HeightMap, brick::Brick)
    height_view = (@view heights[brick])
    height = maximum(height_view) + 1
    drop_height = brick.z[1] - height
    brick.z -= drop_height
    for i in eachindex(height_view)
        height_view[i] = brick.z[end]
    end
end

function supports(a::Brick, b::Brick)::Bool
    return a.z[end] + 1 == b.z[1] && intersects(a.x, b.x) && intersects(a.y, b.y)
end

struct Neighborhood
    bricks_above::Dict{Int,Set{Int}}
    bricks_below::Dict{Int,Set{Int}}
end

function calc_neighborhood(bricks::AbstractVector{Brick})::Neighborhood
    bricks_above = Dict{Int,Set{Int}}()
    bricks_below = Dict{Int,Set{Int}}()

    for (a, b) in Pairs(eachindex(bricks))
        if a == b
            continue
        end
        if supports(bricks[a], bricks[b])
            push!(get!(bricks_above, a, Set()), b)
            push!(get!(bricks_below, b, Set()), a)
        elseif supports(bricks[b], bricks[a])
            push!(get!(bricks_above, b, Set()), a)
            push!(get!(bricks_below, a, Set()), b)
        end
    end
    return Neighborhood(bricks_above, bricks_below)
end

function isredundant(n::Neighborhood, i::Int)::Bool
    if i ∉ keys(n.bricks_above)
        return true
    end
    for supported_index in n.bricks_above[i]
        if length(n.bricks_below[supported_index]) == 1
            return false
        end
    end
    return true
end

function chainlength(n::Neighborhood, i::Int)::Int
    missing_bricks = Set{Int}(i)
    queue = [i]
    while !isempty(queue)
        missing_i = pop!(queue)
        for supported_i in get(n.bricks_above, missing_i, [])
            if isempty(filter(x -> x ∉ missing_bricks, n.bricks_below[supported_i]))
                push!(missing_bricks, supported_i)
                push!(queue, supported_i)
            end
        end
    end
    return length(missing_bricks) - 1  # technically the first brick is destoyed
end


solve()
