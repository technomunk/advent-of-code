lines = IO.readlines("input.txt")
depths = lines.map { |el| el.to_i }
increments = 0
depths.each_cons(2) { |pair| if pair[1] > pair[0]
	increments += 1
end}
puts increments
