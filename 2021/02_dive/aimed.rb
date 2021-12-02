x, y, dy = 0, 0, 0

lines = IO.readlines("input.txt")

directions = lines.map { |line| line.split }
directions = directions.map { |d| [d[0], d[1].to_i] }

for direction in directions do
	case direction[0]
	when "up"
		dy -= direction[1]
	when "down"
		dy += direction[1]
	when "forward"
		x += direction[1]
		y += dy * direction[1]
	end
end

puts x*y
