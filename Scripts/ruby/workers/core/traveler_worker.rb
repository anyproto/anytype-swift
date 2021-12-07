require_relative 'base_worker'

class TravelerWorker < BaseWorker
  attr_accessor :path
  def initialize(path)
    self.path = path
  end

  def tool
    "Ruby::Dir.chdir"
  end

  def is_valid?
    # check that tool is valid by following.
    # 1. file path exists.
    # 2. it is a directory.
    puts "Path is: #{path}"
    File.exists?(path) && Dir.exists?(path)
  end
  def perform_work
    Dir.chdir path
  end
end
