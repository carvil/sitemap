require 'spec_helper'

describe Sitemap::Crawler do

  let(:url)     { "http://dash-it-app.herokuapp.com" }
  let(:subject) {
    c = Sitemap::Crawler.new
    c.url = url
    c
  }
  let(:raw_links) { ["/users/sign_up","/users/password/new","http://twitter.com","#some_div","mailto:me@me.com"] }

  describe ".crawl" do
    context "given a valid url" do
      it "should crawl the site and return the crawler instance" do
        VCR.use_cassette('crawl', :record => :new_episodes) do
          c = Sitemap::Crawler.crawl(url)
          c.queue.should eq([])
          c.is_a?(Sitemap::Crawler).should be_true
          c.queue.should eq([])
        end
      end
    end
  end

  describe "#crawl" do
    context "given an instance of Sitemap::Crawl" do
      it "should crawl the page until there are no more links" do
        VCR.use_cassette('crawl_instance', :record => :new_episodes) do
          c = Sitemap::Crawler.new
          c.url = url
          c.queue << "/"
          c.crawl.keys.should =~ [
            "/",
            "/users/password/new",
            "/users/sign_in",
            "/users/sign_up",
            "/users/auth/facebook",
            "/users/auth/github",
            "/sessions/forgot_password"
          ]
          c.queue.should eq([])
        end
      end
    end
  end

  describe "#process_link" do
    context "given a link" do
      it "should fetch the body links, save them, and enqueue new links to process" do
        VCR.use_cassette('process_link', :record => :new_episodes) do
          subject.queue.empty?.should be_true
          subject.map.empty?.should be_true
          subject.graph.empty?.should be_true
          subject.process_link("/")
          subject.queue.should =~ [
            "/users/auth/github",
            "/users/auth/facebook",
            "/users/sign_up",
            "/users/password/new"
          ]
          subject.map["/"].should =~ [
            "/users/auth/github",
            "/users/auth/facebook",
            "/users/sign_up",
            "/users/password/new",
            "/assets/application-218e261a28dfbc4a5d182e1d74cfa56d.css",
            "/assets/application-8e2ee2948692900aca4cfa8a45d9478f.js",
            "/assets/github_32-ba5dc7eee4765074155e76a524060552.png",
            "/assets/facebook_32-9413ef3b6297484f5fc8d19879dec8cc.png"
          ]
          subject.graph.vertices.size.should eq(9)
          subject.graph.edges.size.should eq(8)
        end
      end
    end
  end

  describe "#fetch_body_links" do
    context "given a url" do
      it "should fetch the body links" do
        VCR.use_cassette('fetch_body_links', :record => :new_episodes) do
          subject.fetch_body_links("/").should =~ [
            "/users/auth/github",
            "/users/auth/facebook",
            "/users/sign_up",
            "/users/password/new",
            "/assets/application-218e261a28dfbc4a5d182e1d74cfa56d.css",
            "/assets/application-8e2ee2948692900aca4cfa8a45d9478f.js",
            "/assets/github_32-ba5dc7eee4765074155e76a524060552.png",
            "/assets/facebook_32-9413ef3b6297484f5fc8d19879dec8cc.png"]
        end
      end
    end
  end

  describe "invalid?" do
    context "given an invalid link" do
      it "should return true" do
        subject.invalid?("http://twitter.com").should be_true
        subject.invalid?("#some_div").should be_true
      end
    end

    context "given a valid link" do
      it "should return false" do
        subject.invalid?("/users/sign_in").should be_false
        subject.invalid?("/my_assets.css").should be_false
      end
    end

    context "given a link that throws an exception" do
      it "should return true" do
        subject.invalid?("some invalid link").should be_true
      end
    end
  end

  describe "#curate" do
    context "given a list with invalid urls" do
      it "should return a list of curated links" do
        subject.curate(raw_links).should eq(["/users/sign_up","/users/password/new"])
      end
    end

    context "given an empty list" do
      it "should return an empty list" do
        subject.curate([]).should eq([])
      end
    end
  end

  describe "#save" do
    context "given a link and a list of links on that page body" do
      it "should save the list of links in the map and the edges in the graph" do
        crawler = Sitemap::Crawler.new
        crawler.map[url].should be_nil
        crawler.graph.vertices.should eq([])
        crawler.graph.edges.should eq([])
        crawler.save(url,["link1","link2"])
        crawler.map[url].should =~ ["link1","link2"]
        crawler.graph.vertices.should =~ [url,"link1","link2"]
        crawler.graph.edges.to_s.should eq("[(http://dash-it-app.herokuapp.com-link1), (http://dash-it-app.herokuapp.com-link2)]")
      end
    end
  end

  describe "#enqueue" do
    let(:enqueue_crawler) { Sitemap::Crawler.new }

    context "given a link and a list of links already processed" do
      it "should not enqueue the links" do
        enqueue_crawler.map["/link1"] = ["/link2"]
        enqueue_crawler.queue.should eq([])
        enqueue_crawler.enqueue(url,["/link1"])
        enqueue_crawler.queue.should eq([])
      end
    end

    context "given a link and a list of links not yet processed" do
      it "should enqueue the links" do
        enqueue_crawler.queue.should eq([])
        enqueue_crawler.enqueue(url,["/link1"])
        enqueue_crawler.queue.should eq(["/link1"])
      end

    end

    context "given a link and a list of links to assets" do
      it "should not enqueue the links" do
        enqueue_crawler.queue.should eq([])
        enqueue_crawler.enqueue(url,["/link1.css"])
        enqueue_crawler.queue.should eq([])
      end
    end

    context "given a link and a list containing the same link" do
      it "should make sure the queue has unique values" do
        enqueue_crawler.queue << "/some_link"
        enqueue_crawler.enqueue(url,["/some_link"])
        enqueue_crawler.queue.should eq(["/some_link"])
      end
    end
  end

end
