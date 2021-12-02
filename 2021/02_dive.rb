def solve_part1 lines
	x, y = 0, 0
	for line in lines do
		dir, amt = line.split
		amt = amt.to_i

		case dir
		when "up"
			y -= amt
		when "down"
			y += amt
		when "forward"
			x += amt
		end
	end

	return x * y
end

def solve_part2 lines
	x, y, dy = 0, 0, 0

	for line in lines do
		dir, amt = line.split
		amt = amt.to_i
	
		case dir
		when "up"
			dy -= amt
		when "down"
			dy += amt
		when "forward"
			x += amt
			y += dy * amt
		end
	end

	return x * y
end

lines = IO.readlines("02.txt")

puts solve_part1(lines)
puts solve_part2(lines)
