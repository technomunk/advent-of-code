ERROR_POINTS = {
	')' => 3,
	']' => 57,
	'}' => 1197,
	'>' => 25137,
}

COMPLETE_POINTS = {
	')' => 1,
	']' => 2,
	'}' => 3,
	'>' => 4,
}

OPENERS = {
	')' => '(',
	']' => '[',
	'}' => '{',
	'>' => '<',
}

CLOSERS = OPENERS.map { |k, v| [v, k] }
	.to_h

class String
	def completion
		opener_stack = []
		for c in self.chars do
			expected_opener = OPENERS[c]
			if expected_opener
				if opener_stack.pop() != expected_opener
					return c
				end
			else
				opener_stack.push(c)
			end
		end

		return opener_stack.reverse
			.map { |c| CLOSERS[c] }
	end
end

class Array
	def score
		self.reduce(0) { |acc, c| acc = acc * 5 + COMPLETE_POINTS[c] }
	end

	def middle
		return self[self.length / 2]
	end
end

completions = STDIN.readlines
	.map { |l| l.strip.completion }

part1 = completions.filter { |c| c.is_a? String }
	.map { |c| ERROR_POINTS[c] }
	.sum

part2 = completions.filter { |c| c.is_a? Array }
	.map { |c| c.score }
	.sort
	.middle

puts(part1)
puts(part2)
