require 'optparse'

require_relative 'library/environment'
require_relative 'commands'

class Options
  def self.parsed(args)
    default_options.merge options_from_args(args)
  end

  private_class_method def self.options_from_args(args)
    options = {}

    OptionParser.new do |opts|
      opts.on('-h', '--help', 'Show help') { help_message(opts); exit(0)}

      opts.on('-i', '--install', '--install', 'Install version from library file') {|v| options[:command] = InstallCommand.new}
      opts.on('-u', '--update', '--update [VERSION]', 'Update middleware to latest or provided version') {|v| options[:command] = UpdateCommand.new(v)}

      opts.on('--token', '--token [TOKEN]', 'Token to access repository. It is private option.') {|v| options[:token] = v}
      opts.on('--on-ci', 'Run on CI') { |v| options[:runsOnCI] = true }

    end.parse!(args)

    return options
  end

  private_class_method def self.default_options
    {
      command: InstallCommand.new,
      runsOnCI: false,
      token: EnvironmentVariables.token || '',
    }
  end

  private_class_method def self.help_message(options)
    puts <<-__HELP__

    #{options.help}

    Suported environment variables:
    #{EnvironmentVariables.variables_description}

    __HELP__
  end
end