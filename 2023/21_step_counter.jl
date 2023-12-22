include("utils.jl")

Map = Matrix{Char}
Point = Tuple{Int,Int}
Steps = Matrix{Int}

const UNWALKED = 0
const STONE = -1


function solve()
    grid = matrix(readlines())
    count(isnthstep(64), steps(grid, 'S')) |> println
    solve2(grid, 26_501_365) |> println
end

function solve2(grid::Map, total_steps::Int)::Int
    step_indices = steps(grid, 'S')
    grid_size = size(grid)[1]

    even_corners = count(takesmorethan(grid_size ÷ 2, iseven), step_indices)
    odd_corners = count(takesmorethan(grid_size ÷ 2, isodd), step_indices)
    even_steps = count(isstep(iseven), step_indices)
    odd_steps = count(isstep(isodd), step_indices)

    n = (total_steps - grid_size ÷ 2) ÷ grid_size

    # the clones form a diamond, with repeating odd-even layers
    # as a diamond is a rotated square - there are a square number of grids we
    # are inerested in. N is the number of grids in one direction, ie
    # half the length of the square
    if iseven(n)
        return (n + 1) * n * odd_steps +
               n * n * even_steps -
               (n + 1) * odd_corners +
               n * even_corners
    else
        return (n + 1) * n * even_steps +
               n * n * odd_steps -
               (n + 1) * even_corners +
               n * odd_corners
    end
end

const INIT_STEPS = Dict{Char,Int}(
    '.' => UNWALKED,
    'S' => UNWALKED,
    'O' => UNWALKED,
    '#' => STONE,
)

function steps(grid::Map, start::Union{Point,Char})::Steps
    step_indices = grid .|> (ch -> INIT_STEPS[ch])
    steps::Vector{Point} = isa(start, Char) ? coordsof(grid, start) : [start]
    next_steps = Vector{Point}()

    step_index = 0
    while !isempty(steps)
        step_index += 1
        empty!(next_steps)
        for step in steps
            for (y, x) in neighborcoords(grid, step)
                if step_indices[y, x] == UNWALKED
                    step_indices[y, x] = step_index
                    push!(next_steps, (y, x))
                end
            end
        end
        empty!(steps)
        append!(steps, next_steps)
    end

    return step_indices
end

isnthstep(n::Int) = x -> (x != STONE) && (x <= n) && isodd(x) == isodd(n)
isstep(parity) = x -> (x != STONE) && parity(x)
takesmorethan(n::Int, parity) = x -> (x != STONE) && (x > n) && parity(x)

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
