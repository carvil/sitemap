# Sitemap

Crawls a domain to obtain a sitemap.

## Installation

Since this gem wasn't published, you will have to run the following commands
to install it:

    bundle install

To install the dependencies, then:

    bundle exec rake build

Which will generate the .gem file in the `pkg` directory, and finally:

    gem install pkg/sitemap-0.0.1.gem

If you use `rbenv`, please also run:

    rbenv rehash

## Usage

There are basically three ways of using `sitemap`. All of them produce the same results,
which is:

* a `map.json` file containing a flat structure of links pointing to a list of links from that page
* a `graph.dot` file, which can then be used to create a visual representation of the sitemap using
graphviz.

In order to generate the graph view, you should install graphviz (homebrew recommended for Mac OSX) and run, for example:

    dot -v -Tsvg graph.dot -o graph.svg

This will generate the svg version of the graph. Please note that it can take a few
minutes to generate the graph, if the url contains many links.

### From the source

First, `cd` into the gem directory and run, for example:

    ./bin/sitemap from http://carvil.github.com

This will create the files mentioned above in the current directory.

### As a gem in the command line

After installing the gem as mentioned in the installation section, you can run it like this:

    sitemap from http://carvil.github.com

Again, this will create the files mentioned above in the current directory.

### As a gem in an interpreter

Finally, in order to use it in `irb` or `pry`, one should install the gem as described in
the installation section and then:

    $ pry
    [1] pry(main)> require 'sitemap'
    => true
    [2] pry(main)> crawler = Sitemap::Crawler.crawl('http://carvil.github.com')
    => #<Sitemap::Crawler:0x007fdecb233b40
    ...(the crawler object)

It is then easy to interact with the hash table of links:

    [3] pry(main)> crawler.map
    => {"/"=>
      ["/archive.html",
      "/pages.html",
      ...(more links)...

Or the graph:

    [4] pry(main)> crawler.graph
    => [(/-/), (/-//ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js),
    ...(more graph edges)...

In order to generate the output, one can use:

    [5] pry(main)> crawler.generate_map
    Map output written to map.json
    => nil

to generate the map, or:

    [6] pry(main)> crawler.generate_dot_file
    Graphviz output written to graph.dot
    => nil

To generate the graph in graphviz format.

## Testing

In order to run the tests, run the following command:

    bundle exec rspec

