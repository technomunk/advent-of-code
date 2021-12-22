class Box
	include Enumerable
	attr_reader(:x, :y, :z)

	def initialize(x, y, z)
		@x, @y, @z = x, y, z
	end

	def self.try(x, y, z)
		if [x, y, z].any? { |n| n.size == 0 }
			return nil
		end
		return Box.new(x, y, z)
	end

	def min_pt
		return @x.min, @y.min, @z.min
	end

	def max_pt
		return @x.max, @y.max, @z.max
	end

	def each
		yield @x
		yield @y
		yield @z
	end

	def intersection(o)
		x, y, z = @x.intersection(o.x), @y.intersection(o.y), @z.intersection(o.z)
		return Box.try(x, y, z)
	end

	def intersect?(o)
		@x.intersect?(o.x) && @y.intersect?(o.y) && @z.intersect?(o.z)
	end

	# Get self region without the intersection with provided box, always returns an array
	def negation(o, debug = false)
		i = self.intersection(o)
		unless i
			return [self]
		end

		boxes = [
			# slice on Z
			Box.try(@x, @y, @z.min..i.z.before),
			Box.try(@x, @y, i.z.after..@z.max),
			# slice on Y
			Box.try(@x, @y.min..i.y.before, i.z),
			Box.try(@x, i.y.after..@y.max, i.z),
			# slice on X
			Box.try(@x.min..i.x.before, i.y, i.z),
			Box.try(i.x.after..@x.max, i.y, i.z),
		]
		if debug
			puts "negation["
			puts boxes
			puts "]"
		end
	
		boxes.compact!
		return boxes
	end

	def deintersect(o)
		unless self.intersect?(o)
			return [self, o]
		end

		if self.cover?(o)
			return [self]
		elsif o.cover?(self)
			return [o]
		end

		if o.x == (2..17) && o.y == (-20..-8) && o.z == (-3..13)
			puts "Box.deintersect"
			puts self
			puts o
			puts "result"
			puts self.negation(o, true) << o
			puts
		end

		boxes = self.negation(o) << o
		unless boxes.intersections.empty?
			raise "Box.deintersect is wrong"
		end
		return boxes
	end

	def volume
		self.reduce(1) { |a, c| a * c.size }
	end

	def to_s
		return "Box{ x: #{@x}, y: #{@y}, z: #{z}, vol: #{self.volume} }"
		# "Box.new(#{x},#{y},#{z})"
	end

	def cover?(o)
		@x.cover?(o.x) && @y.cover?(o.y) && @z.cover?(o.z)
	end

	def hash
		[@x, @y, @z].hash
	end

	def eql?(o)
		[@x, @y, @z].eql? [o.x, o.y, o.z]
	end
end

class String
	def to_box
		x, y, z = self.split(",").map do |c|
			min, max = c.slice(2..)
				.split("..")
				.map { |x| x.to_i }
			min..max
		end
		return Box.new(x, y, z)
	end
end

class Range
	def before
		self.min - 1
	end

	def after
		self.max + 1
	end

	def intersection(o)
		min = [self.min, o.min].max
		max = [self.max, o.max].min
		return min..max
	end

	def intersect?(o)
		return self.max >= o.min && self.min <= o.max
	end
end

class Array
	def intersections
		intersections = self.uniq.combination(2)
			.map { |a, b| a.intersection(b) }
		intersections.compact!
		return intersections
	end

	# Recursive volume of N boxes is sum of individual volumes - total_volume of all intersections
	def total_volume(d = 0)
		if self.empty?
			return 0
		end

		self.deintersect.sum { |b| b.volume }
	end

	def deintersect
		result = [self.first]
		for box in self do
			result.map! { |b| b.deintersect(box) }
				.flatten!
				.uniq!
		end
		puts result
		return result
	end
end

boxes = STDIN.readlines
	.map { |l| l.strip.split(" ", 2) }
	.map { |t, c| [t, c.to_box] }
	.each_with_object([]) do |line, boxes|
		type, box = line
		case type
		when "on"
			boxes.push(box)
		when "off"
			boxes.map! { |b| b.negation(box) }
				.flatten!
		end
	end

part1 = boxes.reject { |b| b.any? { |c| c.any? { |x| x < -50 || x > 51 } } }
	.deintersect
	.combination(2)
	.none? {|a, b| a.intersect?(b) }

puts(part1)
