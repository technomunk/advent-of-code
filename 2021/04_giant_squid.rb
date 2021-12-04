def nilcmp(a, b)
	case
	when a == nil
		return 1
	when b == nil
		return -1
	else
		return a <=> b
	end
end

class BingoGrid
	def initialize(lines)
		@vals = Array.new
		@width = 0
		@height = 0
		@last_mark = -1

		for line in lines do
			symbols = line.split
			@width = symbols.length
			@vals += symbols.map { |s| [s.to_i, false] }
		end
		@height = @vals.length / @width
	end

	def width
		@width
	end

	def height
		@height
	end

	def mark(value)
		for el, idx in @vals.each_with_index do
			if el[0] == value
				@last_mark = idx
				el[1] = true
				return self
			end
		end
		return self
	end

	def row(y)
		return @vals[y*@width, @width]
	end

	def col(x)
		return @vals[(x..).step(@width)]
	end

	def is_bingo?
		if @last_mark == -1
			return false
		end
		y, x = @last_mark.divmod(@width)
		return self.row(y).all? { |el| el[1] } || self.col(x).all? { |el| el[1] }
	end

	def unmarked
		return @vals.filter_map { |el| el[0] if !el[1]}
	end
end

def solve_part1(numbers, boards)
	bingo_found = false
	for number in numbers do
		for board in boards do
			# avoid short-cirquit skipping of marking
			bingo_found = board.mark(number).is_bingo? || bingo_found
		end

		if bingo_found
			unmarked_sums = boards.filter_map { |b| b.unmarked.sum if b.is_bingo? }
			return unmarked_sums.max * number
		end
	end
end

def solve_part2(numbers, boards)
	for number in numbers do
		if boards.length > 1
			boards.each_entry { |b| b.mark(number) }
				.filter! { |b| !b.is_bingo? }
		else
			if boards.first.mark(number).is_bingo?
				return boards.first.unmarked.sum * number
			end
		end
	end
end

lines = IO.readlines("04.txt").map { |line| line.strip }

numbers = lines[0].split(",").map { |s| s.to_i }
boards = lines[1..]
	.chunk { |l| l.empty? }
	.filter_map { |chunk| BingoGrid.new(chunk[1]) if !chunk[0] }

puts(solve_part1(numbers, boards.dup))
puts(solve_part2(numbers, boards))
