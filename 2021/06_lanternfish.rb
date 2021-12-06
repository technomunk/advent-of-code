class Hash
	def next_day
		vals = {}
		vals.default = 0
		for timer, count in self.each
			if timer - 1 < 0
				vals[8] += count
				vals[6] += count
			else
				vals[timer - 1] += count
			end
		end
		return vals
	end
end

def solve(timers, days)
	counts = {}
	counts.default = 0
	for timer in timers do
		counts[timer] += 1
	end
	for i in 1..days do
		counts = counts.next_day
	end
	return counts.values.sum
end

input = STDIN.readline
timers = input.split(",").map { |x| x.to_i }
puts(solve(timers, 80))
puts(solve(timers, 256))
