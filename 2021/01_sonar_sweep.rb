def solve_part1 lines
	increments = 0
	depths = lines.map{|el| el.to_i}
	for a, b in depths.each_cons(2)
		if b > a
			increments += 1
		end
	end
	return increments
end

def solve_part2 lines
	increments = 0
	depths = lines.map{|el| el.to_i}
	triplets = depths.each_cons(3)
	triplet_sums = triplets.map{|t| t.sum}
	for a, b in triplet_sums.each_cons(2)
		if b > a
			increments += 1
		end
	end
	return increments
end

lines = IO.readlines("01.txt")
puts solve_part1(lines)
puts solve_part2(lines)
