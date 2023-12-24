include("geometry.jl")
include("utils.jl")

Pt2 = Point2D{Float64}
Pt3 = Point3D{Float64}

struct Hail
    pos::Pt3
    vel::Pt3
end

function solve()
    hailstones = parse.(Hail, eachline())
    if "--test" ∈ ARGS
        run_test(hailstones)
    end
    solve1(hailstones) |> println
    solve2(hailstones) |> println
end

const TEST_MIN::Float64 = 200_000_000_000_000.0
const TEST_MAX::Float64 = 400_000_000_000_000.0
function solve1(hailstones::Vector{Hail})::Int
    test_area = Rect2D{Float64}(Pt2(TEST_MIN, TEST_MIN), Pt2(TEST_MAX, TEST_MAX))
    count = 0
    for (a, b) in Pairs(hailstones)
        p = xy_intersection(a, b)
        if !isnothing(p)
            is_inside = p ∈ test_area
            is_future = is_in_the_future(a, p) && is_in_the_future(b, p)
            count += is_inside && is_future
        end
    end
    return count
end

function solve2(hailstones::Vector{Hail})::Int
    # Looked for inspiration on AOC subreddit :innocent:
    # If the rock has equation p0 + t * v0
    # We know that the rock has to intercept each hailstone, ie
    # p0 + t[i] * v0 = p[i] + t[i] * v[i] for all i
    # We can rewrite this as
    # cross((p0 - p[i]), (v[i] - v0)) = 0 for all i

    h1, h2, h3 = (@view hailstones[1:3])
    vector = [
        (cross(h2.pos, h2.vel) - cross(h1.pos, h1.vel))...
        (cross(h3.pos, h3.vel) - cross(h1.pos, h1.vel))...
    ]
    matrix = zeros(Float64, 6, 6)
    matrix[1:3, 1:3] = crossmatrix(h1.vel) - crossmatrix(h2.vel)
    matrix[4:6, 1:3] = crossmatrix(h1.vel) - crossmatrix(h3.vel)
    matrix[1:3, 4:6] = crossmatrix(h2.pos) - crossmatrix(h1.pos)
    matrix[4:6, 4:6] = crossmatrix(h3.pos) - crossmatrix(h1.pos)

    result = inv(matrix) * vector
    return sum(x -> Int(round(x)), (@view result[1:3]))
end

function Base.parse(::Type{Hail}, line::AbstractString)::Hail
    pos, vel = split(line, " @ ")
    return Hail(parse(Pt3, pos), parse(Pt3, vel))
end
function Base.parse(::Type{Pt3}, line::AbstractString)::Pt3
    x, y, z = parse.(Float64, split(line, ", "))
    return Pt3(x, y, z)
end

function xy_intersection(h1::Hail, h2::Hail)::Union{Nothing,Pt2}
    # Consider the 2 hailstones as linear equations in XY plane.
    # Find the intersection and make sure the t is negative.
    if xy_codirectional(h1, h2)
        return nothing
    end

    # https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_line_equations
    a, c = as_xy_equation(h1)
    b, d = as_xy_equation(h2)
    # ax + c = bx + d
    # (a - b)x = d - c
    # x = (d - c) / (a - b)
    x = (d - c) / (a - b)
    y = a * x + c
    return Pt2(x, y)
    # return is_in_the_future(h1, Pt2(x, y)) && is_in_the_future(h2, Pt2(x, y))
end

function as_xy_equation(h::Hail)::Tuple{Float64,Float64}
    # y = ax + c
    a = h.vel.y / h.vel.x
    c = h.pos.y - a * h.pos.x
    return a, c
end

is_close(a::Float64, b::Float64) = abs(a - b) < 1e-6
function xy_codirectional(a::Hail, b::Hail)::Bool
    a_xy = Pt2(a.vel.x, a.vel.y)
    a_xy /= norm(a_xy)
    b_xy = Pt2(b.vel.x, b.vel.y)
    b_xy /= norm(b_xy)
    return is_close(a_xy.x, b_xy.x) && is_close(a_xy.y, b_xy.y)
end

function is_in_the_future(h::Hail, p::Pt2)::Bool
    return (p.x - h.pos.x) / h.vel.x > 0 && (p.y - h.pos.y) / h.vel.y > 0
end

function color(b::Bool)::String
    if b
        return "\e[32mtrue\e[0m"
    end
    return "\e[31mfalse\e[0m"
end

Base.show(io::IO, hail::Hail) = print(io, "$(hail.pos) @ vel=$(hail.vel)")

solve()
