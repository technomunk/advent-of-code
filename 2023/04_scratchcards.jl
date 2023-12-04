include("utils.jl")

function solve()
    cards = parse.(Card, readlines())
    solve1(cards)
    solve2(cards)
end

struct Card
    id::String
    winning::Vector{String}
    have::Vector{String}
end

function solve1(cards::Vector{Card})
    cards .|> points |> sum |> println   
end

function solve2(cards::Vector{Card})
    card_instances = fill!(similar(cards, Int), 1)
    for (i, (cnt, card)) in enumerate(zip(card_instances, cards))
        for k = (i+1):(i+overlap(card))
            card_instances[k] += cnt
        end
    end
    sum(card_instances) |> println
end


function parse(::Type{Card}, s::AbstractString)::Card
    id, s = takematch(r"Card \s*(\d+): ", s)
    halves = split.(split(s, " | "), " ") .|> h -> filter!(n -> !isempty(n), h)
    return Card(id[1], halves...)
end

function overlap(card::Card)::Int count(in(card.winning), card.have) end
function points(card::Card)::Int
    o = overlap(card)
    if o == 0
        return 0
    end
    return 2 ^ (o - 1)
end

solve()
