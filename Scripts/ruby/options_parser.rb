require 'optparse'
require 'shellwords'
require 'pathname'

require 'tmpdir'

require 'net/http'

require 'yaml'
require 'json'

require_relative 'middleware_updater'

class OptionsParser
  class DefaultOptionsGenerator
    class << self
      def defaultOptions
        options = {
          # commands
          command: MiddlewareUpdater::Configuration::Commands::InstallCommand.new,

          # library file options
          libraryFilePath: "#{__dir__}/../Libraryfile",
          librarylockFilePath: "#{__dir__}/../Libraryfile.lock",
          librarylockFileVersionKey: "middleware.version",

          # repository options
          token: MiddlewareUpdater::Configuration::EnvironmentVariables.token || '',
          repositoryURL: "https://api.github.com/repos/anytypeio/go-anytype-middleware/releases",

          # download file options
          downloadFilePath: "#{__dir__}/../lib.tar.gz",
          iOSAssetMiddlewarePrefix: "ios_framework_",

          # download archive structure options
          middlewareLibraryName: "Lib.xcframework",
          protobufDirectoryName: "protobuf",

          # target directory options
          dependenciesDirectoryPath: "#{__dir__}/../Dependencies/Middleware",
          targetDirectoryPath: "#{__dir__}/../Modules/ProtobufMessages/Sources/",
          swiftAutocodegenScript: "#{__dir__}/../Scripts/anytype_swift_codegen_runner.rb"
        }
      end

      def filePathOptions
        [
          :libraryFilePath,
          :librarylockFilePath,
          :downloadFilePath,
          :dependenciesDirectoryPath,
          :targetDirectoryPath,
          :swiftAutocodegenScript
        ]
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

  def help_message(options)
    puts <<-__HELP__

    #{options.help}

    This script will help you update middleware library.



    First, it takes arguments:
    --update option. <- You should specify this option if you would like to update middleware to latest available release.
    [--install] default option. <- You should specify or not ( default option ) if you would like to install middleware library from library file.

    Other options you can inspect via
    ruby #{$0} --help

    ---------------
    Usage:
    ---------------
    1. No parameters.
    ruby #{$0}

    # or if you want Siri Voice, set environment variable SIRI_VOICE=1
    SIRI_VOICE=1 ruby #{$0}

    Run without parameters will active default configuration and script will install middleware from a lockfile.

    DefaultConfiguration: #{JSON.pretty_generate(DefaultOptionsGenerator.defaultOptions)}

    2. Parameters
    ruby #{$0} --install # install middleware by gathering version from lockfile.
    ruby #{$0} --list # list available versions from remote.
    ruby #{$0} --current_version # print current version in lockfile.

    3. Update command
    ruby #{$0} --update [Version] # fetch current version from remote.

    This command also can check Libraryfile: Option --libraryFilePath.
    - If file exists, it will read restrictions and find latest approriate version from remote.
    - If file NOT exists, it will fetch latest version from remote.

    ruby #{$0} --update --libraryFilePath ./Libraryfile # Gather restrictions from ./Libraryfile and fetch **appropriate** version from remote.
    ruby #{$0} --update --libraryFilePath ./Abc # Fetch **latest** version from remote

    4. Environment Variables
    You could pass several arguments by environment.

    ENV_VARIABLE="VALUE" ruby #{$0} --list

    Available variables are

    #{MiddlewareUpdater::Configuration::EnvironmentVariables.variables_description}

    5. Set Environment Variables

    For different shells it would different, but the scheme would be:

    1. Open shell terminal rc file.
    2. Append `export ENV_VAR="VALUE"`
    3. Save file.
    Either
    4. Open new terminal window
    Or
    4. Execute `source terminal_rc_file`

    For a zsh shell it would be:

    1. Open ~/.zshrc
    2. Append `export ENV_VAR="VALUE"`
    3. Save file.
    Either
    4. Open new terminal window
    Or
    4. Execute `source ~/.zshrc`
    __HELP__
  end

  def parse_options(arguments)
    # we could also add names for commands to separate them.
    # thus, we could add 'generate init' and 'generate services'
    # add dispatch for first words.
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on('-v', '--version', 'Version of tool') {|v| options[:version] = v}

      opts.on('-d', '--dry_run', 'Dry run to see all options') {|v| options[:dry_run] = v}
      opts.on('-i', '--inspection', 'Inspection of all items, like tests'){|v| options[:inspection] = v}
      # help
      opts.on('-h', '--help', 'Help option') { self.help_message(opts); exit(0)}

      # commands
      opts.on('--install', '--install', 'Install version from library lock file if it is exists.') {|v| options[:command] = MiddlewareUpdater::Configuration::Commands::InstallCommand.new}
      opts.on('--update', '--update [VERSION]', 'Fetch new version from remote and write it to lock file.') {|v| options[:command] = MiddlewareUpdater::Configuration::Commands::UpdateCommand.new(v)}
      opts.on('--list', '--list', 'List available versions from remote') {|v| options[:command] = MiddlewareUpdater::Configuration::Commands::ListCommand.new}
      opts.on('--current_version', '--current_version', 'Print current version') {|v| options[:command] = MiddlewareUpdater::Configuration::Commands::CurrentVersionCommand.new}

      # library file options
      opts.on('--libraryFilePath', '--libraryFilePath PATH', 'Path to library file.') {|v| options[:libraryFilePath] = v}
      opts.on('--librarylockFilePath', '--librarylockFilePath PATH', 'Path to a lock file.') {|v| options[:librarylockFilePath] = v}
      opts.on('--librarylockFileVersionKey', '--librarylockFileVersionKey KEY', 'Key in a lock file that point to a version of current library') {|v| options[:librarylockFileVersionKey] = v}

      # repository options
      opts.on('--token', '--token ENTRY', 'Token to access repository. It is private option.') {|v| options[:token] = v}
      opts.on('--repositoryURL', '--repositoryURL URL', 'Repository URL') {|v| options[:repositoryURL] = v}

      # download file options
      opts.on('--downloadFilePath', '--downloadFilePath PATH', 'Path to temporary file which will be downlaoded') {|v| options[:downloadFilePath] = v}
      opts.on('--iOSAssetMiddlewarePrefix', '--iOSAssetMiddlewarePrefix NAME', 'iOS asset middleware prefix') {|v| options[:iOSAssetMiddlewarePrefix] = v}

      # download archive structure options
      opts.on('--middlewareLibraryName', '--middlewareLibraryName NAME', 'iOS Middleware library name') {|v| options[:middlewareLibraryName] = v }
      opts.on('--protobufDirectoryName', '--protobufDirectoryName NAME', 'Directory name which contains protobuf in downloadable directory') {|v| options[:protobufDirectoryName] = v}

      # target directory options
      opts.on('--dependenciesDirectoryPath', '--dependenciesDirectoryPath PATH', 'Path to a dependencies directory') {|v| options[:dependenciesDirectoryPath] = v}
      opts.on('--targetDirectoryPath', '--targetDirectoryPath PATH', 'Path to target directory') {|v| options[:targetDirectoryPath] = v}

      # swift codegen script
      opts.on('--swiftAutocodegenScript', '--swiftAutocodegenScript PATH', 'Path to codegen script') {|v| options[:swiftAutocodegenScript] = v}

    end.parse!(arguments)
    DefaultOptionsGenerator.populate(arguments, options)
  end
end