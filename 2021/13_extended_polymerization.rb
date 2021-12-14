class Array
	def apply(rules)
		inserted = self.each_cons(2)
			.map { |p| rules[p] }
		self.zip(inserted)
			.flatten
			.compact
	end

	def apply!(rules)
		inserted = self.each_cons(2)
			.map { |p| rules[p] }

		offset = 1
		for e, i in inserted.each_with_index do
			if e
				self.insert(i + offset, e)
				offset += 1
			end
		end
	end
end

def solve(chain, rules, n)
	for i in 1..n do
		chain.apply!(rules)
	end
	_, min, _, max = chain.tally
		.minmax_by { |_, v| v }
		.flatten
	return max - min
end

lines = STDIN.readlines
	.map { |l| l.strip }

chain, rules = lines[0], lines[2..]

chain = chain.chars.to_a
rules = rules.map { |r| r.split(" -> ") }
	.map { |p, e| [p.chars.to_a, e] }
	.to_h

puts(solve(chain, rules, 10))
puts(solve(chain, rules, 30))
