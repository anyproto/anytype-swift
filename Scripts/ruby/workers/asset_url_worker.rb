require_relative '../constants'

class GetRemoteAssetURLWorker
  attr_accessor :json_list, :version

  def initialize(json_list, version)
    self.json_list = json_list
    self.version = version
  end

  def work
    entry = json_list.find {|v| v["tag_name"] == version}
    assets = entry["assets"]
    asset = assets.find{|v| v["name"] =~ %r"ios_framework_"}
    asset["url"]
  end
end