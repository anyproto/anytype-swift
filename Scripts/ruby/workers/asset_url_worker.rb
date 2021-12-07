require_relative 'core/valid_worker'

class GetRemoteAssetURLWorker < AlwaysValidWorker
  attr_accessor :json_list, :version, :prefix
  def initialize(json_list, version, prefix)
    self.json_list = json_list
    self.version = version
    self.prefix = prefix
  end
  def perform_work
    entry = json_list.find {|v| v["tag_name"] == version}
    assets = entry["assets"]
    asset = assets.find{|v| v["name"] =~ %r"#{prefix}"}
    asset["url"]
  end
end