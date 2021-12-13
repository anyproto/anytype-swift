class TravelerWorker
  attr_accessor :path
  def initialize(path)
    self.path = path
  end

  def work
    puts "Path is: #{path}"
    if File.exists?(path) && Dir.exists?(path) 
      Dir.chdir path
    else 
      puts "Path does not exist: #{path}"
      exit 1
    end
  end
end
