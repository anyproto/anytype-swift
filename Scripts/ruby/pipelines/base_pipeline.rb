require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'

require_relative 'download_middleware'

require_relative '../codegen/codegen_runner'
require_relative '../codegen/file_formatter'

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
    remove_gitignore(dependenciesDirectory)
    
    puts "Copying protobuf files from Dependencies to ProtobufMessages"
    directory = File.join([dependenciesDirectory, Constants::PROTOBUF_DIRECTORY_NAME])
    DirHelper.allFiles(directory, "swift").each { |file|
      FileUtils.cp(file, Constants::PROTOBUF_MESSAGES_DIR)
    }

    puts "Generating swift from protobuf"
    CodegenRunner.run()

    puts "Running swift format"
    FileFormatter.formatFiles()
  end

  # Remove when fixed on the middlewere side
  private_class_method def self.remove_gitignore(dependenciesDirectory)
    gitignore_path = "#{dependenciesDirectory}/#{Constants::PROTOBUF_DIRECTORY_NAME}/.gitignore"
    if File.file?(gitignore_path)
      FileUtils.rm(gitignore_path)
    end
  end
end