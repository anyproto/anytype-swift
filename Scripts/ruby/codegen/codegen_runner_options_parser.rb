class CodegenRunnerOptionsParser
  def self.help_message(options)
    puts <<-__HELP__

    #{options.help}

    This script will help you generate pb.swift convenient interfaces and services.

    It generates the following setup: #{JSON.pretty_generate(CodegenConfig.make_all)}

    DefaultConfiguration: #{JSON.pretty_generate(CodegenRunnerDefaultOptionsGenerator.defaultOptions)}

    __HELP__
  end

  def self.parse_options(arguments)
    OptionParser.new do |opts|
      opts.on('-h', '--help', 'Help') { self.help_message(opts); exit(0)}
    end.parse!(arguments)

    return CodegenRunnerDefaultOptionsGenerator.populate(arguments, {})
  end
end
