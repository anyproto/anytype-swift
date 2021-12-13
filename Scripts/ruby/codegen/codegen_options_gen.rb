# OutputFilePath <- f (filePath, transform)
# CommentsHeaderFilePath <- f (filePath)
# ImportsFilePath <- f (filePath, transform)
# TemplateFilePath <- f(filePath, transform) # only for specific transforms.


class CodegenDefaultOptionsGenerator
  def self.defaultOptions
    options = {
      # commands
      command: "None",
      # tools
      toolPath: "#{__dir__}/../Tools/anytype-swift-codegen",
      # templates
      templatesDirectoryPath: "#{__dir__}/../Templates/Middleware",
      # comments header
      commentsHeaderFilePath: "#{__dir__}/../Templates/Middleware/commands+HeaderComments.pb.swift",
      # service file path
      serviceFilePath: "#{__dir__}/../Dependencies/Middleware/protobuf/protos/service.proto",
    }
  end

  def self.available_transforms
    ApplyTransformsCommand.available_transforms
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

  def self.generateFilePaths(options)
    if options[:command].is_a? ApplyTransformsCommand
      command = options[:command]
      unless command.tool_transform.nil?
        our_transform = command.our_transform
        tool_transform = command.tool_transform
        result = {
          transform: tool_transform,
          filePath: options[:filePath],
        }
        keys = [:outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath]
        for k in keys
          directoryPath = k == :outputFilePath ? Pathname.new(options[:filePath]).dirname.to_s : options[:templatesDirectoryPath]
          value = self.appended_suffix(command.suffix_for_file(k), options[:filePath], directoryPath)
          unless value.nil?
            result[k] = value
          end
        end
        result
      end
    end
  end

  def self.filePathOptions
    [
      :toolPath,
      :filePath,
      :outputFilePath,
      :templateFilePath,
      :commentsHeaderFilePath,
      :importsFilePath,
      :serviceFilePath
    ]
  end

  def self.fixOptions(options)
    result_options = options
    filePathOptions.each do |v|
      unless result_options[v].nil?
        result_options[v] = File.expand_path(result_options[v])
      end
    end
    result_options
  end

  def self.generate(arguments, options)
    result = defaultOptions.merge options
    result = generateFilePaths(result).merge result
    fixOptions(result)
  end
  
  def self.populate(arguments, options)
    new_options = self.generate(arguments, options)
    new_options = new_options.merge(options)
    fixOptions(new_options)
  end
end
