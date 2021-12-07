class DownloadFileAtURLWorker < Workers::BaseWorker
  attr_accessor :token, :url, :filePath
  def initialize(token, url, filePath)
    self.token = token
    self.url = url
    self.filePath = filePath
  end
  def tool
    "curl"
  end
  def action
    headers = {}
    headers["Authorization"] = "token #{token}"
    headers["Accept"] = "application/octet-stream"
    headersString = headers.map{|k, v| "-H '#{k}: #{v}'"}.join(' ')
    "#{tool} -L -o #{filePath} #{headersString} #{url}"
  end
end