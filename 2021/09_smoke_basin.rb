class Array
	def minima
		result = []
		for row, y in self.each_with_index do
			for h, x in row.each_with_index do
				others = [
					x > 0 ? self[y][x - 1] : nil,
					x < (row.length - 1) ? self[y][x + 1] : nil,
					y > 0 ? self[y - 1][x] : nil,
					y < (self.length - 1) ? self[y + 1][x] : nil,
				].compact
				if others.all? { |o| o > h }
					result.push(h)
				end
			end
		end
		return result
	end

	def flood_fill!(y, x, val)
		_next = [[y, x]]
		until _next.empty? do
			y, x = _next.pop

			row = self[y]
			row[x] = val  # note that this effectively mutates self

			if x > 0 && row[x - 1] == -1
				_next.push([y, x - 1])
			end
			if x < (row.length - 1) && row[x + 1] == -1
				_next.push([y, x + 1])
			end
			if y > 0 && self[y - 1][x] == -1
				_next.push([y - 1, x])
			end
			if y < (self.length - 1) && self[y + 1][x] == -1
				_next.push([y + 1, x])
			end
		end
	end

	def basins
		basin_map = self.map do |row|
			row.map { |h| h == 9 ? nil : -1 }
		end

		next_idx = 0
		for row, y in basin_map.each_with_index do
			for idx, x in row.each_with_index do
				if idx == -1
					basin_map.flood_fill!(y, x, next_idx)
					next_idx += 1
				end
			end
		end

		return basin_map
	end
end

heights = STDIN.readlines
	.map { |l| l.strip.chars.map { |h| h.to_i } }

part1 = heights.minima.sum + heights.minima.length
part2 = heights.basins
	.flatten
	.compact
	.tally
	.map { |_, c| c }
	.sort
	.last(3)
	.reduce(1) { |m, c| m * c }

puts(part1)
puts(part2)
