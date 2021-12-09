require_relative '../library/environment'
require_relative '../commands'

class DefaultOptions
  def self.options
    options = {
      # commands
      command: Commands::InstallCommand.new,
      runsOnCI: false,
      token: EnvironmentVariables.token || '',

      # paths
      libraryFilePath: File.expand_path("#{__dir__}../../../../Libraryfile"),
      librarylockFilePath: File.expand_path("#{__dir__}../../../../Libraryfile.lock"),
      downloadFilePath: File.expand_path("#{__dir__}../../../../lib.tar.gz"),
      dependenciesDirectoryPath: File.expand_path("#{__dir__}../../../../Dependencies/Middleware"),
      targetDirectoryPath: File.expand_path("#{__dir__}../../../../Modules/ProtobufMessages/Sources/"),
      swiftAutocodegenScript: File.expand_path("#{__dir__}../../../ruby/codegen/anytype_swift_codegen_runner.rb")
    }
  end
end