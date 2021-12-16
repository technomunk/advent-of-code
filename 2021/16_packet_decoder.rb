class Packet
	attr_reader(:version, :type, :body)

	OPERATORS = {0=>"sum", 1=>"prd", 2=>"min", 3=>"max", 5=>">", 6=>"<", 7=>"=="}

	def initialize(version, type, body)
		@version = version
		@type = type
		@body = body
	end

	def version_sum
		if @body.is_a? Array
			return @body.reduce(@version) { |t, p| t + p.version_sum }
		end
		return @version
	end

	def evaluate
		if @type == 4
			return @body
		end
		mb = @body.map { |p| p.evaluate }

		case @type
		when 0
			return mb.sum
		when 1
			return mb.reduce(1) { |t,b| t * b }
		when 2
			return mb.min
		when 3
			return mb.max
		when 5
			return (mb[0] > mb[1]) ? 1 : 0
		when 6
			return (mb[0] < mb[1]) ? 1 : 0
		when 7
			return (mb[0] == mb[1]) ? 1 : 0
		end
	end

	def debug_print(maxdepth = 256, prefix = "")
		if maxdepth == 0
			puts(prefix + self.evaluate.to_s + ",")
			return
		end

		if @type == 4
			puts(prefix + @body.to_s + ",")
			return
		end

		puts(prefix + OPERATORS[@type] + "[")
		for sp in @body do
			sp.debug_print(maxdepth - 1, prefix + "  ")
		end
		puts(prefix + "],")
	end
end

class Integer
	def empty?
		self == 0
	end
end

class String
	def pop_packet!
		version = self.slice!(0, 3).to_i(2)
		type = self.slice!(0, 3).to_i(2)
		if type == 4
			body = self.pop_literal!
		else
			body = []
			len_type = self.slice!(0, 1)
			if len_type == "0"
				len = self.slice!(0, 15).to_i(2)
				body_str = self.slice!(0, len)
				until body_str.empty?
					body.push(body_str.pop_packet!)
				end
			else
				len = self.slice!(0, 11).to_i(2)
				for _ in 0...len do
					body.push(self.pop_packet!)
				end
			end
		end
		return Packet.new(version, type, body)
	end

	def pop_literal!
		r = 0
		repeat = true
		while repeat do
			repeat = self.chr == "1"
			r <<= 4
			n = self.slice!(0, 5).slice(1, 4)
			r += n.to_i(2)
		end
		return r
	end
end

packets = STDIN.readlines.map do |line|
	line.chars
		.map { |c| c.to_i(16).to_s(2).rjust(4, "0") }
		.join
		.pop_packet!
end

puts("part1:")
puts(packets.map { |p| p.version_sum })

puts("part2")
puts(packets.map { |p| p.evaluate })
