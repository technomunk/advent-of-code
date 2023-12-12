function solve()
    rows = parse.(Row, readlines())
    solve1(rows)
end

struct Row
    pattern::String
    counts::Vector{Int}
end

function solve1(rows::Vector{Row})
    rows .|>
        (r -> count(v -> fitscounts(v, r.counts), variations(r))) |>
        sum |>
        println
end

function parse(::Type{Row}, line::AbstractString)::Row
    pattern, counts = split(line, ' ')
    counts = Base.parse.(Int, split(counts, ','))
    return Row(pattern, counts)
end

function groups(pattern::AbstractString)
    filter(nonempty, split(pattern, '.'))
end
function groups(row::Row)
    groups(row.pattern)
end

function nonempty(x)
    !isempty(x)
end

function variations(row::Row)::Vector{String} variations(row.pattern) end
function variations(pattern::AbstractString)::Vector{String}
    result = Vector{String}()
    variations!(result, "", pattern)
    return result
end

function variations!(result::Vector{String}, acc::String, pattern::T) where {T <: AbstractString}
    if isempty(pattern)
        push!(result, acc)
        return
    end
    ch = first(pattern)
    if ch == '?'
        variations!(result, acc * '.', pattern[2:end])
        variations!(result, acc * '#', pattern[2:end])
    else
        variations!(result, acc * ch, pattern[2:end])
    end
end

function fitscounts(v::String, counts::Vector{Int})::Bool
    v_counts = length.(filter(nonempty, split(v, ".")))
    return v_counts == counts
end

solve()
