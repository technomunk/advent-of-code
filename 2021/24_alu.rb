REGISTER_INDEX = {
	"x" => 0,
	"y" => 1,
	"z" => 2,
	"w" => 3,
}
OP_SIGN = {
	"add" => "+",
	"mul" => "*",
	"div" => "/",
	"mod" => "%",
	"eql" => "==",
}

def intersect?(a, b)
	amin, amax = a.minmax
	bmin, bmax = b.minmax
	return amin <= bmax && amax >= bmin
end

class Op
	def initialize(o, a, b)
		@o, @a, @b = o, a, b
	end

	def to_s
		"(#{@a} #{OP_SIGN[@o]} #{@b})"
	end

	def minmax
		amin, amax = @a.minmax
		bmin, bmax = @b.minmax
		case @o
		when "add"
			return [amin + bmin, amax + bmax]
		when "mul"
			return [amin * bmin, amax * bmax]
		when "div"
			return [amin / bmax, amax / bmin]
		when "mod"
			return [0, 26]
		when "eql"
			return [0, 1]
		end
	end

	def self.do(o, a, b)
		unless a.is_a?(Integer) && b.is_a?(Integer)
			return nil
		end

		case o
		when "add"
			return a + b
		when "mul"
			return a * b
		when "div"
			return a / b
		when "mod"
			return a % b
		when "eql"
			return (a == b) ? 1 : 0
		else
			raise "unknown op: #{o}"
		end
	end

	def self.trivial(o, a, b)
		case o
		when "add"
			return a if b == 0
			return b if a == 0
		when "mul"
			return a if b == 1
			return b if a == 1
			return 0 if a == 0 || b == 0
		when "div"
			return a if b == 1
		when "eql"
			return 0 if !intersect?(a, b)
		end

		return self.do(o, a, b)
	end
end

class Inp
	def initialize(index)
		@i = index
	end

	def to_s
		"d#{@i}"
	end

	def minmax
		[1, 9]
	end
end

class Integer
	def minmax
		[self, self]
	end
end

class Array
	# Convert array of instructions to 4 Op stacks
	def monad(registers = [0, 0, 0, 0])
		digit = 0
		for line in self do
			op, a, b = line.split()
			ri = REGISTER_INDEX[a]
			if op == "inp"
				registers[ri] = Inp.new(digit)
				digit += 1
			else
				a = registers.decode(a)
				b = registers.decode(b)
				registers[ri] = Op.trivial(op, a, b) || Op.new(op, a, b)
			end
		end

		return registers
	end

	def decode(n)
		i = REGISTER_INDEX[n]
		return self[i] if i
		return n.to_i
	end
end

lim = ARGV[0].to_i if ARGV[0]
monad = STDIN.readlines
	.map! { |l| l.strip }
	.slice(0...lim)
	.monad

# puts(monad[REGISTER_INDEX["z"]])
for k, i in REGISTER_INDEX do
	puts "#{k}: #{monad[i]}, mm: #{monad[i].minmax}"
end
