#encoding: utf-8
module CheapTaxi
  module Utils
    class Graph

      def initialize
        @g = {}
        @nodes = Array.new
        @infinity = 1 << 64
      end

      def add_edge(s,t,w) 		# s= source, t= target, w= weight
        if (not @g.has_key?(s))
          @g[s] = {t=>w}
        else
          @g[s][t] = w
        end

        if (not @g.has_key?(t))
          @g[t] = {s=>w}
        else
          @g[t][s] = w
        end

        if (not @nodes.include?(s))
          @nodes << s
        end
        if (not @nodes.include?(t))
          @nodes << t
        end
      end

      def dijkstra(s)
        @d = {}
        @prev = {}

        @nodes.each do |i|
          @d[i] = @infinity
          @prev[i] = -1
        end

        @d[s] = 0
        q = @nodes.compact
        while (q.size > 0)
          u = nil
          q.each do |min|
            if (not u) or (@d[min] and @d[min] < @d[u])
              u = min
            end
          end
          if (@d[u] == @infinity)
            break
          end
          q = q - [u]
          @g[u].keys.each do |v|
            alt = @d[u] + @g[u][v]
            if (alt < @d[v])
              @d[v] = alt
              @prev[v]  = u
            end
          end
        end
      end

      def get_path(dest, all_vertex=[])
        all_vertex.push(dest)
        if @prev[dest] != -1
          get_path(@prev[dest], all_vertex)
        end
        all_vertex.reverse
      end

      def shortest_paths(s)
        result_path = []
        @source = s
        dijkstra s
        @nodes.each do |dest|
          path = get_path(dest)
          if @d[dest] != @infinity
            result_path << {:from => s, :to => dest, :path => path, :distance => @d[dest]} if s != dest
          end
        end
        result_path
      end
    end
  end
end
