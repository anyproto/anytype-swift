require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'

require_relative 'download_middleware'

require_relative '../codegen/codegen_runner'
require_relative '../library/dir_helper'

class CodegenPipeline
  def self.work()
    dependenciesDirectory = Constants::DEPENDENCIES_DIR_PATH
    puts "Copying protobuf files from Dependencies to ProtobufMessages".colorize(:blue)
    directory = File.join([dependenciesDirectory, Constants::PROTOBUF_DIRECTORY_NAME])
    DirHelper.allFiles(directory, "swift").each { |file|
      FileUtils.cp(file, Constants::PROTOBUF_MESSAGES_DIR)
    }

    puts "Generating swift from protobuf".colorize(:blue)
    CodegenRunner.run()
  end
end