require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'

class CopyArtifactsPipeline
  def self.work(artifactsDirectory)
    dependenciesDirectory = Constants::DEPENDENCIES_DIR_PATH
    puts "Cleaning up dependencies directory".colorize(:blue)
    puts "#{dependenciesDirectory}"
    CleanupDependenciesDirectoryWorker.new(dependenciesDirectory).work

    puts "Moving files from  #{artifactsDirectory} to #{dependenciesDirectory}"
    lib = File.join(artifactsDirectory, "Lib.xcframework")
    FileUtils.cp_r(lib, dependenciesDirectory)
    protobuf = File.join(artifactsDirectory, Constants::PROTOBUF_DIRECTORY_NAME)
    FileUtils.cp_r(protobuf, dependenciesDirectory)    
    remove_gitignore(dependenciesDirectory)
  end

  # Remove when fixed on the middlewere side
  private_class_method def self.remove_gitignore(dependenciesDirectory)
    gitignore_path = "#{dependenciesDirectory}/#{Constants::PROTOBUF_DIRECTORY_NAME}/.gitignore"
    if File.file?(gitignore_path)
      FileUtils.rm(gitignore_path)
    end
  end
end