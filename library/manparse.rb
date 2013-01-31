class ManParser

 #attr_accessor :net, :port
  
  def initialize()
  end

  def searchMan(binary)
    manPath = "/usr/share/man/"
    
    (binary.match(%r{\/(\w+)$}) ? binary = $1 : binary)

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
      man = "#{manPath}man#{s}/#{binary}.#{s}.gz"
      if (File.file?(man))
        return man
      end
    end
  rescue Exception
  end

  def getBinName(man)
    man.match(%r{^.B\s(.+)$}i).captures
    p = $1 unless $1.nil?
    return p
  end 

  def getOpts(man)
    opts = []
    man.scan(%r{(\-?\\-[\w\d]+)}).each do |l|
      opts << l.to_s.gsub!('\\','')
     end
    return opts.uniq.inspect
  end


end
