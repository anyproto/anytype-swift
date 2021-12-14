class CodegenRunnerDefaultOptionsGenerator
  class << self
    def defaultOptions
      {
        # command
        command: CodegenListCommand.new(Matrix::Configuration.make_all.map(&:options)),
        # tool
        toolPath: "#{__dir__}/anytype_swift_codegen.rb",
        # output directory
        outputDirectory: Matrix::Configuration.protobufDirectory,
        # format tool
        formatToolPath: "#{__dir__}/swift_format.rb"
      }
    end

    def filePathOptions
      [:toolPath, :outputDirectory, :formatToolPath]
    end

    def fixOptions(options)
      result_options = options
      filePathOptions.each do |v|
        unless result_options[v].nil?
          result_options[v] = File.expand_path(result_options[v])
        end
      end
      result_options
    end

    def generate(arguments, options)
      result_options = defaultOptions.merge options
      fixOptions(result_options)
    end

    def populate(arguments, options)
      new_options = self.generate(arguments, options)
      new_options = new_options.merge(options)
      fixOptions(new_options)
    end
  end
end