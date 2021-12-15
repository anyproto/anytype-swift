require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative 'codegen_pipelines'
require_relative 'codegen_options_gen'
require_relative 'codegen_configuration'
 
class Codegen
  def self.run(transform, path)
    options = {}
    options[:command] = ApplyTransformsCommand.new(transform)
    options[:transform] = map_transform(transform)
    options[:filePath] = path

    options = CodegenDefaultOptionsGenerator.populate(options)

    ApplyTransformsPipeline.start(options)
  end

  private_class_method def self.map_transform(transform)
    if transform == "services"
      return "serviceWithRequestAndResponse"
    elsif transform == "inits"
      return "memberwiseInitializer"
    elsif transform == "error_protocol"
      return "errorAdoption"
    end
    
    puts "Unrecognized transform #{transform}"
    exit 1     
  end
end
