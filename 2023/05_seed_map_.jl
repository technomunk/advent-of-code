include("utils.jl")

struct MappingRange
    src_start::Int
    dst_start::Int
    len::Int
end

struct RangeMap
    src_type::String
    dst_type::String

    ranges::Vector{MappingRange}
end

function solve()
    lines = readlines()
    seeds = Base.parse.(Int, split(chopprefix(lines[1], "seeds: ")))
    maps = parse.(RangeMap, filter!(x -> !isempty(x), spliton(lines[2:end], "")))
    solve1(seeds, maps)
    solve2(seeds, maps)
end

function solve1(seeds::Vector{Int}, maps::Vector{RangeMap})
    seeds .|> (s -> map(s, maps)) |> minimum |> println
end

function solve2(seed_ranges::Vector{Int}, maps::Vector{RangeMap})
    ranges = Iterators.partition(seed_ranges, 2) .|> (r -> r[1]:r[1]+r[2]-1)
    ranges .|> (r -> maprange(r, maps[1])) |> display
end

function in(item::Int, range::MappingRange)::Bool
    return item >= range.src_start && item < range.src_start + range.len
end

function map(item::Int, range::MappingRange)::Int
    if in(item, range)
        return range.dst_start + (item - range.src_start)
    end
    return item
end

function map(item::Int, map::RangeMap)::Int
    for range in map.ranges
        if in(item, range)
            return range.dst_start + (item - range.src_start)
        end
    end
    return item
end

function map(item::Int, maps::AbstractArray{RangeMap})::Int
    for m in maps
        item = map(item, m)
    end
    return item
end

function minmap(range::UnitRange, map::MappingRange)::UnitRange
    min(map(range[1], map), map(range[2], map))
end

function parse(::Type{RangeMap}, lines)::RangeMap
    src_type, dst_type = match(r"(\w+)-to-(\w+) map:", lines[1])

    ranges = parse.(MappingRange, lines[2:end])
    return RangeMap(src_type, dst_type, ranges)
end

function parse(::Type{MappingRange}, line::AbstractString)::MappingRange
    src_start, dst_start, len = Base.parse.(Int, match(r"(\d+) (\d+) (\d+)", line))
    return MappingRange(dst_start, src_start, len)
end

function maprange(r::UnitRange, range::MappingRange)::Vector{UnitRange}
    if in(r.start, range) && in(r.stop, range)
        return [range.dst_start+(r.start-range.src_start):range.dst_start+(r.stop-range.src_start)]
    elseif in(r.start, range)
        return [range.dst_start+(r.start-range.src_start):range.dst_start+range.len]
    elseif in(r.stop, range)
        return [range.dst_start:range.dst_start+(r.stop-range.src_start)]
    end
    return [r]
end
function maprange(r::UnitRange, m::RangeMap)::Vector{UnitRange}
    # for each range collect ranges, then merge overlapping ranges
    result = [r]
    for range in m.ranges
        result = vcat(maprange.(result, range)...)
    end
    return result
end

function mergeranges(rs::AbstractArray{UnitRange})::Vector{UnitRange}
    result = []
    for r in rs
        if isempty(result)
            push!(result, r)
        else
            last = result[end]
            if last.stop >= r.start
                result[end] = last.start:r.stop
            else
                push!(result, r)
            end
        end
    end
    return result
end

solve()
