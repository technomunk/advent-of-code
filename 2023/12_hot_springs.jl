function solve()
    rows = parse.(Row, readlines())
    solve1(rows)
    solve2(rows)
end

struct Row
    pattern::String
    counts::Vector{Int}
end

function solve1(rows::Vector{Row})
    solverows(rows)
end
function solve2(rows::Vector{Row})
    solverows(rows, x5)
end

function solverows(rows::Vector{Row}, proc=identity)
    completed_rows = Threads.Atomic{Int}(0)
    total = Threads.Atomic{Int}(0)
    Threads.@threads for row in rows
        Threads.atomic_add!(total, groups(proc(row)))
        Threads.atomic_add!(completed_rows, 1)
        print("\r$(completed_rows[])/$(length(rows)) done")
    end
    println()
    println(total[])
end


function x5(row::Row)::Row
    Row(join(repeat([row.pattern], 5), '?'), repeat(row.counts, 5))
end

function parse(::Type{Row}, line::AbstractString)::Row
    pattern, counts = split(line, ' ')
    counts = Base.parse.(Int, split(counts, ','))
    return Row(pattern, counts)
end

struct State
    pattern_index::Int
    counts_index::Int
    run_length::Int
end

onhash(s::State) = State(s.pattern_index + 1, s.counts_index, s.run_length + 1)
ondot(s::State) = State(s.pattern_index + 1, s.counts_index + (s.run_length > 0), 0)

function isvalid(state::State, row::Row)::Bool
    return state.run_length <= row.counts[state.counts_index]
end

function groups!(cache::Dict{State,Int}, row::Row, state::State)::Int
    if state.counts_index > lastindex(row.counts)
        return '#' ∉ @view row.pattern[state.pattern_index:end]
    end
    if state.pattern_index > lastindex(row.pattern)
        return state.counts_index == lastindex(row.counts) && state.run_length == row.counts[state.counts_index]
    end

    result = get(cache, state, nothing)
    if !isnothing(result)
        return result
    end

    if !isvalid(state, row)
        return 0
    end

    ch = row.pattern[state.pattern_index]
    result = 0
    if ch == '?'
        # assume #
        if state.run_length < row.counts[state.counts_index]
            result = groups!(cache, row, onhash(state))
        end
        # assume .
        if state.run_length == 0 || state.run_length == row.counts[state.counts_index]
            result += groups!(cache, row, ondot(state))
        end
    elseif ch == '.'
        if state.run_length == 0 || state.run_length == row.counts[state.counts_index]
            result = groups!(cache, row, ondot(state))
        end
    else
        if state.run_length < row.counts[state.counts_index]
            result = groups!(cache, row, onhash(state))
        end
    end

    cache[state] = result
    return result
end
groups(r::Row) = groups!(Dict{State,Int}(), r, State(1, 1, 0))

solve()
