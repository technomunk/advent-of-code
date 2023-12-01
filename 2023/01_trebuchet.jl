DIGIT_RE = r"^(one|two|three|four|five|six|seven|eight|nine|\d)"

DIGITS = Base.ImmutableDict(
    "one"=>"1",
    "two"=>"2",
    "three"=>"3",
    "four"=>"4",
    "five"=>"5",
    "six"=>"6",
    "seven"=>"7",
    "eight"=>"8",
    "nine"=>"9",
)

function filter_digits(line::String)::String
    first_digit = nothing
    last_digit = nothing

    for ch in Iterators.filter(isdigit, line)
        if isnothing(first_digit)
            first_digit = ch
        else
            last_digit = ch
        end
    end

    if isnothing(last_digit)
        last_digit = first_digit
    end

    return "$first_digit$last_digit"
end

function digitize(digit)::String
    return get(DIGITS, digit, digit)
end

function grab_digits(line::String)::String
    first_digit = nothing
    last_digit = nothing

    for i = 0:length(line)-1
        m = match(DIGIT_RE, chop(line, head=i, tail=0))
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
    digits = map(filter_digits, lines)
    numbers = map((d) -> parse(Int, d), digits)
    println(sum(numbers))
    digits = map(grab_digits, lines)
    numbers = map((d) -> parse(Int, d), digits)
    println(sum(numbers))
end

solve()
