require_relative '../library/shell_executor'

class DownloadFileAtURLWorker
  attr_accessor :token, :url, :filePath
  def initialize(token, url, filePath)
    self.token = token
    self.url = url
    self.filePath = filePath
  end

  def work
    headers = {}
    headers["Accept"] = "application/octet-stream"
    headersString = headers.map{|k, v| "-H '#{k}: #{v}'"}.join(' ')
    action = "curl -L -o #{filePath} #{headersString} #{url}"

    ShellExecutor.run_command_line action
  end
end