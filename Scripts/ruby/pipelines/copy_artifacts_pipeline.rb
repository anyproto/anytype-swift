require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'
require_relative '../library/dir_helper'

class CopyArtifactsPipeline
  def self.work(artifactsDirectory)
    dependenciesDirectory = Constants::DEPENDENCIES_DIR_PATH
    puts "Cleaning up dependencies directory".colorize(:blue)
    puts "#{dependenciesDirectory}"
    CleanupDependenciesDirectoryWorker.new(dependenciesDirectory).work
    FileUtils.mkdir_p(dependenciesDirectory)

    puts "Moving files from  #{artifactsDirectory} to #{dependenciesDirectory}"
    content = File.join(artifactsDirectory, ".")
    FileUtils.cp_r(content, dependenciesDirectory)
    remove_gitignore(dependenciesDirectory)

    FileUtils.rm_rf(Constants::PROTOBUF_MESSAGES_DIR)
    FileUtils.mkdir_p(Constants::PROTOBUF_MESSAGES_DIR)
    puts "Copying protobuf files from Dependencies to ProtobufMessages".colorize(:blue)
    directory = File.join([dependenciesDirectory, Constants::PROTOBUF_DIRECTORY_NAME])
    DirHelper.allFiles(directory, "swift").each { |file|
      FileUtils.cp(file, Constants::PROTOBUF_MESSAGES_DIR)
    }
  end

  # Remove when fixed on the middlewere side
  private_class_method def self.remove_gitignore(dependenciesDirectory)
    gitignore_path = "#{dependenciesDirectory}/#{Constants::PROTOBUF_DIRECTORY_NAME}/.gitignore"
    if File.file?(gitignore_path)
      FileUtils.rm(gitignore_path)
    end
  end
end