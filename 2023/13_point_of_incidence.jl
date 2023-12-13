include("utils.jl")

function solve()
    grid = matrix.(spliton(readlines(), ""))
    solve1(grid)
    solve2(grid)
end

function solve1(grid::Vector{Matrix{Char}})
    reflection.(grid) |> sum |> println
end

function solve2(grid::Vector{Matrix{Char}})
    semireflection.(grid) |> sum |> println
end

function reflection(grid::Matrix{Char})::Int
    reflectionidx(eachcol(grid), isreflection) + reflectionidx(eachrow(grid), isreflection) * 100
end

function semireflection(grid::Matrix{Char})::Int
    reflectionidx(eachcol(grid), issemireflection) + reflectionidx(eachrow(grid), issemireflection) * 100
end

function reflectionidx(col, reflection_fn)::Int
    for i = 1:lastindex(col)-1
        if reflection_fn(col, i)
            return i
        end
    end
    return 0
end

function isreflection(col, index::Int)::Bool
    for (a, b) in zip(reverse(@view col[1:index]), @view col[index+1:end])
        if a != b
            return false
        end
    end
    return true
end

function issemireflection(col, index::Int)::Bool
    found_diff = false
    for (a, b) in zip(reverse(@view col[1:index]), @view col[index+1:end])
        diff_count = countdiffs(a, b)
        if diff_count == 0
            continue
        elseif diff_count == 1 && !found_diff
            found_diff = true
        else
            return false
        end
    end
    return found_diff
end

function countdiffs(as, bs)::Int
    result = 0
    for (a, b) in zip(as, bs)
        result += Int(a != b)
    end
    return result
end

function printx(grid::Matrix{Char}, rx::Int, ry::Int)
    if rx != 0
        println(' '^rx * "><")
    end
    for (y, r) in enumerate(eachrow(grid))
        delim = ' '
        if y == ry
            delim = 'v'
        elseif y == ry + 1 && ry != 0
            delim = '^'
        end
        println("$delim$(String(r))$delim")
    end
    if rx != 0
        println(' '^rx * "><")
    end
    println()
end

solve()
