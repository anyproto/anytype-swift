require_relative '../library/environment'

class DefaultOptionsGenerator
  def self.defaultOptions
    options = {
      # commands
      command: Commands::InstallCommand.new,

      # library file options
      libraryFilePath: "#{__dir__}/../Libraryfile",
      librarylockFilePath: "#{__dir__}/../Libraryfile.lock",
      librarylockFileVersionKey: "middleware.version",

      # repository options
      token: EnvironmentVariables.token || '',
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

  def self.filePathOptions
    [
      :libraryFilePath,
      :librarylockFilePath,
      :downloadFilePath,
      :dependenciesDirectoryPath,
      :targetDirectoryPath,
      :swiftAutocodegenScript
    ]
  end

  def self.fixOptions(options)
    result_options = options
    filePathOptions.each do |v|
      unless result_options[v].nil?
        result_options[v] = File.expand_path(result_options[v])
      end
    end
    result_options
  end

  def self.generate(arguments, options)
    result_options = defaultOptions.merge options
    fixOptions(result_options)
  end

  def self.populate(arguments, options)
    new_options = self.generate(arguments, options)
    new_options = new_options.merge(options)
    fixOptions(new_options)
  end
end