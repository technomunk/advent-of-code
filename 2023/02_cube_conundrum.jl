include("utils.jl")

struct Draw
    red::Int
    green::Int
    blue::Int
end

struct Game
    id::Int
    draw::Draw
end

const COLOR_RE = r"(\d+) (red|green|blue)"
const DRAW_REF = Draw(12, 13, 14)

function Base.parse(::Type{Draw}, s::AbstractString)::Draw
    red = 0
    green = 0
    blue = 0
    m, s = takematch(COLOR_RE, s)

    while !isnothing(m)
        if m[2] == "red"
            red = parse(Int, m[1])
        elseif m[2] == "green"
            green = parse(Int, m[1])
        elseif m[2] == "blue"
            blue = parse(Int, m[1])
        end
        m, s = takematch(COLOR_RE, s)
    end

    return Draw(red, green, blue)
end

function Base.parse(::Type{Game}, s::AbstractString)::Game
    m, s = takematch(r"Game (\d+): ", s)
    id = parse(Int, m[1])
    draws = split(s, ";") .|> (d -> parse(Draw, d))
    max_red = draws .|> (d -> d.red) |> maximum
    max_green = draws .|> (d -> d.green) |> maximum
    max_blue = draws .|> (d -> d.blue) |> maximum
    return Game(id, Draw(max_red, max_green, max_blue))
end

is_possible(ref::Draw, game::Draw)::Bool = ref.red >= game.red && ref.green >= game.green && ref.blue >= game.blue
is_possible(ref::Draw, game::Game)::Bool = is_possible(ref, game.draw)

power(g::Game)::Int = g.draw.red * g.draw.green * g.draw.blue

function solve()
    lines = readlines()
    games = lines .|> l -> parse(Game, l)
    filter(g -> is_possible(DRAW_REF, g), games) .|>
    (g -> g.id) |>
    sum |>
    println

    games .|> power |> sum |> println
end

solve()
