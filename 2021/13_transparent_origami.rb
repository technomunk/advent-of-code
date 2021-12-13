DIRECTIONS = { "x"=>0, "y"=>1 }

class Integer
	def fold(n)
		dist = self - n
		dist > 0 ? n - dist : self
	end
end

class Array
	def fold(dir, coord)
		self.filter { |c| c[dir] != coord }
			.each { |c| c[dir] = c[dir].fold(coord) }
			.uniq
	end

	def to_hole_pattern
		max_x, max_y = 0, 0
		for x, y in self do
			max_x = x > max_x ? x : max_x
			max_y = y > max_y ? y : max_y
		end

		lines = (0..max_y).map { |_| "." * (max_x + 1) }

		for x, y in self do
			lines[y][x] = "#"
		end

		return lines.join("\n")
	end
end

coords, folds = STDIN.readlines
	.map { |l| l.strip }
	.slice_after("")
	.to_a

coords.pop()  # remove the empty line at which the slice happened
coords = coords.map { |l| l.split(",") }
	.map { |a, b| [a.to_i, b.to_i] }

folds = folds.map { |l| l["fold along ".length ..].split("=") }
	.map { |d, c| [ DIRECTIONS[d], c.to_i ] }

part1 = coords.fold(*folds.first).length
part2 = folds[1..].reduce(coords) { |coords, f| coords.fold(*f) }
	.to_hole_pattern

puts(part1)
puts(part2)
