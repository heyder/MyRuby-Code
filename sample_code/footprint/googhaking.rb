#!/usr/bin/env ruby
# Debugs
DEBUG = false

require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'


def build_http_request(url,use_proxy,proxy_addr,proxy_port)

  url = URI.parse(url)

  if ((url.port == 443) or (url.to_s.match(%r{http(s).*})))
    if (use_proxy)
      http = Net::HTTP.new(url.host,url.port,proxy_addr,proxy_port)
    else
      http = Net::HTTP.new(url.host,url.port)
    end 
    
     http.use_ssl=true
     http.verify_mode=OpenSSL::SSL::VERIFY_NONE

     return http

  else
    if (use_proxy)
      http = Net::HTTP.new(url.host,url.port,proxy_addr,proxy_port)
    else
      http = Net::HTTP.new(url.host,url.port)
    end 
     return http
  end 
end


def search(http,query_to_search)
	results = http.request_get(query_to_search).body
	return results
end


def get_dorks(dorkfile)
	require 'yaml'
    dorks_list = YAML::load_file(dorkfile)
	return dorks_list
end

def parse_result(result,domain)

	puts result if DEBUG

	found = []
	result.each do |url|
		url.each do |u|
			found << u.split('&')[0] if u.match(%r{^https?:\/\/\w+\.#{domain}})
		end
	end
	return found
end

def run(http,domain,dork_file)
	
	require 'uri'
	
	dorks = get_dorks(dork_file)
	result = []
	dorks.each do |dork|
		get_search_result = search(http,URI.escape("/search?q=site:.#{domain}+#{dork}"))
    	result << URI.extract(get_search_result, ['http']).uniq
	end
	
	ret = parse_result(result,domain)
	
	return ret

end	


# Configuração de proxy
use_proxy = false
proxy_addr = '127.0.0.1'
proxy_port = 8080

# Parametros de busca no Google
google_host = "http://www.google.com.br"


# HTTP interface

http = build_http_request(google_host,use_proxy,proxy_addr,proxy_port)

vulns =  run(http,ARGV[0],ARGV[1])


puts vulns
