class CodegenConfig
  ProtobufDirectory = "#{__dir__}/../../../Modules/ProtobufMessages/Sources/"
  CommandsFilePath = ProtobufDirectory + "commands.pb.swift"
  ModelsFilePath = ProtobufDirectory + "models.pb.swift"
  EventsFilePath = ProtobufDirectory + "events.pb.swift"
  LocalstoreFilePath = ProtobufDirectory + "localstore.pb.swift"

  def self.make_all
    [make_inits_for_commands, make_inits_for_models, make_inits_for_events, make_inits_for_localstore, make_error_protocols_for_commands, make_services_for_commands]
  end

  def self.make_error_protocols_for_commands
    new("error_protocol", CodegenConfig::CommandsFilePath)
  end
  def self.make_services_for_commands
    new("services", CodegenConfig::CommandsFilePath)
  end
  def self.make_inits_for_commands
    new("inits", CodegenConfig::CommandsFilePath)
  end
  def self.make_inits_for_models
    new("inits", CodegenConfig::ModelsFilePath)
  end
  def self.make_inits_for_events
    new("inits", CodegenConfig::EventsFilePath)
  end
  def self.make_inits_for_localstore
    new("inits", CodegenConfig::LocalstoreFilePath)
  end

  attr_accessor :transform, :filePath
  def initialize(transform, filePath)
    self.transform = transform
    self.filePath = filePath
  end

  def options
    {
      transform: transform,
      filePath: filePath,
    }
  end

end

CodegenConfig.make_all()