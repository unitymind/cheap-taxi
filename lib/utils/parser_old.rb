require "nokogiri"
require "open-uri"
require "graph"
require "digest/sha1"

module CheapTaxi::Utils
  module Parser
    def parse_districts
      puts "Парсим административные округа, районы и станции метро города Москвы..."

      area_pattern = Regexp.new('Район занимает территорию в (\d*)')
      population_pattern = Regexp.new('населения составляет порядка (\d*)')
      doc = Nokogiri::HTML(open("http://mosopen.ru/regions"))

      doc.search(".//div[@id='regions_by_districts']/table[@class='regions_list']/tr/td/p").each do |district_doc|
        district = District.new
        ActiveRecord::Base.transaction do
          district_doc.search(".//a").each do |district_href|
            if district_href.attributes["href"].value =~ /district/
              break if district_href.attributes["title"].value == 'Зеленоградский административный округ'
              district.name = district_href.attributes["title"].value
              district.save
              puts "\t '#{district.name}' добавлен."
            else
              region = Region.create(:name => district_href.content, :district => district,
                                     :sha1_hash => Digest::SHA1.hexdigest(district_href.attributes["href"].value),
                                     :url => district_href.attributes["href"].value)

              puts "\t\t '#{region.name}' добавлен."

              region_doc = Nokogiri::HTML(open(district_href.attributes["href"].value))
              region_doc.search(".//span[@class='metro_station']/a").each do |metro_href|
                url = metro_href.attributes["href"].value
                sha1_hash = Digest::SHA1.hexdigest(url)

                metro_station = MetroStation.where(:sha1_hash => sha1_hash).first
                if metro_station.nil?
                  name = metro_href.content
                  if url =~ /_rad$/
                    name += " (Кольцевой линии)"
                  elsif url =~ /_fil$/
                    name += " (Филёвской линии)"
                  elsif url =~ /_kah$/
                    name += " (Каховской линии)"
                  elsif url =~ /_tag$/
                    name += " (Таганско-Краснопресненской линии)"
                  elsif url =~ /_kalin$/
                    name += " (Таганско-Краснопресненской линии)"
                  end
                  metro_station = MetroStation.create(:name => name, :url => url, :sha1_hash => sha1_hash)
                end
                region.metro_stations << metro_station
                puts "\t\t\t Найдена станция метро '#{metro_station.name}'."
              end
    #          region_doc.search(".//h3[@id='regions_list']")[0].next.next.search(".//a").each do |nearest_href|
    #            region_links_map[region.name].push << nearest_href.content
    #          end
              matches = area_pattern.match region_doc.to_html
              region.area = matches[1].to_i unless matches.nil?
              matches = population_pattern.match region_doc.to_html
              region.population = matches[1].to_i unless matches.nil?
              region.save
            end
          end
        end
      end
    end

    def parse_regions_links
      puts 'Парсим карту соседних районов...'
      Region.all.each do |region|
        nearest_ids = []
        region_doc = Nokogiri::HTML(open(region.url))
        region_doc.search(".//h3[@id='regions_list']")[0].next.next.search(".//a").each do |nearest_href|
          nearest_ids  << Region.where(:sha1_hash => Digest::SHA1.hexdigest(nearest_href.attributes["href"].value)).select("id").first.id
        end
        ActiveRecord::Base.transaction do
          nearest_ids.each { |to_region_id| RegionLink.create(:from_region_id => region.id, :to_region_id => to_region_id)}
        end
        puts "\t '#{region.name}' обработан."
      end
    end

    def patch_region_links
      puts 'Корректируем карту соседних районов...'
      Region.all.each do |from_region|
        from_region.to_regions.each do |to_region|
          unless to_region.to_regions(true).include? from_region
            RegionLink.create(:from_region => to_region, :to_region => from_region)
            puts "\t'#{to_region.name}' не ссылается на '#{from_region.name}'. Исправлено!"
          end
        end
      end
    end

    def create_routes_graph
      puts "Создаем карту кратчайших маршрутов..."
      graph = Graph.new
      result_graph = []
      processed = []
      RegionLink.all.each { |link| graph.add_edge(link.from_region_id, link.to_region_id, Region.where(:id => [link.from_region_id, link.to_region_id]).average(:area).to_i) }
      Region.select("id").all.each { |r| result_graph.concat graph.shortest_paths(r.id) }
      ActiveRecord::Base.transaction do
        result_graph.each do |route|
          route_key = "#{route[:from]} -> #{route[:to]}"
          unless processed.include? route_key
            Route.create(:from_region_id => route[:from], :to_region_id => route[:to],
                         :path => route[:path].join(','), :routes_count => (route[:path].size-1),
                         :distance => (route[:distance] * 0.01 * 0.5).round(2).to_f)
            processed.push route_key
            puts "\tМаршрут '#{route_key}' создан."
          end
        end
      end
    end
  end
end