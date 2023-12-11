function solve()
    plays = parse.(Play, readlines())
    solve1(plays)
    solve2(plays)
end

Hand = String

struct Play
    hand::Hand
    bid::Int
end

function parse(::Type{Play}, line::AbstractString)::Play
    hand, bid = split(line, " ")
    Play(hand, Base.parse(Int, bid))
end

function solve1(plays::AbstractArray{Play})
    plays = sort(plays, by=p -> rank(p.hand) => ord(p.hand, ORDER_1))
    enumerate(plays) .|>
        (p -> p[1] * p[2].bid) |>
        sum |>
        println
end
function solve2(plays::AbstractArray{Play})
    plays = sort(plays, by=p -> jokerrank(p.hand) => ord(p.hand, ORDER_2))
    enumerate(plays) .|>
        (p -> p[1] * p[2].bid) |>
        sum |>
        println
end

CardsCounts = Dict{Char,Int}

function rank(hand::Hand)::Int
    counts = cardcount(hand)
    if hasnojoke(counts, 5)
        return 7
    elseif hasnojoke(counts, 4)
        return 6
    elseif isfullhouse(counts)
        return 5
    elseif hasnojoke(counts, 3)
        return 4
    elseif istwopair(counts)
        return 3
    elseif hasnojoke(counts, 2)
        return 2
    end
    return 1
end
function jokerrank(hand::Hand)::Int
    counts = cardcount(hand)
    if haswithjoke(counts, 5)
        return 7
    elseif haswithjoke(counts, 4)
        return 6
    elseif isjokerfullhouse(counts)
        return 5
    elseif haswithjoke(counts, 3)
        return 4
    # joker two pair is impossible, as the joker would be used to make 3 of a kind
    elseif istwopair(counts)
        return 3
    elseif haswithjoke(counts, 2)
        return 2
    end
    return 1
end

const RANK_NAMES = Dict{Int, String}(
    1 => "Nothing",
    2 => "One pair",
    3 => "Two pair",
    4 => "Three of a kind",
    5 => "Full house",
    6 => "Four of a kind",
    7 => "Five of a kind",
)

function hasnojoke(counts::CardsCounts, amount::Int)::Bool
    any(c -> c == amount, values(counts))
end
function haswithjoke(counts::CardsCounts, amount::Int)::Bool
    jc = get(counts, 'J', 0)
    for (card, count) in counts
        if card == 'J'
            continue
        elseif count + jc == amount
            return true
        end
    end
    return jc == amount
end
function isfullhouse(counts::CardsCounts)::Bool
    return hasnojoke(counts, 3) && hasnojoke(counts, 2)
end
function isjokerfullhouse(counts::CardsCounts)::Bool
    has_two = false
    has_three = false
    jc = get(counts, 'J', 0)
    for (card, count) in counts
        if card == 'J' continue end
        if count + jc == 3
            has_three = true
            jc = 0
        elseif count + jc == 2
            has_two = true
            jc = 0
        end
    end
    return has_three && has_two
end
function istwopair(counts::CardsCounts)::Bool
    pair_count = 0
    for (_, count) in counts
        if count == 2
            pair_count += 1
        end
    end
    return pair_count == 2
end

const ORDER_1 = "23456789TJQKA"
const ORDER_2 = "J23456789TQKA"

function cardcount(hand::Hand)::Dict{Char,Int}
    result = Dict{Char,Int}()
    for card in hand
        result[card] = get(result, card, 0) + 1
    end
    return result
end
function ord(hand::Hand, order::String)::Int
    result = 0
    for card in hand
        result = result * 13 + getindex(order, card)
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
