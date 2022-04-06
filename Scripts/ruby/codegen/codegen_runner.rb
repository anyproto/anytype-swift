require_relative '../library/shell_executor'
require_relative 'codegen_config'
require_relative 'codegen_options_gen'


class CodegenRunner
  def self.run()
    codegenOptions().each { |options|
      options = CodegenDefaultOptionsGenerator.populate(options)
      puts "Running codegen #{options[:transform]} for file: #{options[:filePath]}"
      start(options)
    }
  end


  def self.start(options)
    args = ""
    extract_codegen_options(options).each {|key, value|
      args += " --#{key.to_s} #{value}"
    }
    
    action = "#{CodegenConfig::CodegenPath} generate #{args}"
    ShellExecutor.run_command_line_silent action
  end

  private_class_method def self.extract_codegen_options(options)
    extracted_options = [
      :filePath,
      :transform,
      :outputFilePath,
      :templateFilePath,
      :importsFilePath,
      :serviceFilePath
    ]

    sliced_options = {}
    extracted_options.each {|key|
      unless options[key].nil?
        sliced_options[key] = options[key]
      end
    }

    return sliced_options
  end

  # names of transforms stored in https://github.com/anytypeio/anytype-swift-codegen
  private_class_method def self.codegenOptions()
    [
      { transform: "memberwiseInitializer", filePath: CodegenConfig::ModelsFilePath }, 
      { transform: "memberwiseInitializer", filePath: CodegenConfig::EventsFilePath },
      { transform: "memberwiseInitializer", filePath: CodegenConfig::LocalstoreFilePath },

      { transform: "memberwiseInitializer", filePath: CodegenConfig::CommandsFilePath },
      { transform: "errorAdoption", filePath: CodegenConfig::CommandsFilePath }, 
      { transform: "serviceWithRequestAndResponse", filePath: CodegenConfig::CommandsFilePath }
    ]
  end
end