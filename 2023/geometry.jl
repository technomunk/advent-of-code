abstract type Point{T<:Number,N} end

struct Point2D{T<:Number} <: Point{T,2}
    x::T
    y::T
end
struct Point3D{T<:Number} <: Point{T,3}
    x::T
    y::T
    z::T
end

Point{T,2}(x::T, y::T) where {T} = Point2D(x, y)
Point{T,3}(x::T, y::T, z::T) where {T} = Point3D(x, y, z)

struct Rect{T<:Number,N}
    min_corner::Point{T,N}
    max_corner::Point{T,N}
end
Rect2D{T<:Number} = Rect{T,2}
Rect3D{T<:Number} = Rect{T,3}

Base.iterate(p::Point2D{T}) where {T} = (p.x, p.y)
Base.iterate(::Point2D{T}, state::T) where {T} = (state, nothing)

Base.iterate(p::Point3D{T}) where {T} = (p.x, 1)
function Base.iterate(p::Point3D{T}, state::Int)::Union{Tuple{T,Int},Nothing} where {T}
    if state == 1
        return (p.y, 2)
    elseif state == 2
        return (p.z, 3)
    end
    return nothing
end

Base.convert(::Type{Point2D{T}}, (x, y)::NamedTuple{(:x, :y),Tuple{T,T}}) where {T} = Point2D(x, y)
Base.convert(::Type{Point3D{T}}, (x, y, z)::NamedTuple{(:x, :y, :z),Tuple{T,T,T}}) where {T} = Point3D(x, y, z)
Base.convert(::Type{Point2D{T}}, (x, y, _)::Point3D{T}) where {T} = Point2D(x, y)

Base.show(io::IO, p::Point2D{T}) where {T} = print(io, "(x=$(p.x), y=$(p.y))")
Base.show(io::IO, p::Point3D{T}) where {T} = print(io, "(x=$(p.x), y=$(p.y), z=$(p.z))")

Base.broadcastable(p::Point2D{T}) where {T} = (p.x, p.y)
Base.broadcastable(p::Point3D{T}) where {T} = (p.x, p.y, p.z)

Base.:(+)(a::Point{T,N}, b::Point{T,N}) where {T,N} = Point{T,N}((a .+ b)...)
Base.:(-)(a::Point{T,N}, b::Point{T,N}) where {T,N} = Point{T,N}((a .- b)...)
Base.:(<)(a::Point{T,N}, b::Point{T,N}) where {T,N} = all(a .< b)
Base.:(<=)(a::Point{T,N}, b::Point{T,N}) where {T,N} = all(a .<= b)
Base.:(>)(a::Point{T,N}, b::Point{T,N}) where {T,N} = all(a .> b)
Base.:(>=)(a::Point{T,N}, b::Point{T,N}) where {T,N} = all(a .>= b)
Base.:(/)(a::Point{T,N}, b::T) where {T,N} = Point{T,N}((a ./ Ref(b))...)

Base.to_index(::AbstractArray{T,3}, p::Point3D{Int}) where {T} = CartesianIndex(p.z, p.y, p.x)
Base.to_index(::AbstractArray{T,2}, p::Point2D{Int}) where {T} = CartesianIndex(p.y, p.x)

Base.:(∈)(p::Point{T,N}, r::Rect{T,N}) where {T,N} = all(r.min_corner .<= p .<= r.max_corner)

norm2(p::Point2D{T}) where {T} = p.x^2 + p.y^2
norm2(p::Point3D{T}) where {T} = p.x^2 + p.y^2 + p.z^2

norm(p::Point{T,N}) where {T,N} = sqrt(norm2(p))

dot(a::Point3D{T}, b::Point3D{T}) where {T} = a.x * b.x + a.y * b.y + a.z * b.z
cross(a::Point3D{T}, b::Point3D{T}) where {T} = Point3D(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
crossmatrix(p::Point3D{T}) where {T} = [0 -p.z p.y; p.z 0 -p.x; -p.y p.x 0]

function coordof(m::Matrix{T}, val::T)::Union{Point2D{Int},Nothing} where {T}
    h, w = size(m)
    for y = 1:h, x in 1:w
        if m[y, x] == val
            return (x=x, y=y)
        end
    end
    return nothing
end
function coordsof(m::Matrix{T}, val::T)::Vector{Point2D{Int}} where {T}
    result = Vector{Point2D}()
    h, w = size(m)
    for y = 1:h, x in 1:w
        if m[y, x] == val
            push!(result, (x=x, y=y))
        end
    end
    return result
end

function neighborcoords(m::Matrix, (y, x)::Point2D{Int}; test=_ -> true)::Vector{Point2D{Int}}
    result = Vector{Point2D}()
    h, w = size(m)
    if x > 1 && test((y=y, x=x - 1))
        push!(result, (y=y, x=x - 1))
    end
    if x < w && test((y=y, x=x + 1))
        push!(result, (y=y, x=x + 1))
    end
    if y > 1 && test((y=y - 1, x=x))
        push!(result, (y=y - 1, x=x))
    end
    if y < h && test((y=y + 1, x=x))
        push!(result, (y=y + 1, x=x))
    end
    return result
end