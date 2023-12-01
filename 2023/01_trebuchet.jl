const NUMBER_RE = r"^(one|two|three|four|five|six|seven|eight|nine|\d)"
const DIGIT_RE = r"^\d"

const DIGITS = Base.ImmutableDict(
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9",
)

function digitize(digit)::String
    return get(DIGITS, digit, digit)
end

function grab_first_last(line::String, re::Regex)::String
    first_digit = nothing
    last_digit = nothing

    for i = 0:length(line)
        m = match(re, chop(line, head=i, tail=0))
        if !isnothing(m)
            if isnothing(first_digit)
                first_digit = m.match
            else
                last_digit = m.match
            end
        end
    end

    if isnothing(last_digit)
        last_digit = first_digit
    end

    first_digit = digitize(first_digit)
    last_digit = digitize(last_digit)
    return "$first_digit$last_digit"
end

function solve()
    lines = readlines()
    result = lines .|>
        (l -> grab_first_last(l, DIGIT_RE)) .|>
        (d -> parse(Int, d)) |>
        sum
    println(result)

    result = lines .|>
        (l -> grab_first_last(l, NUMBER_RE)) .|>
        (d -> parse(Int, d)) |>
        sum
    println(result)
end

solve()
