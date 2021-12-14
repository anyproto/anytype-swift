class CodegenOptionsParser
  def self.parse_options(arguments)
    # we could also add names for commands to separate them.
    # thus, we could add 'generate init' and 'generate services'
    # add dispatch for first words.
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on('-l', '--list_transforms', 'List available transforms') {|v| options[:command] = ListTransformsCommand.new}
      opts.on('-t', '--transform TRANSFORM', 'Which transform we would like to apply') {|v| options[:command] = ApplyTransformsCommand.new(v)}

      # # file options
      opts.on('-f', '--filePath PATH', 'Input file with generated swift protobuf models') {|v| options[:filePath] = v}
    end.parse!(arguments)
    CodegenDefaultOptionsGenerator.populate(arguments, options)
  end
end