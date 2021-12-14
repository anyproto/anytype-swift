require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'
require_relative 'download_middleware'

class BasePipeline
  def self.work(version, options)
    temporaryDirectory = DownloadMiddlewarePipeline.work(version, options)

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