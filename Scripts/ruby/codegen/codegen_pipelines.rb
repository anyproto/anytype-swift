require_relative '../library/shell_executor'
require_relative 'codegen_config'


class ApplyTransformsPipeline
  def self.start(options)
    args = ""
    extract_codegen_options(options).each {|key, value|
      args += " --#{key.to_s} #{value}"
    }
    
    action = "#{CodegenConfig::CodegenPath} generate #{args}"
    ShellExecutor.run_command_line action
  end

  private_class_method def self.extract_codegen_options(options)
    extracted_options = [
      :filePath,
      :transform,
      :outputFilePath,
      :templateFilePath,
      :commentsHeaderFilePath,
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
end