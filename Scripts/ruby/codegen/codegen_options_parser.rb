class CodegenOptionsParser
  def self.help_message(options)
    puts <<-__HELP__

    #{options.help}

    This script will help you generate pb.swift convenient interfaces and services.

    First, it takes arguments:
    [required] <--filePath PATH> Path to a file which will be used to generate desired services and interfaces.
    Other options you can inspect via
    ruby #{$0} --help

    ---------------
    Usage:
    ---------------
    # or if you want Siri Voice, set environment variable SIRI_VOICE=1
    SIRI_VOICE=1 ruby #{$0} <parameters>

    DefaultConfiguration: #{JSON.pretty_generate(CodegenDefaultOptionsGenerator.defaultOptions)}

    1. Parameters
    ruby #{$0} --transform inits --filePath <PATH> [other parameters].

    Available actions e.g. transforms: [#{CodegenDefaultOptionsGenerator.available_transforms}]


    __HELP__
  end

  def self.parse_options(arguments)
    # we could also add names for commands to separate them.
    # thus, we could add 'generate init' and 'generate services'
    # add dispatch for first words.
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on('-v', '--version', 'Version of tool') {|v| options[:command] = ToolVersionCommand.new}
      opts.on('--toolHelp', '--toolHelp', 'Print tool help message') {|v| options[:command] = ToolHelpCommand.new}
      opts.on('-l', '--list_transforms', 'List available transforms') {|v| options[:command] = ListTransformsCommand.new}
      opts.on('-t', '--transform TRANSFORM', 'Which transform we would like to apply') {|v| options[:command] = ApplyTransformsCommand.new(v)}

      # # tool option
      opts.on('--cli', '--toolPath PATH', 'Path to directory with anytype-swift-codegen') {|v| options[:toolPath] = v}

      # # file options
      opts.on('-f', '--filePath PATH', 'Input file with generated swift protobuf models') {|v| options[:filePath] = v}
      opts.on('--outputFilePath', '--outputFilePath PATH', 'Output to file') {|v| options[:outputFilePath] = v}
      opts.on('--templateFilePath', '--templateFilePath PATH', 'File with templates which are used in some transforms'){|v| options[:templateFilePath] = v}
      opts.on('--commentsHeaderFilePath', '--commentsHeaderFilePath PATH', 'Header at the top of file'){|v| options[:commentsHeaderFilePath] = v}
      opts.on('--importsFilePath', '--importsFilePath PATH', 'Import statements at the top of file'){|v| options[:importsFilePath] = v}

      opts.on('--templatesDirectoryPath', '--templatesDirectoryPath PATH', 'Templates directory path'){|v| options[:templatesDirectoryPath] = v}
      opts.on('--serviceFilePath', '--serviceFilePath PATH', 'Rpc service file that contains Rpc services descriptions in .proto (protobuffers) format.') {|v| options[:serviceFilePath] = v}

      opts.on('-d', '--dry_run', 'Dry run to see all options') {|v| options[:dry_run] = v}
      # help
      opts.on('-h', '--help', 'Help option') { self.help_message(opts); exit(0)}
    end.parse!(arguments)
    CodegenDefaultOptionsGenerator.populate(arguments, options)
  end
end