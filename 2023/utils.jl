function takematch(re::Regex, s::AbstractString)::Tuple{Union{Regex,Nothing},SubString}
    m = match(re, s)
    return _take(m, s)
end

function matrix(lines::Vector{T})::Matrix{Char} where {T<:AbstractString}
    return reduce(vcat, permutedims.(collect.(lines)))
end

function neighborindicies(m::AbstractArray{T,N}, n::Int, i::Int)::UnitRange where {T,N}
    return max(1, i - 1):min(size(m, n), i + 1)
end

function _take(m::RegexMatch, s::AbstractString)::Tuple{Regex,SubString}
    s = SubString(s, m.offset + length(m.match) - 1)
    return m, s
end
function _take(m::Nothing, s::AbstractString)
    m, s
end
