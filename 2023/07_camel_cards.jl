function solve()
    plays = parse.(Play, readlines())
    solve1(plays)
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
    cards = Dict{Char,Int}()
    for ch in line
        cards[ch] = get(cards, ch, 0) + 1
    end
    Hand(cards)
end

function solve1(plays::AbstractArray{Play})
    plays = sort(plays, by=p -> rank(p.hand) => ord(p.hand))
    enumerate(plays) .|>
    (p -> p[1] * p[2].bid) |>
    sum |>
    println
end

struct RankPair end
struct RankTwoPair end
struct RankThreeOfAKind end
struct RankFullHouse end
struct RankFourOfAKind end
struct RankFiveOfAKind end

function rank(hand::Hand)::Int
    if is(hand, RankFiveOfAKind)
        return 7
    elseif is(hand, RankFourOfAKind)
        return 6
    elseif is(hand, RankFullHouse)
        return 5
    elseif is(hand, RankThreeOfAKind)
        return 4
    elseif is(hand, RankTwoPair)
        return 3
    elseif is(hand, RankPair)
        return 2
    end
    return 1
end

function is(hand::Hand, ::Type{RankFiveOfAKind})::Bool
    for (card, count) in hand.cards
        if count == 5
            return true
        end
    end
    false
end
function is(hand::Hand, ::Type{RankFourOfAKind})::Bool
    for (card, count) in hand.cards
        if count == 4
            return true
        end
    end
    false
end
function is(hand::Hand, ::Type{RankFullHouse})::Bool
    is(hand, RankThreeOfAKind) && is(hand, RankPair)
end
function is(hand::Hand, ::Type{RankThreeOfAKind})::Bool
    for (card, count) in hand.cards
        if count == 3
            return true
        end
    end
    false
end
function is(hand::Hand, ::Type{RankTwoPair})::Bool
    pairs = 0
    for (card, count) in hand.cards
        if count == 2
            pairs += 1
        end
    end
    pairs == 2
end
function is(hand::Hand, ::Type{RankPair})::Bool
    for (card, count) in hand.cards
        if count == 2
            return true
        end
    end
    false
end

const ORDER = "23456789TJQKA"

function ord(hand::Hand)::Int
    result = 0
    for (card, count) in sort!(collect(hand.cards), by=((p) -> p[2] => getindex(ORDER, p[1])), rev=true)
        result = result * 13^count + getindex(ORDER, card)
    end
    result
end
function ordstr(hand::Hand)::String
    result = ""
    for (card, count) in sort!(collect(hand.cards), by=((p) -> p[2] => getindex(ORDER, p[1])), rev=true)
        result *= repeat(card, count)
    end
    result
end
function getindex(str::AbstractString, ch::Char)::Int
    for (i, c) in enumerate(str)
        if c == ch
            return i
        end
    end
    error("not found")
end

solve()
