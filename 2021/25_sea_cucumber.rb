# For data locality cells are stored by index
CELLS = ".>v"

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
			.map { |r| r.map { |l| CELLS[l] } .join }
			.join("\n")
	end

	def step!
		moves = 0
		nvals = @vals.dup

		for type in 1..2 do			
			for v, i in @vals.each_with_index do
				next unless v == type

				y, x = i.divmod(@width)
				ni = self.next_idx(i, type)
				ny, nx = ni.divmod(@width)
				if @vals[ni] == 0
					nvals[ni] = v
					nvals[i] = 0
					moves += 1
				end
			end
			@vals = nvals.dup
		end

		return moves
	end

	def steps_to_rest!
		steps = 0
		until self.step! == 0 do
			steps += 1
		end
		return steps
	end

	def next_idx(idx, type)
		return right_of(idx) if type == 1
		return bottom_of(idx)
	end

	def right_of(idx)
		y, x = idx.divmod(@width)
		x = -1 if x + 1 == @width
		return y * @width + x + 1
	end

	def bottom_of(idx)
		y, x = idx.divmod(@width)
		y = -1 if y + 1 == self.height
		return (y + 1) * @width + x
	end
end

class Array
	def to_grid
		Grid.new(self)
	end
end

grid = STDIN.readlines
	.map! { |l| l.strip.chars.map! { |x| CELLS.index(x) } }
	.to_grid

puts grid.steps_to_rest! + 1
