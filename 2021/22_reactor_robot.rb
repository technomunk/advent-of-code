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

	def each
		yield @x
		yield @y
		yield @z
	end

	def each_pt
		for z in @z do
			for y in @y do
				for x in @x do
					yield x, y, z
				end
			end
		end
	end

	def intersection(o)
		x, y, z = @x.intersection(o.x), @y.intersection(o.y), @z.intersection(o.z)
		return Box.try(x, y, z)
	end

	def volume
		[@x, @y, @z].reduce(1) { |a, x| a * x.size }
	end

	def intersect?(o)
		@x.intersect?(o.x) && @y.intersect?(o.y) && @z.intersect?(o.z)
	end

	def to_s
		return "Box{ x: #{@x}, y: #{@y}, z: #{@z}, vol: #{self.volume} }"
	end

	# convert a point to a linear index relative to this box
	def li(x, y, z)
		x, y, z = x - @x.min, y - @y.min, z - @z.min
		return z * @y.size * @x.size + y * @x.size + x
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
	def total_volume
		boxes = []

		for type, box in self do
			intersections = []

			for prev_type, prev_box in boxes do
				intersection = box.intersection(prev_box)
				next unless intersection

				# to avoid double-counting add the intersection with the opposite sign
				# off off => some have already been turned off
				# off on => well, now it's on
				# on off => well not it's off
				# on on => don't double count
				other_type = prev_type == "on" ? "off" : "on"
				intersections.push([other_type, intersection])
			end
		
			boxes.concat(intersections)
			if type == "on"
				boxes << ["on", box]
			end
		end

		return boxes.sum { |t, b| t == "on" ? b.volume : -b.volume }
	end
end

boxes = STDIN.readlines
	.map { |l| l.strip.split(" ", 2) }
	.map { |t, c| [t, c.to_box] }

part1 = boxes.reject { |_, b| b.any? { |c| c.any? { |x| x < -50 || x > 50 } } }
	.total_volume
part2 = boxes.total_volume

puts(part1)
puts(part2)
