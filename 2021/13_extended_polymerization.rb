class Hash
	def apply(rules)
		result = Hash.new
		result.default = 0
		for pair, count in self do
			b = rules[pair]
			if b
				a, c = pair.chars
				ab = a + b
				bc = b + c

				result[ab] += count
				result[bc] += count
			else
				result[pair] = count
			end
		end
		return result
	end

	def apply_n(rules, n)
		result = self
		for _ in 1..n do
			result = result.apply(rules)
		end
		return result
	end

	def count_first_elements
		elements = Hash.new
		elements.default = 0

		for pair, count in self do
			a, _ = pair.chars
			elements[a] += count
		end

		return elements
	end

	def solve(rules, n, last_element)
		elements = self.apply_n(rules, n).count_first_elements
		elements[last_element] += 1
		_, min, _, max = elements.minmax_by { |_, v| v }
			.flatten
		return max - min
	end
end

chain, _, *rules = STDIN.readlines
	.map { |l| l.strip }

rules = rules.map { |l| l.split(" -> ") }
	.to_h

pairs = chain.chars
	.each_cons(2)
	.map { |a, b| a + b }
	.tally

last_element = chain.chars.last
part1 = pairs.solve(rules, 10, last_element)
part2 = pairs.solve(rules, 40, last_element)

puts(part1)
puts(part2)
