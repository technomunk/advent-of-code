class String
	def is_digit?
		return self >= "0" && self <= "9"
	end
end

class Integer
	def mag() return self end
end

class Array
	def snail_add(other)
		self.dup
			.snail_add!(other)
	end

	def snail_add!(other)
		self.unshift("[")
		self.concat(other)
		self.push("]")
		self.snail_reduce!
	end

	def snail_reduce!
		done = false
		until done do
			done = !self.snail_explode! && !self.snail_split!
		end
		return self
	end

	def snail_explode!
		depth = 0
		last_integer = false
		for el, idx in self.each_with_index do
			case el
			in "["
				depth += 1
				last_integer = false
			in "]"
				depth -= 1
				last_integer = false
			else
				if depth > 4
					if last_integer
						self.add_right!(self[idx - 1], idx - 2)
						self.add_left!(el, idx + 1)
						self[idx + 1] = 0
						self.slice!(idx - 2, 3)
						return true
					end
					last_integer = true
				end
			end
		end
		return false
	end

	def snail_split!
		for el, i in self.each_with_index do
			if el.is_a?(Integer) && el >= 10
				self[i] = "["
				a = el / 2
				b = (el + 1) / 2
				self.insert(i + 1, a, b, "]")
				return true
			end
		end
		return false
	end

	def add_right!(n, max_idx = self.length - 1)
		for i in (0..max_idx).reverse_each do
			if self[i].is_a? Integer
				self[i] += n
				return
			end
		end
	end

	def add_left!(n, start_idx = 0)
		for i in start_idx...self.length do
			if self[i].is_a? Integer
				self[i] += n
				return
			end
		end
	end

	def to_tree
		node_stack = []
		for el, idx in self.each_with_index do
			case el
			in Integer
				node_stack.push(el)
			in "]"
				b = node_stack.pop()
				a = node_stack.pop()
				node_stack.push([a, b])
			else
				# do nothing
			end
		end

		return node_stack[0]
	end

	def mag
		if self.length != 2
			return self.to_tree.mag
		end
		return 3 * self[0].mag + 2 * self[1].mag
	end
end

numbers = STDIN.readlines
	.map do |l|
		l.strip
			.chars
			.chunk_while { |a, b| a.is_digit? && b.is_digit? }
			.to_a
			.flatten
			.filter { |x| x != "," }
			.map { |x| x.is_digit? ? x.to_i : x }
	end

part1 = numbers
	.reduce { |a, b| a.snail_add(b) }
	.mag

part2 = numbers
	.permutation(2)
	.map { |a, b| a.snail_add(b).mag }
	.max

puts(part1)
puts(part2)
