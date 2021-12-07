class GetRemoteAvailableVersionsWorker < AlwaysValidWorker
  attr_accessor :json_list
  def initialize(json_list)
    self.json_list = json_list
  end
  def perform_work
    json_list.map{|v| v["tag_name"]}
  end
end