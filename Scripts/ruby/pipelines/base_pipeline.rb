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
    CopyLibraryArtifactsWorker.new(artifactsDirectory, dependenciesDirectory).work
    
    puts "Copying protobuf files from Dependencies to ProtobufMessages"
    CopyProtobufFilesWorker.new(dependenciesDirectory).work

    puts "Generating swift from protobuf"
    codegen_runner = File.expand_path("#{__dir__}../codegen/anytype_swift_codegen_runner.rb")
    "ruby #{codegen_runner}"
  end
end