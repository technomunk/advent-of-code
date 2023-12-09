Seq = Vector{Int}

function solve()
    seqs = split.(readlines()) .|> l -> parse.(Int, l)
    solve1(seqs)
    solve2(seqs)
end

function solve1(seqs::AbstractVector{Seq})
    seqs .|>
        following |>
        sum |>
        println
end

function solve2(seqs::AbstractVector{Seq})
    seqs .|>
        preceding |>
        sum |>
        println
end

function following(seq::Seq)::Int
    value = 0
    for s in Iterators.reverse(diffstack(seq))
        value += s[end]
    end
    return value
end
function preceding(seq::Seq)::Int
    stack = diffstack(seq)
    value = 0
    for s in Iterators.reverse(stack)
        value = s[1] - value
    end
    return value
end

function diffstack(seq::Seq)::Vector{Seq}
    stack = [seq]
    while !all(e -> e == 0, stack[end])
        push!(stack, diffs(stack[end]))
    end
    return stack
end

function diffs(seq::Seq)::Seq
    result = Vector{Int}()
    for i = 2:lastindex(seq)
        push!(result, seq[i] - seq[i - 1])
    end
    return result
end

solve()
