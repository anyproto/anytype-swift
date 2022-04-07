require_relative '../library/shell_executor'
require_relative 'codegen_config'
require 'pathname'

class CodegenRunner
  def self.run()
    generateErrorAdoption(CodegenConfig::CommandsFilePath)
    generateService(CodegenConfig::CommandsFilePath)

    generateInit(CodegenConfig::ModelsFilePath)
    generateInit(CodegenConfig::EventsFilePath)
    generateInit(CodegenConfig::LocalstoreFilePath)
  end

  private_class_method def self.generateErrorAdoption(filePath)
    dirPath = Pathname.new(filePath).dirname.to_s
    outputFilePath = append_suffix("+ErrorAdoption", filePath, dirPath)
    args = "generateErrorAdoption" +
      " --filePath #{filePath}" +
      " --outputFilePath #{outputFilePath}"
    
    puts "Run generateErrorAdoption for #{filePath}"
    ShellExecutor.run_command_line_silent "#{CodegenConfig::CodegenPath} #{args}"
  end

  private_class_method def self.generateInit(filePath)
    dirPath = Pathname.new(filePath).dirname.to_s
    outputFilePath = append_suffix("+Initializers", filePath, dirPath)
    importsFilePath = append_suffix("+Initializers+Import", filePath, CodegenConfig::CodegenTemplatesPath)

    args = "generateInitializes" +
        " --filePath #{filePath}" +
        " --outputFilePath #{outputFilePath}" +
        " --importsFilePath #{importsFilePath}"
    
    puts "Run generateInitializes for #{filePath}"
    ShellExecutor.run_command_line_silent "#{CodegenConfig::CodegenPath} #{args}"
  end

  private_class_method def self.generateService(filePath)
    dirPath = Pathname.new(filePath).dirname.to_s
    outputFilePath = append_suffix("+Service", filePath, dirPath)
    importsFilePath = append_suffix("+Service+Import", filePath, CodegenConfig::CodegenTemplatesPath)
    templateFilePath = append_suffix("+Service+Template", filePath, CodegenConfig::CodegenTemplatesPath)
    serviceFilePath = File.expand_path("#{__dir__}/../../../Dependencies/Middleware/#{Constants::PROTOBUF_DIRECTORY_NAME}/protos/service.proto")

    args = "generateService" +
      " --filePath #{filePath}" +
      " --outputFilePath #{outputFilePath}" +
      " --importsFilePath #{importsFilePath}" +
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