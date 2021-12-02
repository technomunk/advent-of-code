x, y, dy = 0, 0, 0

lines = IO.readlines("input.txt")

for line in lines do
	dir, amt = line.split
	amt = amt.to_i

	case dir
	when "up"
		dy -= amt
	when "down"
		dy += amt
	when "forward"
		x += amt
		y += dy * amt
	end
end

puts x*y
