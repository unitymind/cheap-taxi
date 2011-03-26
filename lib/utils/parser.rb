#encoding: utf-8
require "singleton"
require "utils/cached_url"
require "nokogiri"
require "open-uri"

module CheapTaxi
  module Utils
    class Parser
      include Singleton

      PROFILE_REG_MATCH = /^http:\/\/www.taxodrom.ru\/taxi-moscow\/\d+$/

      def initialize
        @cache = CheapTaxi::Utils::CachedUrl.instance
      end

      def parse_company_profile_urls
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
        unless url =~ PROFILE_REG_MATCH
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

    end
  end

end