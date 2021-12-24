# notice that z = z*26 if vars[0] == 1
# z = z/26 only if vars[0] == 26 and a pair of digits overlaps
# use this script to get variables and pen and paper to solve the resulting equation

# Decompiled loop of 18 lines
def iteration(z, w, vars)
	t = (z % 26)
	z /= vars[0]  # 1 or 26
	if t + vars[1] != w
		z *= 26
		z += w+vars[2]
	end
	return z
end

vars = STDIN.readlines
	.each_slice(18)
	.map do |s|
		[4, 5, 15].map { |i| s[i].split[-1].to_i }
	end

for v, i in vars.each_with_index do
	puts "#{i+1}: #{v}"
end
