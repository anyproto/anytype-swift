class CodegenOptionsParser
  def self.parse_options(arguments)
    options = {}
    OptionParser.new do |opts|
      opts.on('-t', '--transform TRANSFORM', 'Which transform we would like to apply') {|v| options[:command] = ApplyTransformsCommand.new(v)}

      opts.on('-f', '--filePath PATH', 'Input file with generated swift protobuf models') {|v| options[:filePath] = v}
    end.parse!(arguments)
    CodegenDefaultOptionsGenerator.populate(arguments, options)
  end
end