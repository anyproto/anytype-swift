require 'optparse'
require 'shellwords'
require 'pathname'

require 'tmpdir'

require 'net/http'

require 'yaml'
require 'json'

require_relative 'library/shell_executor'
require_relative 'library/voice'
require_relative 'library/workers'
require_relative 'library/semantic_versioning'

module MiddlewareUpdater
  class BaseWorker < Workers::BasicWorker
    def is_valid?
      true
    end
  end

  # version=`curl -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" -sL https://$GITHUB/repos/$REPO/releases | jq ".[] | select(.tag_name == \"$MIDDLEWARE_VERSION_BY_TAG_NAME\")"`
  class GetRemoteInformationWorker < BaseWorker
    attr_accessor :token, :url
    def initialize(token, url)
      self.token = token
      self.url = url
    end
    def is_valid?
      (self.token || '').empty? == false
    end
    def work
      unless can_run?
        puts <<-__REASON__
        Access token does not exist. 
        Please, provide it by cli argument or environment variable. 
        Run `ruby #{$0} --help`
        __REASON__
        exit(0)
      end
      perform_work
    end
    def perform_work
      # fetch curl -H "Authorization: token Token" -H "Accept: application/vnd.github.v3+json" -sL https://api.github.com/repos/anytypeio/go-anytype-middleware/releases
      uri = URI(url)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "token #{token}"
      request["Accept"] = "application/vnd.github.v3+json"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http|
        http.request(request)
      }
      if Integer(response.code) >= 400
        puts "Code: #{response.code} and response: #{JSON.parse(response.body)}"
        exit(0)
      end
      JSON.parse(response.body)
    end
  end

  class GetRemoteAvailableVersionsWorker < BaseWorker
    attr_accessor :json_list
    def initialize(json_list)
      self.json_list = json_list
    end
    def perform_work
      json_list.map{|v| v["tag_name"]}
    end
  end

  class GetRemoteVersionWorker < BaseWorker
    attr_accessor :json_list
    def initialize(json_list)
      self.json_list = json_list
    end
    def perform_work
      entry = json_list.first
      version = entry["tag_name"]
      if version.empty?
        puts "I can't find version at remote!"
        exit(1)
      end
      version
    end
  end

  class GetRemoteAssetURLWorker < BaseWorker
    attr_accessor :json_list, :version, :prefix
    def initialize(json_list, version, prefix)
      self.json_list = json_list
      self.version = version
      self.prefix = prefix
    end
    def perform_work
      entry = json_list.find {|v| v["tag_name"] == version}
      assets = entry["assets"]
      asset = assets.find{|v| v["name"] =~ %r"#{prefix}"}
      asset["url"]
    end
  end

  class DownloadFileAtURLWorker < Workers::BasicWorker
    attr_accessor :token, :url, :filePath
    def initialize(token, url, filePath)
      self.token = token
      self.url = url
      self.filePath = filePath
    end
    def tool
      "curl"
    end
    def action
      headers = {}
      headers["Authorization"] = "token #{token}"
      headers["Accept"] = "application/octet-stream"
      headersString = headers.map{|k, v| "-H '#{k}: #{v}'"}.join(' ')
      "#{tool} -L -o #{filePath} #{headersString} #{url}"
    end
  end

  class GetTemporaryDirectoryWorker < BaseWorker
    def perform_work
      Dir.mktmpdir
    end
  end

  class UncompressFileToTemporaryDirectoryWorker < Workers::BasicWorker
    attr_accessor :filePath, :temporaryDirectory
    def initialize(filePath, temporaryDirectory)
      self.filePath = filePath
      self.temporaryDirectory = temporaryDirectory
    end
    def tool
      "tar"
    end
    def action
      "#{tool} -zxf #{filePath} -C #{temporaryDirectory}"
    end
  end

  class CleanupDependenciesDirectoryWorker < BaseWorker
    attr_accessor :directoryPath
    def initialize(directoryPath)
      self.directoryPath = directoryPath
    end
    def perform_work
      FileUtils.remove_entry directoryPath
      FileUtils.mkdir_p directoryPath
    end
  end

  class CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker < BaseWorker
    attr_accessor :temporaryDirectoryPath, :filesNames, :targetDirectoryPath
    def initialize(temporaryDirectoryPath, filesNames = [], targetDirectoryPath)
      self.temporaryDirectoryPath = temporaryDirectoryPath
      self.filesNames = filesNames
      self.targetDirectoryPath = targetDirectoryPath
    end
    def perform_work
      if filesNames.empty?
        puts "filesNames are empty!"
        return
      end
      files = filesNames.map{|x| File.join(temporaryDirectoryPath, x)}
      FileUtils.mv(files, targetDirectoryPath)
    end
  end

  class CopyProtobufFilesWorker < BaseWorker
    attr_accessor :dependenciesDirectoryPath, :protobufDirectoryName, :targetDirectoryPath
    def initialize(dependenciesDirectoryPath, protobufDirectoryName, targetDirectoryPath)
      self.dependenciesDirectoryPath = dependenciesDirectoryPath
      self.protobufDirectoryName = protobufDirectoryName
      self.targetDirectoryPath = targetDirectoryPath
    end
    def protobuf_files
      [
        "commands.pb.swift",
        "events.pb.swift",
        "models.pb.swift",
        "localstore.pb.swift"
      ]
    end
    def perform_work
      directory = File.join([self.dependenciesDirectoryPath, self.protobufDirectoryName])
      files = protobuf_files.map{|v| File.join([directory, v])}
      target_directory = self.targetDirectoryPath
      FileUtils.mv(files, target_directory)
    end
  end

  class RunCodegenScriptWorker < Workers::BasicWorker
    attr_accessor :scriptPath
    def initialize(scriptPath)
      self.scriptPath = scriptPath
    end
    def tool
      "ruby"
    end
    def action
      "#{tool} #{scriptPath}"
    end
  end

  class RemoveDirectoryWorker < BaseWorker
    attr_accessor :directoryPath
    def initialize(directoryPath)
      self.directoryPath = directoryPath
    end
    def perform_work
      FileUtils.remove_entry directoryPath
    end
  end

  class GetLockfileVersionWorker < BaseWorker
    attr_accessor :filePath, :key
    def initialize(filePath, key)
      self.key = key
      self.filePath = filePath
    end
    def perform_work
      (YAML.load File.open(filePath))[key]
    end
  end

  class SetLockfileVersionWorker < BaseWorker
    attr_accessor :filePath, :key, :value
    def initialize(filePath, key, value)
      self.filePath = filePath
      self.key = key
      self.value = value
    end
    def perform_work
      result = {key => value}.to_yaml
      result = result.gsub(/^---\s+/, '')
      File.open(filePath, 'w') do |file_handler|
        file_handler.write(result)
      end
    end
  end

  class GetLibraryfileVersionWorker < BaseWorker
    attr_accessor :filePath, :key
    def initialize(filePath, key)
      self.filePath = filePath
      self.key = key
    end
    def perform_work
      value = (YAML.load File.open(filePath))[key]
      SemanticVersioning::Parsers::Parser.parse(value)
    end
  end

  class SemanticCompareVersionsWorker < BaseWorker
    attr_accessor :semantic_versioning_parsed, :versions
    def initialize(semantic_versioning_parsed, versions)
      self.semantic_versioning_parsed = semantic_versioning_parsed
      self.versions = versions
    end
    def perform_work
      versions.find{|x| self.semantic_versioning_parsed.is_allowed?(SemanticVersioning::Version.parse(x))}
    end
  end
