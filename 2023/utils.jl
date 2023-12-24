function takematch(re::Regex, s::AbstractString)::Tuple{Union{RegexMatch,Nothing},SubString}
    m = match(re, s)
    return _take(m, s)
end

# 2D utilities

function matrix(lines::AbstractArray{T})::Matrix{Char} where {T<:AbstractString}
    return reduce(vcat, permutedims.(collect.(lines)))
end

function printgrid(m::Matrix{Char}; repl=identity)::Nothing
    for row in eachrow(m)
        for ch in row
            print(repl(ch))
        end
        println("\e[0m")
    end
end

function neighborindicies(m::AbstractArray{T,N}, n::Int, i::Int)::UnitRange where {T,N}
    return max(1, i - 1):min(size(m, n), i + 1)
end

function _take(m::RegexMatch, s::AbstractString)::Tuple{RegexMatch,SubString}
    s = SubString(s, m.offset + length(m.match) - 1)
    return m, s
end
function _take(m::Nothing, s::AbstractString)
    m, s
end

function spliton(i::AbstractArray{T}, delim::T)::Vector{SubArray{T}} where {T}
    result = []
    prev_index = 1
    for idx in findall(x -> x == delim, i)
        push!(result, view(i, prev_index:idx-1))
        prev_index = idx + 1
    end
    push!(result, view(i, prev_index:length(i)))
    return result
end

struct Pairs{T}
    a::AbstractArray{T}
end

function Base.iterate(p::Pairs{T})::Union{Tuple{Tuple{T,T},Tuple{Int,Int}}} where {T}
    if length(p.a) <= 1
        return nothing
    end
    return ((p.a[1], p.a[2]), (1, 3))
end
function Base.iterate(p::Pairs{T}, (a, b)::Tuple{Int,Int}) where {T}
    if b > lastindex(p.a)
        if a >= lastindex(p.a) - 1
            return nothing
        end
        a += 1
        b = a + 1
    end
    return ((p.a[a], p.a[b]), (a, b + 1))
end

function Base.length(p::Pairs{T})::Int where {T}
    # triangle number
    return div(length(p.a) * (length(p.a) - 1), 2)
end

function indexof(collection, element::T)::Union{Int,Nothing} where {T}
    for (i, el) in enumerate(collection)
        if el == element
            return i
        end
    end
    return nothing
end

function initvector(n::Int, ctor)::Vector
    result = Vector(undef, n)
    for i in eachindex(result)
        result[i] = ctor()
    end
    return result
end

Base.deleteat!(a::Vector{T}, ::Nothing) where {T} = identity

# A structure for efficiently fetching the element with the smallest priority
struct MinQueue{T,N<:Number}
    buckets::Vector{Tuple{N,Vector{T}}}
end
MinQueue{T,N}() where {T,N<:Number} = MinQueue(Vector{Tuple{N,Vector{T}}}())

function Base.push!(q::MinQueue{T,N}, val::T, prio::N)::MinQueue{T,N} where {T,N<:Number}
    idx = findfirst(b -> b[1] <= prio, q.buckets)
    if isnothing(idx)
        push!(q.buckets, (prio, [val]))
        return q
    end
    if q.buckets[idx][1] == prio
        push!(q.buckets[idx][2], val)
        return q
    end
    insert!(q.buckets, idx, (prio, [val]))
    return q
end
function Base.pop!(q::MinQueue{T})::Union{T,Nothing} where {T}
    if isempty(q.buckets)
        return Nothing
    end
    result = pop!(q.buckets[end][2])
    if isempty(q.buckets[end][2])
        pop!(q.buckets)
    end
    return result
end

Base.isempty(q::MinQueue)::Bool = isempty(q.buckets)

eq(val) = x -> x == val
