require "set"

class String
	def to_dk  # to digit_key
		return self.chars.to_set
	end

	def to_dm  # to digit_map
		keys = self.split.map { |s| s.to_dk }
		# initialize trivial keys first
		dk = {
			1 => keys.find { |x| x.length == 2 },
			4 => keys.find { |x| x.length == 4 },
			7 => keys.find { |x| x.length == 3 },
			8 => keys.find { |x| x.length == 7 },
		}

		# initialize intermediate keys
		dk[3] = keys.find { |x| x.length == 5 && x.superset?(dk[7]) }
		dk[6] = keys.find { |x| x.length == 6 && !x.superset?(dk[7]) }
		dk[9] = keys.find { |x| x.length == 6 && x.superset?(dk[4]) }
		
		# reject known keys, only 0, 2 and 5 should remain
		keys.reject! { |x| dk.value?(x) }
		
		dk[0] = keys.find { |x| x.length == 6 }
		dk[2] = keys.find { |x| x.length == 5 && !x.subset?(dk[9]) }
		dk[5] = keys.find { |x| x.length == 5 && x.subset?(dk[9]) }

		return dk.map { |k, v| [v, k] } .to_h
	end
end

class Array
	def to_i
		return self.reduce(0) { |acc, n| acc * 10 + n }
	end
end

digits = STDIN.readlines
	.map { |l| l.strip.split(" | ") }  # split input lines
	.map { |d, n| [d.to_dm, n.split] }  # convert left hand side to digit map (see above) and right hand side to digits
	.map { |dm, n| n.map { |d| dm[d.to_dk] } }  # decode right hand side digits into numbers

part1 = digits.flatten.count { |d| [1, 4, 7, 8].include?(d) }
part2 = digits.map { |n| n.to_i } .sum
puts(part1)
puts(part2)