end

class Configuration
  class Commands
    class InstallCommand
    end
    class UpdateCommand
      attr_accessor :version
      def initialize(version = nil)
        self.version = version
      end
    end
    class ListCommand
    end
    class CurrentVersionCommand
    end
  end
  class EnvironmentVariables
    AVAILABLE_VARIABLES = {
      ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN: 'Access token to a middelware repositry'
    }
    def self.token
      ENV['ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN']
    end
    def self.variables_description
      AVAILABLE_VARIABLES.collect{|k, v| "#{k} -- #{v}"}.join('\n')
    end
  end
end

class Pipeline
  class BasePipeline < Pipeline
    def self.work(version, options)
      say "Lets fetch data from remote!"
      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      say "I have gathered information!"

      say "Now lets find our url to release!"
      assetURL = MiddlewareUpdater::GetRemoteAssetURLWorker.new(information, version, options[:iOSAssetMiddlewarePrefix]).work
      say "Our URL is: #{assetURL}"

      downloadFilePath = options[:downloadFilePath]
      say "Start downloading library to #{downloadFilePath}"
      MiddlewareUpdater::DownloadFileAtURLWorker.new(options[:token], assetURL, options[:downloadFilePath]).work
      say "Library is downloaded at #{downloadFilePath}"

      temporaryDirectory = MiddlewareUpdater::GetTemporaryDirectoryWorker.new.work
      say "Start uncompressing to directory #{temporaryDirectory}"
      MiddlewareUpdater::UncompressFileToTemporaryDirectoryWorker.new(downloadFilePath, temporaryDirectory).work

      ourDirectory = options[:dependenciesDirectoryPath]
      say "Cleaning up Dependencies directory #{ourDirectory}"
      MiddlewareUpdater::CleanupDependenciesDirectoryWorker.new(ourDirectory).work

      say "Moving files from temporaryDirectory #{temporaryDirectory} to ourDirectory: #{ourDirectory}"
      MiddlewareUpdater::CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker.new(temporaryDirectory, options.slice(:middlewareLibraryName, :protobufDirectoryName).values, ourDirectory).work

      say "Cleaning up Downloaded files"
      MiddlewareUpdater::RemoveDirectoryWorker.new(downloadFilePath).work
      MiddlewareUpdater::RemoveDirectoryWorker.new(temporaryDirectory).work

      say "Moving protobuf files from Dependencies to our project directory"
      MiddlewareUpdater::CopyProtobufFilesWorker.new(ourDirectory, options[:protobufDirectoryName], options[:targetDirectoryPath]).work

      say "Generate services from protobuf files"
      MiddlewareUpdater::RunCodegenScriptWorker.new(options[:swiftAutocodegenScript]).work
    end
  end
  class InstallPipeline < BasePipeline
    def self.start(options)
      say "Hey! You would like to install something, ok!"
      say "Let's check lock file for a version."

      librarylockFilePath = options[:librarylockFilePath]
      unless File.exists? librarylockFilePath
        say "I can't find library lock file at filepath #{librarylockFilePath} :("
      end

      version = MiddlewareUpdater::GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

      say "We have version <#{version}> in a lock file!"

      self.work(version, options)
    end
  end
  class UpdatePipeline < BasePipeline
    def self.store_version(version, options)
      say "Saving version <#{version}> to library lock file."
      librarylockFilePath = options[:librarylockFilePath]
      MiddlewareUpdater::SetLockfileVersionWorker.new(librarylockFilePath, options[:librarylockFileVersionKey], version).work
    end
    def self.install_with_version(options)
      version = options[:command].version
      say "Hey, you would like to install concrete version. #{version}"
      say "Lets fetch data from remote!"

      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      versions = MiddlewareUpdater::GetRemoteAvailableVersionsWorker.new(information).work
      if versions.include?(version)
        self.work(version, options)
        self.store_version(version, options)
      else 
        say "I can't find version #{version}"
        say "versions are: #{versions}"
      end
    end
    def self.install_with_restrictions(options)
      say "Hey, you would like to install version with restrictions."
      say "Lets gather restrictions!"

      # well, we could use another key, but keep it like in lock file.
      restrictions = MiddlewareUpdater::GetLibraryfileVersionWorker.new(options[:libraryFilePath], options[:librarylockFileVersionKey]).work

      say "I have restrictions: #{restrictions}"

      unless restrictions
        say "Restrctions are not valid at #{options[:libraryFilePath]}"
        return
      end

      say "Lets fetch data from remote!"
      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      versions = MiddlewareUpdater::GetRemoteAvailableVersionsWorker.new(information).work

      version = MiddlewareUpdater::SemanticCompareVersionsWorker.new(restrictions, versions).work
      if version
        say "I choose version: #{version}"
        self.work(version, options)
        self.store_version(version, options)
      else
        say "I can't find appropriate version: #{version}"
      end
    end
    def self.install_without_restrictions(options)
      say "Hey, you would like to install latest remote version!"
      say "Lets fetch data from remote!"
      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      say "I have gathered information!"

      version = MiddlewareUpdater::GetRemoteVersionWorker.new(information).work

      say "We have fresh version <#{version}> in remote!"
      self.work(version, options)
      self.store_version(version, options)
    end
    def self.start(options)
      say "Hey! You would like to update something, ok!"

      if options[:command].version
        self.install_with_version(options)
        return
      end

      libraryFilePath = options[:libraryFilePath]
      unless File.exists? libraryFilePath
        say "I can't find library file at filepath #{libraryFilePath}."
        # so, we have to install any version, right?
        self.install_without_restrictions(options)
      else
        self.install_with_restrictions(options)
      end
    end
  end
  class ListPipeline < Pipeline
    def self.start(options)
      say "Hey! You would like to list available versions?"
      say "Lets fetch data from remote!"

      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      say "I have gathered information!"

      say "We have versions below"
      versions = MiddlewareUpdater::GetRemoteAvailableVersionsWorker.new(information).work

      say "Versions: \n"
      say "#{JSON.pretty_generate(versions)}"
    end
  end
  class CurrentVersionPipeline < Pipeline
    def self.start(options)
      say "Hey! You would like to print current version from Lockfile, ok!"
      say "Let's check lock file for a version."

      librarylockFilePath = options[:librarylockFilePath]
      unless File.exists? librarylockFilePath
        say "I can't find library lock file at filepath #{librarylockFilePath} :("
      end

      version = MiddlewareUpdater::GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

      say "Lockfile Version: \n"
      say "#{version}"
    end
  end
  class << self
    def say(messages)
      Voice.say messages
    end
    def start(options)
      say "Lets find you command in a list..."
      case options[:command]
      when Configuration::Commands::InstallCommand then InstallPipeline.start(options)
      when Configuration::Commands::UpdateCommand then UpdatePipeline.start(options)
      when Configuration::Commands::ListCommand then ListPipeline.start(options)
      when Configuration::Commands::CurrentVersionCommand then CurrentVersionPipeline.start(options)
      else
        say "I don't recognize this command: #{options[:command]}"
        finalize
        return
      end

      say "Congratulations! You have just generated new protobuf files!"
      finalize
    end

    def finalize
      puts "Goodbye!"
    end
  end
