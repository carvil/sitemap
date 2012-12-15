require "sitemap/version"
require "sitemap/crawler"

module Sitemap
  class Map
    def self.create(url)
      puts "Crawling #{url}..."
      crawler = Sitemap::Crawler.crawl(url)
      crawler.generate_map
      crawler.generate_dot_file
    end
  end
end
