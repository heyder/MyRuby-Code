require 'net/http'
require 'uri'
require 'readability'
require 'sanitize'
require 'cgi'

module Aurelio
    def self.generate( opts={} )
        begin
            puts opts.inspect
            uri = URI.parse( opts[:uri] )    
            resp = request( uri )

            puts resp
            
            raise "Custom::Exception" unless resp.kind_of?( Net::HTTPOK )
                
            doc = Readability::Document.new( resp.body )

            content = Sanitize.fragment( CGI.unescapeHTML( doc.content ) )

            dic_name = "#{(uri.path.split('/').last + '_' + uri.host)}".gsub('.','_').downcase

            output( dic_name,  post_processing( most_common( content ) , opts ) )

        rescue RuntimeError, Encoding::CompatibilityError => e
            raise e
        else
            true
        end
        
    end

    private
    def self.output( dic_name, input )
        
        file = File.open("#{dic_name}.dic" , "w")
        input.each {|k,v| file.puts k }
        file.close
        
    end
    def self.request( uri )
        Net::HTTP::get_response( uri )
    end

    def self.most_common( string )

        begin
            replacement = { 
                'á' => "a",
                'ã' => 'a',
                'é' => 'e',
                'ë' => 'e',
                'í' => 'i',                    
                'ô' => 'o',
                'õ' => 'o',
                'ú' => 'u',
                'Ú' => 'U',
                'ç' => 'c'
            }
            
            encoding_options = {
                :invalid   => :replace,     # Replace invalid byte sequences
                :replace => "",             # Use a blank for those replacements
                :universal_newline => true, # Always break lines with \n
                # For any character that isn't defined in ASCII, run this
                # code to find out how to replace it
                :fallback => lambda { |char|
                # If no replacement is specified, use an empty string
                replacement.fetch(char, "")
                },
            }

            # get words
            words = string.strip.downcase.tr(')(][,.?!;\/:\'"','').gsub('&nbsp','').gsub('&amp','').encode(Encoding.find('ASCII'), encoding_options).split(' ')
            # count how many time we've seen the word and sort it
            orded_list = words.each_with_object(Hash.new(0)) { |e, h| h[e] += 1 }.sort_by {|_key, value| value}.reverse.uniq.to_h
            
        rescue Encoding::UndefinedConversionError => e
            Rails.logger.debug "#{ e.message } - (#{ e.class })"
        else
            return orded_list
        end

    end

    def self.post_processing(wordlist, opts={})
        string_size     =  opts[:str_size]
        string_count    =  opts[:str_count]

        wordlist.select {|k,v| (k.length >= string_size && v >= string_count) }

    end

end

