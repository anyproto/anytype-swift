require 'optparse'

require_relative 'options_generator'
require_relative '../library/environment'

class OptionsParser
  def self.parse_options(arguments)
    options = {}
    OptionParser.new do |opts|
      opts.on('-v', '--version', 'Version of tool') {|v| options[:version] = v}

      # help
      opts.on('-h', '--help', 'Help option') { help_message(opts); exit(0)}

      # commands
      opts.on('--install', '--install', 'Install version from library lock file if it is exists.') {|v| options[:command] = Commands::InstallCommand.new}
      opts.on('--update', '--update [VERSION]', 'Fetch new version from remote and write it to lock file.') {|v| options[:command] = Commands::UpdateCommand.new(v)}

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

  private_class_method def self.help_message(options)
    puts <<-__HELP__

    #{options.help}


    First, it takes arguments:
    --update <- Update middleware to latest available release.
    [--install] default option. <- Installs middleware library from library file.

    Other options you can inspect via
    ruby #{$0} --help

    ---------------
    Usage:
    ---------------
    1. No parameters.
    ruby #{$0}

    2. Parameters
    ruby #{$0} --install # install middleware by gathering version from lockfile.

    3. Update command
    ruby #{$0} --update [Version] # fetch current version from remote.

    This command also can check Libraryfile: Option --libraryFilePath.
    - If file exists, it will read restrictions and find latest approriate version from remote.
    - If file NOT exists, it will fetch latest version from remote.

    ruby #{$0} --update --libraryFilePath ./Libraryfile # Gather restrictions from ./Libraryfile and fetch **appropriate** version from remote.
    ruby #{$0} --update --libraryFilePath ./Abc # Fetch **latest** version from remote

    4. Environment Variables

    #{EnvironmentVariables.variables_description}

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
end