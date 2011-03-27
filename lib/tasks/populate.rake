#encoding: utf-8
require "utils/graph"

namespace :db do
  namespace :populate do

    desc "Populate and generate (randomly) needed data"
    task(:all => ["db:populate:routes"])

    desc "Create graph from RegionLinks and Regions. Find shortest path from one region to another and save them to database"
    task :routes => :environment do
      puts "\n" + "** ".bold + "Создаем карту кратчайших маршрутов...".green.bold
      graph = CheapTaxi::Utils::Graph.new
      result_graph = []
      created = 0
      RegionLink.all.each { |link| graph.add_edge(link.from_region_id, link.to_region_id, Region.where(:id => [link.from_region_id, link.to_region_id]).average(:area).to_i) }
      Region.select("id").all.each { |r| result_graph.concat graph.shortest_paths(r.id) }
      ActiveRecord::Base.transaction do
        result_graph.each do |route|
          route_key = "#{route[:from]} -> #{route[:to]}"
          unless Route.where(:from_region_id => route[:from], :to_region_id => route[:to]).exists?
            Route.create(:from_region_id => route[:from], :to_region_id => route[:to],
                         :path => route[:path].join(','), :routes_count => (route[:path].size-1),
                         :distance => (route[:distance] * 0.01 * 0.5).round(2).to_f)
            created += 1
          end
        end
      end
      puts "    -->".bold + "  Создано новых маршрутов: ".green + created.to_s
    end
  end
end
