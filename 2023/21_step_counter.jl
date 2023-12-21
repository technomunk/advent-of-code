include("utils.jl")

Map = Matrix{Char}
Point = Tuple{Int,Int}

function solve()
    grid = matrix(readlines())
    count(isnthstep(64), steps(grid, 64)) |> println
    # count(isnthstep(26501365), steps(grid, 26501365)) |> println
end

function steps(grid::Map, n::Int, nfn = neighborcoords)::Matrix{Union{Int,Nothing}}
    step_indices = grid .|> (ch -> ch ∈ ".S" ? 0 : nothing)
    steps = coordsof(grid, 'S')
    next_steps = Vector{Point}()

    max_steps = min(n, prod(size(grid)))

    for i in 1:max_steps
        for step in steps
            for (y, x) in nfn(grid, step)
                if step_indices[y, x] == 0
                    step_indices[y, x] = i
                    push!(next_steps, (y, x))
                end
            end
        end
        empty!(steps)
        append!(steps, next_steps)
        empty!(next_steps)
    end

    return step_indices
end

function countsteps(steps::Matrix{Union{Int,Nothing}}, n::Int)::Int
end

isnthstep(n::Int) = x -> !isnothing(x) && (x > 0) && isodd(x) == isodd(n)

function printstep(grid::Matrix{Union{Int,Nothing}}, n::Int)
    for row in eachrow(grid)
        for s in row
            if isnothing(s)
                print('#')
            elseif s > 0 && isodd(n) == isodd(s)
                print('O')
            else
                print('.')
            end
        end
        println()
    end
end

function floodfill!(grid::Map, n::Int)::Map
    steps::Vector{Point} = append!(coordsof(grid, 'S'), coordsof(grid, 'O'))
    next_steps = Vector{Point}()
    for _ in 1:n
        for step in steps
            for (y, x) in neighborcoords(grid, step)
                if grid[y, x] == '.'
                    grid[y, x] = 'O'
                    push!(next_steps, (y, x))
                end
            end
        end
        empty!(steps)
        append!(steps, next_steps)
        empty!(next_steps)
    end

    return grid
end

solve()
