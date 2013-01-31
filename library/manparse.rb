class ManParser

  attr_accessor :bin, :man, :opts

  def initialize(bin)
    (bin.match(%r{\/(\w+)$}) ? @bin = $1 : @bin = bin)
    @man = nil
    @buff = nil
    @opts = []
    rescue Exception
  end


  def getMan()
    manPath = "/usr/share/man/"

#    1      User Commands
#    2      System Calls
#    3      C Library Functions
#    4      Devices and Special Files
#    5      File Formats and Conventions
#    6      Games et. Al.
#    7      Miscellanea
#    8      System Administration tools and Deamons

    sections = [1,8,2,3,4,5,6,7]
    sections.each do |s|
      man = "#{manPath}man#{s}/#{@bin}.#{s}.gz"
      if (File.file?(man))
        @man = man
        return true
      else
        return false
      end
    end
  rescue Exception
  end
  
  def inflate()
    zstream  = Zlib::GzipReader.new(File.open(@man))
    buf = zstream.read
    zstream.close
    return buf
  end

=begin
 def getBinName(man)
    man.match(%r{^.B\s(.+)$}i).captures
    p = $1 unless $1.nil?
    return p
  end
=end

  def getOpts()
    @buff = inflate()
    @buff.scan(%r{(\-?\\-[\w\d]+)}).each do |l|
      @opts << l.to_s.gsub!('\\','')
     end
  end

end
