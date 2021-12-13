require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'

class BasePipeline
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

    puts "Library unarchived to directory #{temporaryDirectory}"

    ourDirectory = Constants::DEPENDENCIES_DIR_PATH
    puts "Cleaning up dependencies directory #{ourDirectory}"
    CleanupDependenciesDirectoryWorker.new(ourDirectory).work

    puts "Moving files from  #{temporaryDirectory} to #{ourDirectory}"
    CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker.new(temporaryDirectory, ourDirectory).work

    puts "Cleaning up Downloaded files"
    FileUtils.remove_entry downloadFilePath
    FileUtils.remove_entry temporaryDirectory
    
    puts "Moving protobuf files from Dependencies to our project directory"
    CopyProtobufFilesWorker.new(ourDirectory).work

    puts "Generate services from protobuf files"
    codegen_runner = File.expand_path("#{__dir__}../codegen/anytype_swift_codegen_runner.rb")
    "ruby #{codegen_runner}"
  end
end