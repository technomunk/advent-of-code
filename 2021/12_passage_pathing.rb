require "set"

class Graph
	attr_reader(:nodes)

	def initialize(edges)
		@nodes = Hash.new
		for a, b in edges do
			self.nodes(a, b)
			self.edge(a, b)
		end
	end

	def count_paths(allowed_duplicates, node = "start", curpath = [])
		if node == "start" && !curpath.empty?
			return 0
		end

		if node == "end"
			return 1
		end

		node_is_duplicate = node.minor? && curpath.include?(node)
		if allowed_duplicates > 0 || !node_is_duplicate
			allowed_duplicates -= node_is_duplicate ? 1 : 0
			curpath.push(node)
			return @nodes[node].reduce(0) { |acc, n| acc + self.count_paths(allowed_duplicates, n, curpath.dup) }
		end

		return 0
	end

	def nodes(*_nodes)
		for _node in _nodes do
			unless @nodes.key?(_node)
				@nodes[_node] = Set.new
			end
		end
	end

	def edge(a, b)
		@nodes[a].add(b)
		@nodes[b].add(a)
	end

	def to_s() @nodes.to_s end
end

class Array
	def to_graph() Graph.new(self) end
end

class String
	def major?() self.upcase == self end
	def minor?() self.downcase == self end
end

graph = STDIN.readlines()
	.map { |l| l.strip.split("-") }
	.compact
	.to_graph

part1 = graph.count_paths(allowed_duplicates=0)
part2 = graph.count_paths(allowed_duplicates=1)

puts(part1)
puts(part2)
