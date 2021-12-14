require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'

require_relative 'download_middleware'

class BasePipeline
  def self.work(artifactsDirectory)
    dependenciesDirectory = Constants::DEPENDENCIES_DIR_PATH
    puts "Cleaning up dependencies directory #{dependenciesDirectory}"
    CleanupDependenciesDirectoryWorker.new(dependenciesDirectory).work

    puts "Moving files from  #{artifactsDirectory} to #{dependenciesDirectory}"
    lib = File.join(artifactsDirectory, "Lib.xcframework")
    FileUtils.cp_r(lib, dependenciesDirectory)
    protobuf = File.join(artifactsDirectory, Constants::PROTOBUF_DIRECTORY_NAME)
    FileUtils.cp_r(protobuf, dependenciesDirectory)    
    
    puts "Copying protobuf files from Dependencies to ProtobufMessages"
    directory = File.join([dependenciesDirectory, Constants::PROTOBUF_DIRECTORY_NAME])
    FileUtils.cp_r(directory, Constants::PROTOBUF_MESSAGES_DIR)

    puts "Generating swift from protobuf"
    codegen_runner = File.expand_path("#{__dir__}../codegen/anytype_swift_codegen_runner.rb")
    "ruby #{codegen_runner}"
  end
end