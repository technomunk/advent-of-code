function takematch(re::Regex, s::AbstractString)::Tuple{Union{RegexMatch,Nothing},SubString}
    m = match(re, s)
    return _take(m, s)
end

function matrix(lines::Vector{T})::Matrix{Char} where {T<:AbstractString}
    return reduce(vcat, permutedims.(collect.(lines)))
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
        push!(result, view(i, prev_index:idx - 1))
        prev_index = idx + 1
    end
    push!(result, view(i, prev_index:length(i)))
    return result
end

struct Pairs{T}
    a::AbstractArray{T}
end

function Base.iterate(p::Pairs{T})::Union{Tuple{Tuple{T, T}, Tuple{Int, Int}}} where {T}
    if length(p.a) <= 1
        return nothing
    end
    return ((p.a[1], p.a[2]), (1, 3))
end
function Base.iterate(p::Pairs{T}, (a, b)::Tuple{Int, Int}) where {T}
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
