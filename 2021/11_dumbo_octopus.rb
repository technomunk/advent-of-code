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

	def step!
		offsets = [
			-@width - 1, -@width, -@width + 1,
			-1, 1,
			@width - 1, @width, @width + 1,
		]

		# check for flash out of order, assuming each cell will get +1
		incomplete = true
		while incomplete do
			incomplete = false
			for idx in @vals.each_index do
				if @vals[idx] >= 9
					@vals[idx] = -1

					# bump neighbors
					for ni in self.neighbor_indices(idx) do
						if @vals[ni] != -1
							@vals[ni] += 1
						end
					end

					# repeat outer loop for increased cache hitrate
					incomplete = true
					break
				end
			end
		end
	
		# count flashes that happened
		flashes = @vals.count { |i| i == -1 }

		# increment all values by 1, recently flashed -1 become 0 as stated by the problem
		@vals.map! { |v| v + 1 }

		return flashes
	end

	def steps!(n)
		flashes = 0
		for _ in 1..n do
			flashes += self.step!
		end

		return flashes
	end

	def neighbor_indices(idx)
		y, x = idx.divmod(@width)
		return [
			[ x - 1, y - 1 ], [ x, y - 1 ], [ x + 1, y - 1 ],
			[ x - 1, y ], [ x + 1, y ],
			[ x - 1, y + 1 ], [ x, y + 1 ], [ x + 1, y + 1 ],
		].filter_map { | x, y | (y * @width + x) if self.include_indices?(x, y) }
	end

	def steps_to_synchronized!
		steps = 0

		until @vals.all? { |l| l == 0 } do
			self.step!
			steps += 1
		end

		return steps
	end

private
	def include_indices?(x, y) y >= 0 && x >= 0 && x < @width && y < self.height end
end

class Array
	def to_grid() Grid.new(self) end

	def include_index?(idx) idx >= 0 && idx < self.length end
end

grid = STDIN.readlines
	.map { |l| l.strip }
	.map { |l| l.chars.map { |c| c.to_i } }
	.to_grid

part1 = grid.clone().steps!(100)
part2 = grid.steps_to_synchronized!

puts(part1)
puts(part2)
