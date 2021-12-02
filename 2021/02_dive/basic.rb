x, y = 0, 0

lines = IO.readlines("input.txt")

directions = lines.map { |line| line.split }
directions = directions.map { |d| [d[0], d[1].to_i] }

for direction in directions do
	case direction[0]
	when "up"
		y -= direction[1]
	when "down"
		y += direction[1]
	when "forward"
		x += direction[1]
	end
end

print(x*y)
