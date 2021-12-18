require 'pathname'

require_relative 'codegen_config'

class CodegenDefaultOptionsGenerator
  def self.defaultOptions
    options = {
      commentsHeaderFilePath: File.expand_path("#{__dir__}/../../../Templates/Middleware/commands+HeaderComments.pb.swift"),
      serviceFilePath: File.expand_path("#{__dir__}/../../../Dependencies/Middleware/protobuf/protos/service.proto"),
    }
  end

  def self.appended_suffix(suffix, inputFilePath, directoryPath)
    unless inputFilePath.nil?
      unless suffix.nil?
        pathname = Pathname.new(inputFilePath)
        basename = pathname.basename
        components = basename.to_s.split(".")
        the_name = components.first
        the_extname = components.drop(1).join(".")
        result_name = directoryPath + "/" + the_name + suffix + ".#{the_extname}"

        result_name
      end
    end
  end

  private_class_method def self.generateFilePaths(transform, filePath)
    result = {
      filePath: filePath,
    }

    paths = [:outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath]
    
    for path in paths
      if path == :outputFilePath
        directoryPath = Pathname.new(filePath).dirname.to_s
      else 
        directoryPath = CodegenConfig::CodegenTemplatesPath
      end


      suffix = suffix(transform, path)
      result[path] = appended_suffix(suffix, filePath, directoryPath)
    end

    result
  end

  def self.suffix(transform, key)
    case transform
      when "memberwiseInitializer" then
        case key
          when :outputFilePath then "+Initializers"
          when :templateFilePath then nil #"+Initializers+Template"
          when :commentsHeaderFilePath then "+CommentsHeader"
          when :importsFilePath then "+Initializers+Import"
        end
      when "serviceWithRequestAndResponse" then
        case key
          when :outputFilePath then "+Service"
          when :templateFilePath then "+Service+Template"
          when :commentsHeaderFilePath then "+CommentsHeader"
          when :importsFilePath then "+Service+Import"
        end
      when "errorAdoption" then
        case key
          when :outputFilePath then "+ErrorAdoption"
          when :templateFilePath then nil
          when :commentsHeaderFilePath then "+CommentsHeader"
          when :importsFilePath then nil
        end
    end
  end

  def self.generate(options)
    result = defaultOptions.merge options
    result = generateFilePaths(result[:transform], result[:filePath]).merge result
    result
  end
  
  def self.populate(options)
    new_options = generate(options)
    new_options = new_options.merge(options)
    new_options
  end
end
