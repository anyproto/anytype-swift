require 'optparse'

require_relative 'default_options'
require_relative '../library/environment'

class OptionsParser
  def self.parse_options(arguments)
    options = {}
    OptionParser.new do |opts|
      opts.on('-h', '--help', 'Show help') { help_message(opts); exit(0)}

      opts.on('-i', '--install', '--install', 'Install version from library file') {|v| options[:command] = Commands::InstallCommand.new}
      opts.on('-u', '--update', '--update [VERSION]', 'Update middleware to latest or provided version') {|v| options[:command] = Commands::UpdateCommand.new(v)}

      opts.on('--token', '--token [ENTRY]', 'Token to access repository. It is private option.') {|v| options[:token] = v}
      opts.on('--on-ci', 'Run on CI') { |v| options[:runsOnCI] = true }

    end.parse!(arguments)
    DefaultOptions.options.merge options
  end

  private_class_method def self.help_message(options)
    puts <<-__HELP__

    #{options.help}

    Suported environment variables:
    #{EnvironmentVariables.variables_description}

    __HELP__
  end
end