require "set"

# Arbitrary hack, max int should be bigger than any other integer in the solution
MAX_INT = 1 << 31

class Grid
	attr_reader(:vals, :width)
	def initialize(arr)
		height = arr.length
		@vals = arr.flatten
		@width = @vals.length / height
	end

	def initialize_clone(orig)
		@width = orig.width
		@vals = orig.vals.clone()
	end

	def height() @vals.length / @width end

	def rows() @vals.each_slice(@width) end

	def to_s
		self.rows
			.map { |r| r.map { |l| l.to_s } .join }
			.join("\n")
	end

	def neighbor_indices(idx)
		y, x = self.idx_to_yx(idx)
		return [
			[ x, y - 1 ], [ x, y + 1 ],
			[ x - 1, y ], [ x + 1, y ],
		].filter_map { | x, y | (y * @width + x) if self.include_indices?(x, y) }
	end

	def include_indices?(x, y) y >= 0 && x >= 0 && x < @width && y < self.height end

	# Heuristic linear distance from provided node to the final destination
	def hdist(n)
		y, x = self.idx_to_yx(n)
		return self.height - y - 1 + @width - x - 1
	end

	def idx_to_yx(idx) idx.divmod(@width) end
	def xy_to_idx(x, y) x + y * @width end

	def astar
		explore = [0]
		previous = Hash.new
		distances = { 0 => 0 }
		distances.default = MAX_INT

		until explore.empty? do
			node = explore.pop()
			if node == @vals.length - 1
				break
			end

			for neighbor in self.neighbor_indices(node) do
				dist = distances[node] + @vals[neighbor]
				if dist < distances[neighbor]
					previous[neighbor] = node
					distances[neighbor] = dist

					explore.binsert(neighbor) { |v| dist - distances[v] }
				end
			end
		end

		return distances[@vals.length - 1]
	end

	def repeat!(n = 5)
		o_height = self.height
		o_len = @vals.length
		o_width = @width
		@vals = self.rows
			.map { |r| r * n }
			.flatten
		@vals *= n
		@width *= n

		for v, i in @vals.each_with_index do
			y, x = self.idx_to_yx(i)
			if y < o_height && x < o_width
				next
			end

			if x >= o_width
				x -= o_width
			else
				y -= o_height
			end
			lv = @vals[self.xy_to_idx(x, y)]
			@vals[i] = (lv >= 9) ? 1 : lv + 1
		end

		return self
	end
end

class Array
	def to_grid()
		Grid.new(self)
	end

	def binsert(element, &block)
		min_i = 0
		max_i = self.length
		after = false

		until min_i == max_i
			i = (max_i + min_i) / 2
			sr = block.call(self[i])
			case
			when sr > 0
				max_i = (max_i == i) ? min_i : i
				after = false
			when sr < 0
				after = min_i != i
				min_i = (min_i == i) ? max_i : i
			else
				min_i = i
				max_i = i
			end
		end

		i = after ? min_i + 1 : min_i
		self.insert(i, element)
	end
end

grid = STDIN.readlines
	.map { |l| l.strip.chars.map { |c| c.to_i } }
	.to_grid

part1 = grid.astar
part2 = grid.repeat!.astar

puts(part1)
puts(part2)
