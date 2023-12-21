include("utils.jl")

Map = Matrix{Char}
Point = Tuple{Int,Int}
Steps = Matrix{Int}

const UNWALKED = 0
const STONE = -1


function solve()
    grid = matrix(readlines())
    count(isnthstep(64), steps(grid, 'S')) |> println
    solve2(grid) |> println
end

Base.Enums.@enum GridDir begin
    CENTER
    NORTH
    NORTH_EAST
    EAST
    SOUTH_EAST
    SOUTH
    SOUTH_WEST
    WEST
    NORTH_WEST
end

const TOTAL_STEPS = 26501365

function solve2(grid::Map)::Int
    # Observation: the column and row with the start in the real input are empty
    # which means that reaching a neighboring grid clone takes (size(grid).-1) ./ 2 steps
    height, width = size(grid)
    start_y, start_x = coordof(grid, 'S')

    north_steps = start_y - 1
    south_steps = height - start_y
    east_steps = width - start_x
    west_steps = start_x - 1

    step_indices = Dict{GridDir,Steps}(
        CENTER => steps(grid, (start_y, start_x)),
        NORTH => steps(grid, (height, start_x)), # start at bottom center
        NORTH_EAST => steps(grid, (height, 1)),  # start at bottom left
        EAST => steps(grid, (start_y, 1)),  # start at center left
        SOUTH_EAST => steps(grid, (1, 1)),  # start at top left
        SOUTH => steps(grid, (1, start_x)),  # start at top center
        SOUTH_WEST => steps(grid, (1, width)),  # start at top right
        WEST => steps(grid, (start_y, width)),  # start at center right
        NORTH_WEST => steps(grid, (height, width)),  # start at bottom right
    )

    # map the direction of the grid with its relevant neighbors and the number of steps to reach said neighbor
    # the "relevant" neighbors are chosen such that there is only 1 way to reach a given neighbor (except from center)
    neighbors = Dict{GridDir,Vector{Tuple{GridDir,Int}}}(
        CENTER => [(NORTH, north_steps), (EAST, east_steps), (SOUTH, south_steps), (WEST, west_steps)],
        NORTH => [(NORTH_WEST, west_steps), (NORTH, height)],
        NORTH_EAST => [(NORTH_EAST, height)],
        EAST => [(NORTH_EAST, north_steps), (EAST, width)],
        SOUTH_EAST => [(SOUTH_EAST, width)],
        SOUTH => [(SOUTH_EAST, east_steps), (SOUTH, height)],
        SOUTH_WEST => [(SOUTH_WEST, height)],
        WEST => [(SOUTH_WEST, south_steps), (WEST, width)],
        NORTH_WEST => [(NORTH_WEST, width)],
    )

    reachable_plots = 0

    grids = [(CENTER, 0)]
    next_grids = []

    last_printed_threshold = 0

    while !isempty(grids)
        empty!(next_grids)
        for (dir, made_steps) in grids
            reachable_plots += count(isnthstep(TOTAL_STEPS - made_steps), step_indices[dir])
            for (neighbor_dir, dist_to_neighbor) in neighbors[dir]
                steps_to_neighbor = made_steps + dist_to_neighbor
                if made_steps + dist_to_neighbor < TOTAL_STEPS
                    push!(next_grids, (neighbor_dir, steps_to_neighbor))
                end
                if steps_to_neighbor - last_printed_threshold >= 1000
                    print("\r$steps_to_neighbor steps")
                    last_printed_threshold = steps_to_neighbor
                end
            end
        end
        empty!(grids)
        append!(grids, next_grids)
    end
    println()

    return reachable_plots
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

isnthstep(n::Int) = x -> (0 < x <= n) && isodd(x) == isodd(n)

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
