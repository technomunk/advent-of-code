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

solve2(time::Int, distance::Int) = countwintimes(time, distance) |> println

function countwintimes(time::Int, distance::Int)::Int
    for t = 0:time
        if (time - t)*t > distance
            return length(t:(time-t))
        end
    end
end

solve()
