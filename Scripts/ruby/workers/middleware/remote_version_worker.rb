require_relative '../core/valid_worker'

class GetRemoteVersionWorker < AlwaysValidWorker
  attr_accessor :json_list
  def initialize(json_list)
    self.json_list = json_list
  end
  def perform_work
    entry = json_list.first
    version = entry["tag_name"]
    if version.empty?
      puts "I can't find version at remote!"
      exit(1)
    end
    version
  end
end