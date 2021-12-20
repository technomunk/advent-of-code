class Image
	attr_reader(:pixels, :width, :height, :background)

	def initialize(pixels, width, background = 0)
		@pixels = pixels
		@width = width
		@background = background
	end

	def height
		@pixels.length / @width
	end

	# Returns 1 if pixel at given coordinate is lit and 0 otherwise
	def sample(x, y)
		if x < 0 || x >= @width || y < 0
			return @background
		end

		return @pixels[y * @width + x] || @background
	end

	# Sample a 3x3 area around provided coordinate
	# returns the interpreted number from sampled pixels
	def sample_for(x, y, debug = false)
		result = 0
		for dy in -1..1 do
			for dx in -1..1 do
				pt = self.sample(x + dx, y + dy)
				result <<= 1
				result += pt
			end
		end
		return result
	end

	def enhance(recipe)
		# result includes an extra pixel in each direction, as that's the interesting
		# region that is possibly different from background
		width = self.width + 2
		height = self.height + 2
		pixels = Array.new(width * height, 0)

		for y in 0...height do
			for x in 0...width do
				sample = self.sample_for(x - 1, y - 1)
				pt = recipe[sample]
				pixels[y * width + x] = (pt == "#") ? 1 : 0
			end
		end

		case @background
		when 0
			background = recipe[0] == "#" ? 1 : 0
		when 1
			background = recipe[511] == "#" ? 1 : 0
		end

		return Image.new(pixels, width, background)
	end

	def enhance_n(recipe, n)
		(1..n).reduce(self) { |img, _| img.enhance(recipe) }
	end

	def count_lit
		@pixels.sum
	end

	def to_s
		@pixels.map { |px| px == 1 ? "#" : "." }
			.each_slice(@width)
			.map { |l| l.join }
			.join("\n")
	end
end

class Array
	def to_img
		width = self[0].length
		pixels = self.join
			.chars
			.map { |px| px == "#" ? 1 : 0 }
		return Image.new(pixels, width)
	end
end

img = STDIN.readlines
	.map { |l| l.strip }
	.reject! { |l| l.empty? }

recipe = img.shift()
img = img.to_img

part1 = img.enhance_n(recipe, 2).count_lit
part2 = img.enhance_n(recipe, 50).count_lit

puts(part1)
puts(part2)
