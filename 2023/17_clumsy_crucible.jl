include("utils.jl")

using Printf

function solve()
    grid = parse.(Int, matrix(readlines()))
    solve1(grid)
    solve2(grid)
end

Grid = Matrix{Int}
Point2 = Tuple{Int,Int}

function solve1(grid::Grid)
    pathcost(grid, 1, 3) |> println
end
function solve2(grid::Grid)
    pathcost(grid, 4, 10) |> println
end

const INT_INF = 2^62

Base.Enums.@enum Direction horizontal vertical
Node = Tuple{Int,Int,Direction}
other(dir::Direction) = dir == horizontal ? vertical : horizontal

function pathcost(grid::Grid, min_step::Int, max_step::Int)::Int
    # Use Dijkstra's assuming each vertex is connected to 6 neighbors
    # that are perpendicular to the direction they were reached from
    # First point is a special case where both directions are allowed
    costs = Dict{Node,Int}((1, 1, horizontal) => 0, (1, 1, vertical) => 0)
    visited = Set{Node}()
    prev = Dict{Node,Node}()
    to_visit = MinQueue{Node,Int}()
    push!(to_visit, (1, 1, horizontal), 0)
    push!(to_visit, (1, 1, vertical), 0)
    height, width = size(grid)

    function updatecost(n::Node, cost::Int, p::Node)
        old_cost = get(costs, n, INT_INF)
        if old_cost > cost
            costs[n] = cost
            prev[n] = p
            return cost
        end
        return old_cost
    end

    function visit(node::Node)
        if node ∈ visited
            return
        end
        push!(visited, node)
        node_cost = costs[node]
        y, x, dir = node
        neg_cost = 0
        pos_cost = 0
        dx = Int(dir == horizontal)
        dy = Int(dir == vertical)
        for d = 1:max_step
            nx = x - d * dx
            ny = y - d * dy
            if nx >= 1 && ny >= 1
                neg_cost += grid[ny, nx]
                if d >= min_step
                    nnode = (ny, nx, other(dir))
                    cost = updatecost(nnode, node_cost + neg_cost, node)
                    if nnode ∉ visited
                        push!(to_visit, nnode, cost)
                    end
                end
            end
            nx = x + d * dx
            ny = y + d * dy
            if nx <= width && ny <= height
                pos_cost += grid[ny, nx]
                if d >= min_step
                    nnode = (ny, nx, other(dir))
                    cost = updatecost(nnode, node_cost + pos_cost, node)
                    if nnode ∉ visited
                        push!(to_visit, nnode, cost)
                    end
                end
            end
        end
    end

    while !isempty(to_visit)
        node = pop!(to_visit)
        visit(node)
    end

    return min(costs[height, width, horizontal], costs[height, width, vertical])
end

function printpath(height, width, prev, node)
    path = Dict{Point2,Char}()
    while !isnothing(node)
        path[node[1], node[2]] = node[3] == horizontal ? '-' : '|'
        node = get(prev, node, nothing)
    end

    for y = 1:height
        for x = 1:width
            ch = get(path, (y, x), '.')
            print(ch)
        end
        println()
    end
end

solve()
