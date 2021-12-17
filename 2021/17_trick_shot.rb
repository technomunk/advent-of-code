# Hypothesis 1: any X coordinate is reachable
# Hypothesis 2: any Y coordinate >= 0 is hit exactly twice if dy > 0
# Hypothesis 3: any dY(n+1) is the same as dY(-n) with extra steps if n >= 0
# Observation 1: proble settles on triangle X coordinates (0, 1, 3, 6, 10, etc)

def solve_part1(limits)
	# Given H1 and H2 the tallest height reachable is achieved with dy = (0 - min_y)
	min_y = limits[2]
	dy = 0 - min_y
	# algebraic sequence sum
	max_height = dy*(dy-1) / 2
	return max_height
end

def solve_part2(limits)
	count = 0
	for dy in limits[2]..(-limits[2]) do
		ody = dy
		for dx in 0..limits[1] do
			dy = ody
			x, y = 0, 0
			steps = 0
			while (y >= limits[2]) && (x <= limits[1]) do
				if x >= limits[0] && y <= limits[3]
					count += 1
					break
				end
				x, dx = x + dx, dx - dx.sign
				y, dy = y + dy, dy - 1
			end
		end
	end
	return count
end

class Integer
	def sign
		if self > 0
			return 1
		end
		return self == 0 ? 0 : -1
	end
end


limits = STDIN.readline
	.strip
	.delete_prefix("target area: ")
	.split(", ")
	.map { |s| s.slice(2..).split("..") }
	.flatten
	.map { |x| x.to_i }


part1 = solve_part1(limits)
part2 = solve_part2(limits)

puts(part1)
puts(part2)
