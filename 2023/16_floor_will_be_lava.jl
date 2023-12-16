include("utils.jl")

function solve()
    grid = matrix(readlines())
    solve1(grid)
    solve2(grid)
end

function solve1(grid::Matrix{Char})
    energized(grid) |> println
end
function solve2(grid::Matrix{Char})
    max_energized = Threads.Atomic{Int}(0)
    w, h = size(grid)
    Threads.@threads for x = 1:w
        Threads.atomic_max!(max_energized, energized(grid, Ray(x, 1, down)))
        Threads.atomic_max!(max_energized, energized(grid, Ray(x, h, up)))
    end
    Threads.@threads for y = 1:h
        Threads.atomic_max!(max_energized, energized(grid, Ray(1, y, right)))
        Threads.atomic_max!(max_energized, energized(grid, Ray(w, y, left)))
    end
    println(max_energized[])
end

Base.Enums.@enum Direction up down left right

function step(d::Direction)::Tuple{Int,Int}
    if d == up
        return 0, -1
    elseif d == down
        return 0, 1
    elseif d == left
        return -1, 0
    else
        return 1, 0
    end
end
function reflect(d::Direction, m::Char)::Direction
    if m == '\\'
        if d == up
            return left
        elseif d == down
            return right
        elseif d == left
            return up
        else
            return down
        end
    else  # '/'
        if d == up
            return right
        elseif d == down
            return left
        elseif d == left
            return down
        else
            return up
        end
    end
end

struct Ray
    x::Int
    y::Int
    dir::Direction
end

Base.getindex(m::AbstractMatrix, r::Ray) = m[r.y, r.x]
function Base.setindex!(m::AbstractMatrix, v, r::Ray)
    m[r.y, r.x] = v
end

function Base.:(+)(r::Ray, d::Direction)::Ray
    dx, dy = step(d)
    return Ray(r.x + dx, r.y + dy, d)
end

function energized(grid::Matrix{Char}, ray::Ray = Ray(1, 1, right))::Int
    energized_grid = falses(size(grid))
    seen_rays = Set{Ray}()
    rays = [ray]
    while !isempty(rays)
        ray = pop!(rays)
        push!(seen_rays, ray)
        for child in traceray!(energized_grid, ray, grid)
            if child ∉ seen_rays
                push!(seen_rays, child)
                push!(rays, child)
            end
        end
    end
    return count(energized_grid)
end

function traceray!(eg::BitMatrix, ray::Ray, grid::Matrix{Char})::Vector{Ray}
    steps = Set{Ray}()
    children = Vector{Ray}()
    while inbounds(ray, grid)
        eg[ray] = true
        push!(steps, ray)
        # print("($(ray.x),$(ray.y)) => ")
        new_ray = stepray(ray, grid)
        if isa(new_ray, Ray)
            ray = new_ray
        else
            ray = new_ray[1]
            push!(children, new_ray[2])
        end
        if ray ∈ steps
            break
        end
    end
    return children
end

function inbounds(ray::Ray, grid::Matrix{Char})::Bool
    w, h = size(grid)
    return ray.x >= 1 && ray.y >= 1 && ray.x <= w && ray.y <= h
end

function stepray(ray::Ray, grid::Matrix{Char})::Union{Ray,Tuple{Ray,Ray}}
    ch = grid[ray]
    if ch == '.'
        return ray + ray.dir
    elseif ch == '\\' || ch == '/'
        return ray + reflect(ray.dir, ch)
    elseif ch == '|'
        if ray.dir == right || ray.dir == left
            return (ray + up, ray + down)
        else
            return ray + ray.dir
        end
    else # ch == '-'
        if ray.dir == up || ray.dir == down
            return (ray + left, ray + right)
        else
            return ray + ray.dir
        end
    end
end

solve()
