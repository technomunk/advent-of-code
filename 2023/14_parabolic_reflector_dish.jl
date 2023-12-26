include("utils.jl")

function solve()
    grid = matrix(readlines())
    solve1(grid)
    solve2(grid)
end

function solve1(grid::Matrix{Char})
    tiltup(grid) |> calcload |> println
end

function solve2(grid::Matrix{Char})
    grids = Vector{Matrix{Char}}()
    i = 1
    while i < 1000000000
        tiltcycle!(grid)
        push!(grids, copy(grid))
        gi = indexof((@view grids[1:end-1]), grid)
        if isnothing(gi)
            i += 1
        else
            period = i - gi
            i = 1000000000 - mod(1000000000 - i, period)
            break
        end
    end
    while i < 1000000000
        tiltcycle!(grid)
        i += 1
    end
    println(calcload(grid))
end

tiltcycle!(grid) = grid |> tiltup! |> tiltleft! |> tiltdown! |> tiltright!

function tiltup(grid::Matrix{Char})
    tiltup!(copy(grid))
end

function tiltup!(grid::Matrix{Char})::Matrix{Char}
    tilt!(eachcol(grid))
    return grid
end
function tiltleft!(grid::Matrix{Char})
    tilt!(eachrow(grid))
    return grid
end
function tiltdown!(grid::Matrix{Char})
    cols = reverse!.(eachcol(grid))
    tilt!(cols)
    reverse!.(cols)
    return grid
end
function tiltright!(grid::Matrix{Char})
    rows = reverse!.(eachrow(grid))
    tilt!(rows)
    reverse!.(rows)
    return grid
end

function tilt!(cols)
    for col in cols
        empty_idx = 1
        for i in eachindex(col)
            if col[i] == 'O'
                if i > empty_idx
                    col[empty_idx] = 'O'
                    col[i] = '.'
                    empty_idx += 1
                elseif i == empty_idx
                    empty_idx = i + 1
                end
            elseif col[i] == '#'
                empty_idx = i + 1
            elseif empty_idx > i
                i = empty_idx
            end
        end
    end
end

function calcload(grid::Matrix{Char})::Int
    result = 0
    for (i, row) in enumerate(reverse(eachrow(grid)))
        result += count(ch -> ch == 'O', row) * i
    end
    return result
end

solve()
