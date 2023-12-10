include("utils.jl")

function solve()
    lines = readlines()
    seeds = Base.parse.(Int, split(chopprefix(lines[1], "seeds: ")))
    maps = parse.(Vector{RangeMap}, filter!(x -> !isempty(x), spliton(lines[2:end], "")))
    solve1(seeds, maps)
    bruteforce2(seeds, maps)
    # solve2(seeds, maps)
end

struct RangeMap
    src::UnitRange
    dst::Int
end
mutable struct SparseRange
    subranges::Vector{UnitRange}
end

function solve1(seeds::Vector{Int}, maps::Vector{Vector{RangeMap}})
    seeds .|>
    (s -> apply(maps, s)) |>
    minimum |>
    println
end
function bruteforce2(seeds::Vector{Int}, maps::Vector{Vector{RangeMap}})
    ranges = Iterators.partition(seeds, 2) .|> (p -> p[1]:p[1]+p[2]-1)
    min_val = 2^62
    for (i, r) in enumerate(ranges)
        for i in r
            min_val = min(apply(maps, i), min_val)
        end
        print("\rDone with range $i")
    end
    println()
    println(min_val)
end
function solve2(seeds::Vector{Int}, maps::Vector{Vector{RangeMap}})
    ranges = Iterators.partition(seeds, 2) .|> (p -> SparseRange([p[1]:p[1]+p[2]-1]))
    ranges .|>
        (r -> apply!(maps, r)) |>
        # minimum |>
        display
end

function parse(::Type{RangeMap}, line::AbstractString)::RangeMap
    dst_start, src_start, len = Base.parse.(Int, match(r"(\d+) (\d+) (\d+)", line))
    return RangeMap(src_start:(src_start+len-1), dst_start)
end
function parse(::Type{Vector{RangeMap}}, lines)::Vector{RangeMap}
    parse.(RangeMap, lines[2:end])
end

function apply(maps::Vector{RangeMap}, val::Int)::Int
    for m in maps
        if val ∈ m.src
            return m.dst + val - m.src[1]
        end
    end
    return val
end
function apply(maps::AbstractVector{Vector{RangeMap}}, val::Int)::Int
    for m in maps
        val = apply(m, val)
    end
    return val
end

function apply!(maps::AbstractVector{Vector{RangeMap}}, range::SparseRange)::SparseRange
    for m in maps
        apply!(m, range)
    end
    return range
end
function apply!(maps::Vector{RangeMap}, range::SparseRange)::SparseRange
    for m in maps
        apply!(m, range)
    end
    return range
end
function apply!(m::RangeMap, range::SparseRange)::SparseRange
    ranges = Vector{UnitRange}()
    for r in range.subranges
        append!(ranges, apply(m, r))
    end
    range.subranges = mergeoverlaps!(ranges)
    return range
end
function apply(m::RangeMap, range::UnitRange)::Vector{UnitRange}
    # handle no-intersections
    if range[end] < m.src[1] || range[1] > m.src[end]
        return [range]
    end
    result = []
    if range[1] < m.src[1]
        push!(result, range[1]:(m.src[1]-1))
    end
    # push the mapped range
    mapped_offset = max(m.src[1], range[1]) - m.src[1]
    mapped_start = m.dst + mapped_offset
    mapped_length = min(range[end], m.src[end]) - max(m.src[1], range[1])
    mapped_end = mapped_start + mapped_length
    push!(result, mapped_start:mapped_end)
    if range[end] > m.src[end]
        push!(result, m.src[end]+1:range[end])
    end
    return result
end

function mergeoverlaps!(ranges::Vector{UnitRange})::Vector{UnitRange}
    sort!(ranges)
    last_index = 1
    for i = 2:lastindex(ranges)
        if ranges[i][1] ∈ ranges[last_index]
            ranges[last_index] = ranges[last_index][1]:ranges[i][end]
        else
            last_index += 1
            ranges[last_index] = ranges[i]
        end
    end
    keepat!(ranges, 1:last_index)
    return ranges
end

function Base.length(r::SparseRange)::Int sum(length.(r.subranges)) end
function Base.first(r::SparseRange)::Int r.subranges[1][1] end

function test()
    sr = SparseRange([1:10])
    println("|$sr| == $(length(sr))")
    rms = [RangeMap(0:5, 20), RangeMap(6:10, 30)]
    apply!(rms, sr)
    println("|$sr| == $(length(sr))")
end

# test()
solve()
