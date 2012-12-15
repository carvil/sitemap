require 'faraday'
require 'faraday_middleware'
require 'nokogiri'
require 'uri'
require 'rgl/adjacency'
require 'rgl/dot'
require 'json'

module Sitemap
  class Crawler

    attr_accessor :queue, :url, :conn, :graph, :map

    MAX_NUM_THREADS = 5

    def self.crawl(url)
      crawler = Sitemap::Crawler.new
      crawler.url = url
      crawler.queue << "/"
      crawler.crawl
      crawler
    end

    def conn
      @conn ||= Faraday.new(:url => url) do |faraday|
        faraday.use FaradayMiddleware::FollowRedirects
        faraday.request  :url_encoded
        faraday.adapter  :net_http
      end
    end

    def queue
      @queue ||= []
    end

    def map
      @map ||= {}
    end

    def graph
      @graph ||= RGL::DirectedAdjacencyGraph.new
    end

    def crawl
      threads = []
      process_link(queue.pop)
      MAX_NUM_THREADS.times do
        threads << Thread.new do
          while link = queue.pop do
            process_link(link)
          end
        end
      end
      threads.each{|t| t.join }
      map
    end

    def process_link(link)
      raw_body_links = fetch_body_links(link)
      body_links = curate(raw_body_links)
      save(link, body_links)
      enqueue(link, body_links)
    end

    def fetch_body_links(link)
      response = conn.get(link)
      body = Nokogiri::HTML.parse(response.body)
      body.css('a[href],link[href],script[src],img[src]').map{ |node| node['href'] || node['src'] }
    end

    def curate(links)
      links.reject! do |link|
        invalid?(link)
      end
      links
    end

    def invalid?(link)
      URI.parse(link).absolute? or !/^#.*/.match(link).nil?
    rescue URI::InvalidURIError => e
      true
    end

    def save(link, body_links)
      body_links.each {|bl| graph.add_edge(link, bl) }
      map[link] = body_links
    end

    def enqueue(link, body_links)
      body_links.reject!{|link| map.has_key?(link)}
      body_links.each{|link| queue << link if File.extname(link).empty? }
      queue.uniq!
    end

    def generate_map
      File.open('map.json','w') do |f|
        f.write(JSON.pretty_generate(map))
      end
      puts "Map output written to map.json"
    end

    def generate_dot_file
      File.open('graph.dot','w') do |f|
        f.write(graph.to_dot_graph)
      end
      puts "Graphviz output written to graph.dot"
    end
  end
end
