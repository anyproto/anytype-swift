require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'

class DownloadMiddlewarePipeline
  def self.work(version, options)
    puts "Fetching data"
    information = GetRemoteInformationWorker.new(options[:token]).work
    assetURL = GetRemoteAssetURLWorker.new(information, version).work
    puts "Archive URL is: #{assetURL}"

    downloadFilePath = Constants::DOWNLOAD_FILE_PATH
    DownloadFileAtURLWorker.new(options[:token], assetURL, downloadFilePath).work
    puts "Library is downloaded at #{downloadFilePath}"

    temporaryDirectory = Dir.mktmpdir
    unarchiveAction = "tar -zxf #{downloadFilePath} -C #{temporaryDirectory}"
    ShellExecutor.run_command_line unarchiveAction
    FileUtils.remove_entry downloadFilePath

    puts "Library unarchived to directory #{temporaryDirectory}"
    return temporaryDirectory
  end
end