end

class MainWork
  class << self
    def work(arguments)
      work = new
      work.work(work.parse_options(arguments))
    end
  end

  # fixing arguments
  def fix_options(options)
    options
  end
  def required_keys
    []
  end
  def valid_options?(options)
    # true
    (required_keys - options.keys).empty?
  end

  def work(options = {})
    options = fix_options(options)

    if options[:inspection]
      puts "options are: #{options}"
    end

    unless valid_options? options
      puts "options are not valid!"
      puts "options are: #{options}"
      puts "missing options: #{required_keys}"
      exit(0)
    end

    ShellExecutor.setup options[:dry_run]

    Pipeline.start(options)
  end

  class DefaultOptionsGenerator
    class << self
      def defaultOptions
        options = {
          # commands
          command: Configuration::Commands::InstallCommand.new,

          # library file options
          libraryFilePath: "#{__dir__}/../Libraryfile",
          librarylockFilePath: "#{__dir__}/../Libraryfile.lock",
          librarylockFileVersionKey: "middleware.version",

          # repository options
          token: Configuration::EnvironmentVariables.token || '',
          repositoryURL: "https://api.github.com/repos/anytypeio/go-anytype-middleware/releases",

          # download file options
          downloadFilePath: "#{__dir__}/../lib.tar.gz",
          iOSAssetMiddlewarePrefix: "ios_framework_",

          # download archive structure options
          middlewareLibraryName: "Lib.framework",
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

    #{Configuration::EnvironmentVariables.variables_description}

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
      opts.on('--install', '--install', 'Install version from library lock file if it is exists.') {|v| options[:command] = Configuration::Commands::InstallCommand.new}
      opts.on('--update', '--update [VERSION]', 'Fetch new version from remote and write it to lock file.') {|v| options[:command] = Configuration::Commands::UpdateCommand.new(v)}
      opts.on('--list', '--list', 'List available versions from remote') {|v| options[:command] = Configuration::Commands::ListCommand.new}
      opts.on('--current_version', '--current_version', 'Print current version') {|v| options[:command] = Configuration::Commands::CurrentVersionCommand.new}

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

MainWork.work(ARGV)