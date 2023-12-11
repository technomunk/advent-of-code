include("utils.jl")

function solve()
    grid = matrix(readlines())
    gals = galaxies(grid)
    solve1(grid, gals)
    solve2(grid, gals)
end

Coord = Tuple{Int, Int}

function galaxies(grid::Matrix{Char})::Vector{Coord}
    result = Vector{Coord}()
    for (x, col) in enumerate(eachcol(grid))
        for (y, ch) in enumerate(col)
            if ch == '#'
                push!(result, (x, y))
            end
        end
    end
    return result
end

function solve1(grid::Matrix{Char}, gals::Vector{Coord})
    gals = expand(gals, grid, 1)
    println(sum(Pairs(gals) .|> p -> dist(p...)))
end
function solve2(grid::Matrix{Char}, gals::Vector{Coord})
    gals = expand(gals, grid, 999999)
    println(sum(Pairs(gals) .|> p -> dist(p...)))
end

function expand(gals::Vector{Coord}, grid::Matrix{Char}, amount::Int)::Vector{Coord}
    expand!(copy(gals), grid, amount)
end
function expand!(gals::Vector{Coord}, grid::Matrix{Char}, amount::Int)::Vector{Coord}
    expanded_cols = Vector{Int}()
    for (x, col) in enumerate(eachcol(grid))
        if all(ch -> ch == '.', col)
            push!(expanded_cols, x)
        end
    end
    expanded_rows = Vector{Int}()
    for (y, row) in enumerate(eachrow(grid))
        if all(ch -> ch == '.', row)
            push!(expanded_rows, y)
        end
    end
    for i in eachindex(gals)
        (x, y) = gals[i]
        x += count(n -> n < x, expanded_cols) * amount
        y += count(n -> n < y, expanded_rows) * amount
        gals[i] = (x, y)
    end
    return gals
end

function dist(a::Coord, b::Coord)::Int
    return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

solve()
