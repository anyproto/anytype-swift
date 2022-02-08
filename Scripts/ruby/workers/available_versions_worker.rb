class GetRemoteAvailableVersionsWorker
  attr_accessor :json_list
  def initialize(json_list)
    self.json_list = json_list
  end

  def work
    json_list.map{|v| v["tag_name"]}
  end
end