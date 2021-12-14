require_relative '../pipeline_starter'
require_relative 'codegen_workers_2'
require_relative 'codegen_commands'

class ListTransformsPipeline < BasePipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      TravelerWorker.new(options[:toolPath]).work
    end
    puts "Look at available trasnforms!"
    puts ListTransformsWorker.new(options[:toolPath]).work
  end
end

class ApplyTransformsPipeline < BasePipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      TravelerWorker.new(options[:toolPath]).work
    end

    extracted_options_keys = [:filePath, :transform, :outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath, :serviceFilePath]

    sliced_options = {}
    extracted_options_keys.each {|k|
      value = options[k]
      unless value.nil?
        sliced_options[k] = value
      end
    }

    puts "You want to generate something?"
    puts "sliced_options are: #{sliced_options}"
    puts "Lets go!"

    ApplyTransformsWorker.new(options[:toolPath], sliced_options).work
    puts "Congratulations! You have just generated new protobuf files!"
  end
end

class CompoundPipeline < BasePipeline
  def self.start(options)
    case options[:command]
    when ListTransformsCommand then ListTransformsPipeline.start(options)
    when ApplyTransformsCommand then ApplyTransformsPipeline.start(options)
    else
      puts "I don't recognize this command: #{options[:command]}"
      return
    end
  end
end

module AnytypeSwiftCodegenPipeline
  def self.start(options)
    CompoundPipeline.start(options)
  end
end

class CodegenPipeline < BasePipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      TravelerWorker.new(options[:toolPath]).work
    end
    CodegenWorker.new(options[:toolPath], options[:transform], options[:filePath]).work
  end
end

class FormatDirectoryPipeline < BasePipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      TravelerWorker.new(options[:toolPath]).work
    end
    directory = options[:outputDirectory]
    Dir.entries(directory).map{|f| File.join(directory, f)}.select{|f| File.file?(f) && File.extname(f) == '.swift'}.each{|f|
      FormatWorker.new(options[:formatToolPath], f).work
    }
  end
end

class CompoundPipeline < BasePipeline
  def self.start(options)
    case options[:command]
    when CodegenCommand then CodegenPipeline.start(options)
    when CodegenListCommand then
      options[:command].list.each{ |value|
        CodegenPipeline.start(options.merge value)
      }
      FormatDirectoryPipeline.start(options)
    else
      puts "I don't recognize this command: #{options[:command]}"
      return
    end
  end
end