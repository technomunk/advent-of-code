include("utils.jl")
include("geometry.jl")

Map = Matrix{Char}
Pt2 = Point2D{Int}
Steps = Matrix{Int}

const UNWALKED = -1
const STONE = -2

expected = 592_723_929_260_582

function solve()
    grid = matrix(readlines())
    count(isnthstep(64), steps(grid)) |> println
    printsteps(steps(grid))
    # solve2(grid, 26_501_365) |> println
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
               n * n * even_steps
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

function steps(grid::Map)::Steps
    step_indices = grid .|> (ch -> INIT_STEPS[ch])
    start = coordsof(grid, 'S')[1]
    steps::Vector{Tuple{Int,Pt2}} = [(0, start)]

    while !isempty(steps)
        step_idx, coord = popfirst!(steps)
        step_indices[coord] = step_idx
        for pt in neighborcoords(grid, coord, test=pt -> step_indices[pt] == UNWALKED)
            step_indices[coord] = step_idx + 1
            push!(steps, (step_idx + 1, pt))
        end
    end

    return step_indices
end

isnthstep(n::Int) = x -> (UNWALKED < x <= n) && isodd(x) == isodd(n)
isstep(parity) = x -> (x > UNWALKED) && parity(x)
takesmorethan(n::Int, parity) = x -> (x > n) && parity(x)

const STONE_STR = "\e[36m#"
const UNWALKED_STR = "\e[31m0"
const STEP_STR = "\e[32mx"
const EMPTY_STR = "\e[30m."

function printstep(grid::Matrix{Int}, n::Int)
    for row in eachrow(grid)
        for s in row
            if s == STONE
                print(STONE_STR)
            elseif s <= n && isodd(n) == isodd(s)
                print(STEP_STR)
            else
                print(EMPTY_STR)
            end
        end
        println()
    end
end
function printsteps(grid::Matrix{Int})
    for row in eachrow(grid)
        for s in row
            if s == STONE
                print(STONE_STR)
            elseif s == UNWALKED
                print(UNWALKED_STR)
            else
                print(STEP_STR)
            end
        end
        println()
    end
end

function floodfill!(grid::Map, n::Int)::Map
    steps::Vector{Pt2} = append!(coordsof(grid, 'S'), coordsof(grid, 'O'))
    next_steps = Vector{Pt2}()
    for _ in 1:n
        for step in steps, coord in neighborcoords(grid, step)
            if grid[coord] == '.'
                grid[coord] = 'O'
                push!(next_steps, coord)
            end
        end
        empty!(steps)
        append!(steps, next_steps)
        empty!(next_steps)
    end

    return grid
end

solve()
