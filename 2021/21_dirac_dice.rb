# Credit to Mr Ahab
DIRAC_DIST = { 3=>1, 4=>3, 5=>6, 6=>7, 7=>6, 8=>3, 9=>1 }

class Die
	attr_reader(:next)
	def initialize
		@next = 1
	end

	def roll
		value = @next
		@next = @next % 100 + 1
		return value
	end
end

def count_universes(roll, m, p0, s0, p1, s1, first = true)
	if first
		p0 = (p0 + roll - 1) % 10 + 1
		s0 += p0

		if s0 >= 21
			return [m, 0]
		end
	else
		p1 = (p1 + roll - 1) % 10 + 1
		s1 += p1

		if s1 >= 21
			return [0, m]
		end
	end

	u0, u1 = 0, 0
	for v0, v1 in DIRAC_DIST.map { |k, v| count_universes(k, v * m, p0, s0, p1, s1, !first) } do
		u0 += v0
		u1 += v1
	end

	return u0, u1
end

def solve_part1(positions)
	die = Die.new
	scores = positions.map { |_| 0 }
	active = 0
	roll_count = 0

	while scores[active] < 1000 do
		roll_count += 3
		roll_value = (1..3).map { |_| die.roll }
			.sum
		positions[active] = (positions[active] + roll_value - 1) % 10 + 1
		scores[active] += positions[active]
		if scores[active] >= 1000
			break
		end

		active = (active + 1) % positions.length
	end

	return scores[active - 1] * roll_count
end

def solve_part2(positions)
	p0, p1 = positions
	DIRAC_DIST.map { |k, v| count_universes(k, v, p0, 0, p1, 0) }
		.reduce { |a, x| [a[0] + x[0], a[1] + x[1]] }
		.max
end

positions = STDIN.readlines
	.map { |l| l.strip.split[-1] }
	.map { |p| p.to_i }

part1 = solve_part1(positions)
part2 = solve_part2(positions)

puts(part1)
puts(part2)
