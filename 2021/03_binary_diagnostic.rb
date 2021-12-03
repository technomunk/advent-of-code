def one_counts(lines)
	one_counts = Array.new(lines.first.length, 0)

	for line in lines
		for c, i in line.each_char.with_index
			one_counts[i] += c.to_i
		end
	end

	return one_counts
end

def solve_part1(lines)
	ones = one_counts(lines)
	c, e = 0, 0
	half_point = lines.length / 2
	for cnt, i in ones.reverse.map.with_index
		if cnt > half_point
			c += 2 ** i
		else
			e += 2 ** i
		end
	end

	return c * e
end

def solve_part2(lines)
	o2 = lines.dup
	co2 = lines

	for i in 0..lines.first.length do
		if o2.length > 1
			ones = one_counts(o2)
			d, r = o2.length.divmod(2)
			ip = d + r  # inflection point
			kept_digit = ones[i] >= ip ? "1" : "0"
			o2.filter! { |el| el[i] == kept_digit }
		end
		if co2.length > 1
			ones = one_counts(co2)
			d, r = co2.length.divmod(2)
			ip = d + r  # inflection point
			kept_digit = ones[i] >= ip ? "0" : "1"
			co2.filter! { |el| el[i] == kept_digit }
		end
	end

	return o2.first.to_i(2) * co2.first.to_i(2)
end

lines = IO.readlines("03.txt").map { |line| line.strip }
puts(solve_part1(lines))
puts(solve_part2(lines))
