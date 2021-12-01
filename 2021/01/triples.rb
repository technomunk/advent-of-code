lines = IO.readlines("input.txt")
depths = lines.map { |el| el.to_i }
triple_sums = depths.each_cons(3).map { |triple| triple.sum }
increments = 0
triple_sums.each_cons(2) { |pair| increments += pair[1] > pair[0] ? 1 : 0 }
puts increments
