class Array
	def median
		return self.sort[self.length / 2]
	end

	def mean
		value, mod = self.sum.divmod(self.length)
		return value
	end
end

def nth_triangle_num(n)
	return n * (n + 1) / 2
end

def solve_part1(positions)
	target = positions.median
	deltas = positions.map { |x| (x - target).abs }
	return deltas.sum
end

def solve_part2(positions)
	target = positions.mean
	deltas = positions.map { |x| nth_triangle_num((x - target).abs) }
	return deltas.sum
end

input = STDIN.readline
positions = input.split(",").map { |x| x.to_i }

puts(solve_part1(positions))
puts(solve_part2(positions))
