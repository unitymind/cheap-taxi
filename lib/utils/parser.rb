#encoding: utf-8
require "singleton"
require "utils/cached_url"
require "nokogiri"
require "open-uri"

module CheapTaxi
  module Utils
    class Parser
      include Singleton

      COMPANY_PROFILE_URL_REG_MATCH = /^http:\/\/www.taxodrom.ru\/taxi-moscow\/\d+$/
      DISTRICT_URL_REG_MATCH = /http:\/\/mosopen.ru\/district\/[a-z]+$/
      REGION_URL_MATCH = /http:\/\/mosopen.ru\/region\/.+$/
      METRO_URL_REG_MATCH = /http:\/\/mosopen.ru\/metro\/station\/.+$/

      REGION_AREA_MATCH = /Район занимает территорию в (\d*)/
      REGION_POPULATION_MATCH = /населения составляет порядка (\d*)/

      METRO_URL_POSTFIX_MATCH = {
          /_rad$/ => " (Кольцевой линии)",
          /_fil$/ => " (Филёвской линии)",
          /_kah$/ => " (Каховской линии)",
          /_tag$/ => " (Таганско-Краснопресненской линии)",
          /_kalin$/ => " (Таганско-Краснопресненской линии)"
      }

      def initialize
        @cache = CheapTaxi::Utils::CachedUrl.instance
      end

      def grab_company_profile_urls
        urls = []
        begin
          doc = Nokogiri::HTML(@cache.get('http://www.taxodrom.ru/taxi-moscow', 'companies/moscow'))
          last_page_num = doc.search(".//a[@class='active']").find { |a| a.content == 'последняя »' }.attributes['href'].value \
            .gsub('/taxi-moscow?page=', '').to_i
          (1..last_page_num).each do |page_num|
            doc = Nokogiri::HTML(@cache.get("http://www.taxodrom.ru/taxi-moscow?page=#{page_num}", 'companies/moscow'))
            founded = doc.search(".//a").map { |a| a.attributes["href"].value }. \
                find_all { |a| a =~ /\/taxi-moscow\/\d+/ }. \
                map { |a| a.gsub('http://www.taxodrom.ru', '') }.uniq.map { |a| "http://www.taxodrom.ru#{a}"}
            urls.push(founded)
          end
        rescue OpenURI::HTTPError
        end
        urls.flatten.uniq
      end

      def parse_company_profile(url)
        unless url =~ COMPANY_PROFILE_URL_REG_MATCH
          raise ArgumentError, "Url '#{url}' is not valid taxodrom.ru company's profile url"
        end
        company = {}
        begin
          raise NameError if @cache.get(url, 'companies/moscow') =~ /По Вашему запросу ничего не найдено/

          doc = Nokogiri::HTML(@cache.get(url, 'companies/moscow'))
          company[:name] = doc.search(".//title")[0].content.split('|')[0].strip

          if company[:phones] = doc.search(".//label").find { |l| l.content == 'Телефон' }
            company[:phones] = company[:phones].parent.search(".//strong").map { |s| s.content.strip }.join("\n")
          end

          if company[:url] = doc.search(".//label").find { |l| l.content == 'Сайт службы такси' }
            company[:url] = company[:url].next.next.search(".//a")[0].attributes['href'].value
          end

          company[:car_types] = {}
          {:e_class => 'taxi-econom', :b_class => 'taxi-business', :v_class => 'taxi-vip'}.each do |type, postfix|
            doc.search(".//label/a[@href='/#{postfix}']")[0].parent.next.next. \
              search(".//li[@class='square']").each do |car|
                company[:car_types][type] = [] if company[:car_types][type].nil?
                company[:car_types][type].push(car.content.strip) unless company[:car_types][type].include? car.content.strip
            end
          end
        rescue OpenURI::HTTPError, NameError
        rescue Exception => e
          raise e
        end
        company
      end

      def parse_districts
        districts_info = {}
        Nokogiri::HTML(@cache.get('http://mosopen.ru/regions', 'cities/moscow')).\
          search(".//div[@id='regions_by_districts']/table[@class='regions_list']/tr/td/p").each do |district|
            district_url = ''
            district.search(".//a").each do |a|
              if a.attributes["href"].value =~ DISTRICT_URL_REG_MATCH && a.attributes["href"].value !~ /zelao$/
                district_url = a.attributes["href"].value
                districts_info[district_url] = { :name => a.attributes["title"].value }
              end
              if districts_info.has_key?(district_url) && a.attributes["href"].value =~ REGION_URL_MATCH
                districts_info[district_url][:regions] = {} unless districts_info[district_url].has_key?(:regions)
                districts_info[district_url][:regions][a.attributes["href"].value] = a.content
              end
            end
        end
        districts_info
      end

      def parse_region(region_url)
        region_info = {
            :metro_stations => {},
            :nearest_regions => [],
            :area => 0,
            :population => 0
        }

        doc = Nokogiri::HTML(@cache.get(region_url, 'cities/moscow'))

        doc.search(".//span[@class='metro_station']/a").\
          find_all { |a| a.attributes["href"].value =~ METRO_URL_REG_MATCH }.\
            each do |a|
              metro_url = a.attributes["href"].value
              metro_name = a.content
              METRO_URL_POSTFIX_MATCH.keys.each do |postfix|
                metro_name += METRO_URL_POSTFIX_MATCH[postfix] if metro_url =~ postfix
              end
              region_info[:metro_stations][metro_url] = metro_name
            end

        region_info[:nearest_regions] = doc.search(".//p").find { |p| p.to_html =~ /имеющие общую границу/ }.\
          search(".//a").find_all { |a| a.attributes["href"].value =~ REGION_URL_MATCH }.\
          map { |a| a.attributes["href"].value }

        region_info[:area] = $1.to_i if doc.to_html =~ REGION_AREA_MATCH
        region_info[:population] = $1.to_i if doc.to_html =~ REGION_POPULATION_MATCH

        region_info
      end

    end
  end
end