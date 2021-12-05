class Line
include Enumerable
	attr_reader(:start, :stop)

	def initialize(str)
		coords = str.split(" -> ")
		@start, @stop = coords.map do |c|
			c.split(",")
				.map { |el| el.to_i }
		end
	end

	def to_s
		return [@start, @stop].map { |c| c.map { |x| x.to_s }.join(",") }
			.join(" -> ")
	end

	def vertical?
		return @start[0] == @stop[0]
	end

	def horizontal?
		return @start[1] == @stop[1]
	end

	def diagonal?
		dx = @stop[0] - @start[0]
		dy = @stop[1] - @start[1]
		return dx.abs == dy.abs
	end

	def each
		x, y = @start
		dx = @stop[0] - start[0]
		dy = @stop[1] - start[1]
				
		yield [x, y]
		while [x, y] != @stop do
			case
			when self.horizontal?
				x += dx.sign
			when self.vertical?
				y += dy.sign
			when self.diagonal?
				x += dx.sign
				y += dy.sign
			else
				break
			end
			yield [x, y]
		end
	end
end

class Integer
	def sign
		return self >= 0 ? 1 : -1
	end
end

class Grid
include Enumerable

	def initialize(mag)
		@width = mag
		@visits = Array.new(mag * mag, 0)
	end

	def mark(x, y)
		@visits[y * @width + x] += 1
	end

	def mark_line(line)
		for x, y in line do
			self.mark(x, y)
		end
	end

	def to_s
		return @visits.each_slice(@width)
			.map { |s| s.map { |x| x == 0 ? "." : x.to_s } .join }
			.join("\n")
	end

	def each
		return @visits.each
	end
end

def solve_part1(lines, mag)
	grid = Grid.new(mag)

	for line in lines do
		if line.horizontal? || line.vertical?
			grid.mark_line(line)
		end
	end

	dangerous = grid.each.filter { |x| x > 1 }
	return dangerous.length
end

def solve_part2(lines, mag)
	grid = Grid.new(mag)

	for line in lines do
		grid.mark_line(line)
	end

	dangerous = grid.each.filter { |x| x > 1 }
	return dangerous.length
end

input = IO.readlines("05.txt")
lines = input.map { |l| Line.new(l) }

puts(solve_part1(lines, 1000))
puts(solve_part2(lines, 1000))
