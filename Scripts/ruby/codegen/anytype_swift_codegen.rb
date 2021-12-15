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
    options[:transform] = transform
    options[:filePath] = path

    options = CodegenDefaultOptionsGenerator.populate(options)

    ApplyTransformsPipeline.start(options)
  end
end
