function solve()
    plays = parse.(Play, readlines())
    display(plays)
end

struct Hand
    cards::Dict{Char,Int}
end

struct Play
    hand::Hand
    bid::Int
end

function parse(::Type{Play}, line::AbstractString)::Play
    hand, bid = split(line, " ")
    Play(parse(Hand, hand), Base.parse(Int, bid))
end
function parse(::Type{Hand}, line::AbstractString)::Hand
    Hand(reduce(((c, d) -> d[c] += 1; d), hand, Dict{Char,Int}()))
end

function handtype(hand::Hand)::Int
    if occursin("S", hand.cards)
        return "S"
    elseif occursin("H", hand.cards)
        return "H"
    elseif occursin("D", hand.cards)
        return "D"
    elseif occursin("C", hand.cards)
        return "C"
    else
        return "N"
    end
end

solve()
