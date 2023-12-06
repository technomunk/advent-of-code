function solve()
    lines = readlines() .|> l -> l[12:end]
    times, distances = lines .|> l -> parse.(Int, split(l))
    solve1(times, distances)
    time, distance = parse.(Int, replace.(lines, ' ' => ""))
    solve2(time, distance)
end

function solve1(times::AbstractVector{Int}, distances::AbstractVector{Int})
    countwintimes.(times, distances) |>
        prod |>
        println
end

function solve2(time::Int, distance::Int)
    countwintimes(time, distance) |> println
end

function countwintimes(time::Int, distance::Int)::Int
    t = 0
    while (time - t)*t <= distance
        t += 1
    end
    return length(t:(time-t))
end

solve()
