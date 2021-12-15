require_relative 'codegen_workers_2'

class ListTransformsPipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      TravelerWorker.new(options[:toolPath]).work
    end
    puts "Look at available trasnforms!"
    puts ListTransformsWorker.new(options[:toolPath]).work
  end
end

class ApplyTransformsPipeline
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

class CompoundPipeline
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

class CodegenPipeline
  def self.start(toolPath, transform, filePath)
    if Dir.exists? toolPath
      TravelerWorker.new(toolPath).work
    end
    CodegenWorker.new(toolPath, transform, filePath).work
  end
end

class FormatDirectoryPipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      TravelerWorker.new(options[:toolPath]).work
    end
    directory = options[:outputDirectory]
    Dir.entries(directory).map{ |f|
      File.join(directory, f)
    }
    .select{ |f|
      File.file?(f) && File.extname(f) == '.swift'
    }.each{ |f|
      FormatWorker.new(options[:formatToolPath], f).work
    }
  end
end