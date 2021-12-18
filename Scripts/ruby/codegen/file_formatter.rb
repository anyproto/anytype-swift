require_relative 'codegen_config'

require_relative '../library/shell_executor'
require_relative '../library/dir_helper'

class FileFormatter
  def self.formatFiles()
    DirHelper.allFiles(CodegenConfig::ProtobufDirectory, "swift")
      .each { |path|
        puts "Running swift format for file #{path}"
        action = "#{CodegenConfig::SwiftFormatPath} -i --configuration #{CodegenConfig::SwiftFormatConfigPath} #{path}"
        ShellExecutor.run_command_line_silent action
     }
  end
end