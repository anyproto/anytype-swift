require_relative '../library/environment'
require_relative '../commands'
require_relative '../workers_hub'

class DefaultOptionsGenerator
  def self.populate(arguments, options)
    new_options = generate(arguments, options)
    new_options = new_options.merge(options)
    fixOptions(new_options)
  end

  private_class_method def self.filePathOptions
    [
      :libraryFilePath,
      :librarylockFilePath,
      :downloadFilePath,
      :dependenciesDirectoryPath,
      :targetDirectoryPath,
      :swiftAutocodegenScript
    ]
  end

  private_class_method def self.fixOptions(options)
    result_options = options
    filePathOptions.each do |v|
      unless result_options[v].nil?
        result_options[v] = File.expand_path(result_options[v])
      end
    end
    result_options
  end

  private_class_method def self.generate(arguments, options)
    result_options = defaultOptions.merge options
    fixOptions(result_options)
  end

  private_class_method def self.defaultOptions
    options = {
      # commands
      command: Commands::InstallCommand.new,

      # library file options
      libraryFilePath: "#{__dir__}../../../../Libraryfile",
      librarylockFilePath: "#{__dir__}../../../../Libraryfile.lock",

      # repository options
      token: EnvironmentVariables.token || '',

      # download file options
      downloadFilePath: "#{__dir__}../../../../lib.tar.gz",

      # target directory options
      dependenciesDirectoryPath: "#{__dir__}../../../../Dependencies/Middleware",
      targetDirectoryPath: "#{__dir__}../../../../Modules/ProtobufMessages/Sources/",
      swiftAutocodegenScript: "#{__dir__}../../../ruby/codegen/anytype_swift_codegen_runner.rb"
    }
  end
end