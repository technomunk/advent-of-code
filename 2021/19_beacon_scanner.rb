# obv look at deltas between each coordinates between scanners
# each scanner has just one orientation
#
# 0: do all 24 permutations of each scanner? 26*24 = 624 sets of coordinates
class Map
	attr_reader(:beacons, :scanners)

	def initialize(scan)
		@beacons = scan
		@deltas = @beacons.deltas
		@scanners = [[0, 0, 0]]
	end

	def try_add!(scan)
		for rot in 0...24 do
			rscan = scan.map { |s| s.rotation(rot) }
			rscan_deltas = rscan.deltas

			intersection = rscan_deltas & @deltas
			if !intersection.empty? && self.try_beacons!(rscan)
				return true
			end
		end

		return false
	end

	def try_beacons!(scan)
		for base in @beacons do
			for el in scan do
				delta = base.lneg(el)
				dscan = scan.map { |pt| pt.lsum(delta) }

				intersection = @beacons & dscan
				if intersection.length >= 12
					dscan.reject! { |pt| intersection.any?(pt) }
					@beacons.concat(dscan)
					@deltas = @beacons.deltas
					@scanners.push(delta)
					return true
				end
			end
		end

		return false
	end
end

class Array
	def deltas
		self.combination(2)
			.map { |a, b| [a[0] - b[0], a[1] - b[1], a[2] - b[2] ] }
	end

	def lneg(o)
		[ self[0] - o[0], self[1] - o[1], self[2] - o[2] ]
	end

	def lsum(o)
		[ self[0] + o[0], self[1] + o[1], self[2] + o[2] ]
	end

	def mdist(o)
		lneg(o).map { |x| x.abs }
			.sum
	end

	def rotation(n)
		# Google 24 unit rotations or use a rubics cube as an aid
		if n == 0
			return self.dup
		end

		r = self
		rots = 0
		for _ in 0..1 do
			for _ in 0..2 do
				r = r.roll
				rots += 1
				if rots == n
					return r
				end

				for _ in 0..2 do
					r = r.turn
					rots += 1
					if rots == n
						return r
					end
				end
			end
			r = r.roll.turn.roll
		end
	end

	def rotations
		(0...24).map { |n| self.rotation(n) }
	end

	def roll
		[ self[0], self[2], -self[1] ]
	end

	def turn
		[ -self[1], self[0], self[2] ]
	end
end

scanners = STDIN.readlines
	.map { |l| l.strip }
	.chunk_while { |a, b| !a.empty? }
	.to_a
	.each do |c|
		c.shift
		c.filter! { |x| !x.empty? }
		c.map! do |p|
			pts = p.split(",")
			pts.map { |x| x.to_i }
		end
	end

lastlen = scanners.length
# Starting at 0 the algorithm gets stuck
# TODO: debug
map = Map.new(scanners.delete_at(1))
until scanners.empty? || scanners.length == lastlen do
	lastlen = scanners.length
	scanners.reject! { |s| map.try_add!(s) }
end

part1 = map.beacons.length
part2 = map.scanners
	.combination(2)
	.map { |a, b| a.mdist(b) }
	.max

puts(part1)
puts(part2)
