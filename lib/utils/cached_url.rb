require "open-uri"
require "digest/sha1"
require "singleton"

module CheapTaxi
  module Utils
    class CachedUrl
      include Singleton

      attr_reader :cache_map

      BASE_CACHE_DIR = Rails.root.join('tmp/cache/parser/')

     def initialize
        @cache_map = {}
        Dir.mkdir(BASE_CACHE_DIR) unless Dir.exist? BASE_CACHE_DIR
        Dir[BASE_CACHE_DIR.join("**/*")].each do |cached_file_path|
          if File.file? cached_file_path
            basename = File.basename(cached_file_path)
            cache_key = cached_file_path.gsub(BASE_CACHE_DIR.to_s, '').gsub(basename, '').gsub(/\/$/, '')
            @cache_map[cache_key] = [] unless @cache_map.has_key? cache_key
            @cache_map[cache_key].push(basename)
          end
        end

      end

      def get(url, group, use_cache = true)
        url_digest = Digest::SHA1.hexdigest(url)
        expected_dir = BASE_CACHE_DIR.join(group)
        expected_path = expected_dir.join(url_digest)
        content = ''
        if use_cache && @cache_map.has_key?(group) && @cache_map[group].include?(url_digest)
          content = open(expected_path).read if File.exist? expected_path
        end
        if content.empty?
          content = open(url).read()
          FileUtils.mkpath(expected_dir) unless Dir.exist? expected_dir
          @cache_map[group] = [] unless @cache_map.has_key? group
          File.open(expected_path, 'w') do |f|
            f.write(content)
            @cache_map[group].push(url_digest) unless @cache_map[group].include? url_digest
          end
        end
        content
      end
    end
  end
end