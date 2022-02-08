class GetRemoteVersionWorker
  attr_accessor :json_list
  def initialize(json_list)
    self.json_list = json_list
  end

  def work
    entry = json_list.first
    version = entry["tag_name"]
    if version.empty?
      puts "I can't find version at remote!"
      exit(1)
    end
    version
  end
end