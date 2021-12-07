require_relative '../pipeline_starter'

class ToolVersionPipeline < BasePipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      AnytypeSwiftCodegen::TravelerWorker.new(options[:toolPath]).work
    end
    say "Look at current version!"
    puts AnytypeSwiftCodegen::ToolVersionWorker.new(options[:toolPath]).work
  end
end

class ToolHelpPipeline < BasePipeline
  def self.start(options)
    say "Look at help meesage from tool!"
    puts AnytypeSwiftCodegen::ToolHelpWorker.new(options[:toolPath]).work
  end
end

class ListTransformsPipeline < BasePipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      AnytypeSwiftCodegen::TravelerWorker.new(options[:toolPath]).work
    end
    say "Look at available trasnforms!"
    puts AnytypeSwiftCodegen::ListTransformsWorker.new(options[:toolPath]).work
  end
end

class ApplyTransformsPipeline < BasePipeline
  def self.start(options)
    if Dir.exists? options[:toolPath]
      AnytypeSwiftCodegen::TravelerWorker.new(options[:toolPath]).work
    end

    extracted_options_keys = [:filePath, :transform, :outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath, :serviceFilePath]

    sliced_options = {}
    extracted_options_keys.each {|k|
      value = options[k]
      unless value.nil?
        sliced_options[k] = value
      end
    }

    say "You want to generate something?"
    puts "sliced_options are: #{sliced_options}"
    say "Lets go!"

    AnytypeSwiftCodegen::ApplyTransformsWorker.new(options[:toolPath], sliced_options).work
    say "Congratulations! You have just generated new protobuf files!"
  end
end

class CompoundPipeline < BasePipeline
  def self.start(options)
    case options[:command]
    when ToolVersionCommand then ToolVersionPipeline.start(options)
    when ToolHelpCommand then ToolHelpPipeline.start(options)
    when ListTransformsCommand then ListTransformsPipeline.start(options)
    when ApplyTransformsCommand then ApplyTransformsPipeline.start(options)
    else
      say "I don't recognize this command: #{options[:command]}"
      finalize
      return
    end
    finalize
  end
end

module AnytypeSwiftCodegenPipeline
  def self.start(options)
    CompoundPipeline.start(options)
  end
end