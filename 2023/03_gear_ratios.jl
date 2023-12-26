include("utils.jl")


function solve()
    grid = readlines() |> matrix
    solve1(grid) |> display
    solve2(grid) |> display
end

function solve1(grid::Matrix{Char})
    is_part = parts(grid)
    total = 0
    for (y, row) = enumerate(eachrow(grid))
        nums = grabnums(row, is_part[y, :]')
        total += sum(nums)
    end
    return total
end

solve2(grid::Matrix{Char})::Int = gears(grid) |> sum
as01(b::Bool)::Char = b ? '1' : '0'

const IGNORED_CHARS = Set(".1234567890")

function parts(grid::Matrix{Char})::Matrix{Bool}
    is_part = fill!(similar(grid, Bool), false)
    for (y, row) in enumerate(eachrow(grid))
        for x = 1:lastindex(row)
            if row[x] ∉ IGNORED_CHARS
                mark!(is_part, grid, y, x)
            end
        end
    end
    return is_part
end

function mark!(is_part::Matrix{Bool}, grid::Matrix{Char}, y::Int, x::Int)::Nothing
    for ny in neighborindicies(is_part, 1, y)
        for nx in neighborindicies(is_part, 2, x)
            if isdigit(grid[ny, nx]) && !is_part[ny, nx]
                markdigits!(is_part, grid, ny, nx)
            end
        end
    end
end

function markdigits!(is_part::Matrix{Bool}, grid::Matrix{Char}, y::Int, x::Int)::Nothing
    nx = x
    while nx > 0 && isdigit(grid[y, nx])
        is_part[y, nx] = true
        nx -= 1
    end
    nx = x + 1
    while nx <= size(grid, 2) && isdigit(grid[y, nx])
        is_part[y, nx] = true
        nx += 1
    end
end

function grabnums(row::AbstractArray{Char}, is_part::AbstractArray{Bool})::Vector{Int}
    nums = Int[]
    num = Char[]
    for (ch, ip) in zip(row, is_part)
        if ip && isdigit(ch)
            push!(num, ch)
        elseif !isempty(num)
            push!(nums, parse(Int, String(num)))
            empty!(num)
        end
    end
    if !isempty(num)
        push!(nums, parse(Int, String(num)))
    end
    return nums
end

function gears(grid::Matrix{Char})::Vector{Int}
    gears = Int[]
    for (y, row) in enumerate(eachrow(grid))
        for (x, ch) in enumerate(row)
            if ch == '*'
                g = gear(grid, y, x)
                if !isnothing(g)
                    push!(gears, g)
                end
            end
        end
    end
    return gears
end

function gear(grid::Matrix{Char}, y::Int, x::Int)::Union{Int,Nothing}
    nums = String[]
    for ny in neighborindicies(grid, 1, y)
        allow_num = true
        for nx in neighborindicies(grid, 2, x)
            if isdigit(grid[ny, nx])
                if allow_num
                    push!(nums, grabnum(grid, ny, nx))
                    allow_num = false
                end
            else
                allow_num = true
            end
        end
    end
    if length(nums) == 2
        return parse.(Int, nums) |> prod
    end
    return nothing
end

function grabnum(grid::Matrix{Char}, y::Int, x::Int)::String
    num = Char[]
    nx = x
    while nx >= 1 && isdigit(grid[y, nx])
        push!(num, grid[y, nx])
        nx -= 1
    end
    reverse!(num)
    nx = x + 1
    while nx <= size(grid, 2) && isdigit(grid[y, nx])
        push!(num, grid[y, nx])
        nx += 1
    end
    return String(num)
end

solve()
