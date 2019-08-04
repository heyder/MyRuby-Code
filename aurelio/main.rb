require 'optparse'

options = {:uri => nil, :str_size => 3, :str_count => 1}
OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options]"

    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
    end
    opts.on("-u", "--uri URI", String, "URI to dump the wordlist form") do |u|
        options[:uri] = u
    end
    opts.on("-s", "--str-size SIZE", Integer, "String size") do |s|
        options[:str_size] = s
    end
    opts.on("-c", "--str-count COUNT", Integer, "Minimal time we've this string in the page") do |c|
        options[:str_count] = c
    end

end.parse!

require './aurelio.rb'

Aurelio.generate( options ) if $0 == __FILE__