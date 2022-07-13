require_relative '../library/shell_executor'
require_relative 'codegen_config'
require 'pathname'

class CodegenRunner
  def self.run()
    generateErrorAdoption(CodegenConfig::CommandsFilePath)
    generateService(CodegenConfig::CommandsFilePath)

    generateInit(CodegenConfig::CommandsFilePath)
    generateInit(CodegenConfig::ModelsFilePath)
    generateInit(CodegenConfig::EventsFilePath)
    generateInit(CodegenConfig::LocalstoreFilePath)
  end

  private_class_method def self.generateErrorAdoption(filePath)
    dirPath = Pathname.new(filePath).dirname.to_s
    outputFilePath = append_suffix("+ErrorAdoption", filePath, dirPath)
    templateFilePath = CodegenConfig::CodegenTemplatesPath + "/" +  "error.stencill"

    args = "generateErrorAdoption" +
      " --filePath #{filePath}" +
      " --outputFilePath #{outputFilePath}" +
      " --templateFilePath #{templateFilePath}"
    
    puts "Run generateErrorAdoption for #{filePath}"
    ShellExecutor.run_command_line_silent "#{CodegenConfig::CodegenPath} #{args}"
  end

  private_class_method def self.generateInit(filePath)
    dirPath = Pathname.new(filePath).dirname.to_s
    outputFilePath = append_suffix("+Initializers", filePath, dirPath)
    templateFilePath = CodegenConfig::CodegenTemplatesPath + "/" +  "initializer.stencill"

    args = "generateInitializes" +
        " --filePath #{filePath}" +
        " --outputFilePath #{outputFilePath}" +
        " --templateFilePath #{templateFilePath}"
    
    puts "Run generateInitializes for #{filePath}"
    ShellExecutor.run_command_line_silent "#{CodegenConfig::CodegenPath} #{args}"
  end

  private_class_method def self.generateService(filePath)
    dirPath = Pathname.new(filePath).dirname.to_s
    outputFilePath = append_suffix("+Service", filePath, dirPath)
    templateFilePath = CodegenConfig::CodegenTemplatesPath + "/" + "service.stencill"
    serviceFilePath = File.expand_path("#{__dir__}/../../../Dependencies/Middleware/#{Constants::PROTOBUF_DIRECTORY_NAME}/protos/service.proto")

    args = "generateService" +
      " --filePath #{filePath}" +
      " --outputFilePath #{outputFilePath}" +
      " --templateFilePath #{templateFilePath}" +
      " --serviceFilePath #{serviceFilePath}"
    
    puts "Run generateService for #{filePath}"
    ShellExecutor.run_command_line_silent "#{CodegenConfig::CodegenPath} #{args}"
  end

  private_class_method def self.append_suffix(suffix, filePath, dirPath)
    pathname = Pathname.new(filePath)
    basename = pathname.basename
    components = basename.to_s.split(".")
    the_name = components.first
    the_extname = components.drop(1).join(".")
    result_name = dirPath + "/" + the_name + suffix + ".#{the_extname}"

    result_name
  end
end
