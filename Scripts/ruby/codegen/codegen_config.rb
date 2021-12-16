class CodegenConfig
  ProtobufDirectory = File.expand_path("#{__dir__}/../../../Modules/ProtobufMessages/Sources") + "/"
  CommandsFilePath = ProtobufDirectory + "commands.pb.swift"
  ModelsFilePath = ProtobufDirectory + "models.pb.swift"
  EventsFilePath = ProtobufDirectory + "events.pb.swift"
  LocalstoreFilePath = ProtobufDirectory + "localstore.pb.swift"

  def self.make_all
    [
      { transform: "memberwiseInitializer", filePath: CodegenConfig::ModelsFilePath }, 
      { transform: "memberwiseInitializer", filePath: CodegenConfig::EventsFilePath },
      { transform: "memberwiseInitializer", filePath: CodegenConfig::LocalstoreFilePath },

      { transform: "memberwiseInitializer", filePath: CodegenConfig::CommandsFilePath },
      { transform: "errorAdoption", filePath: CodegenConfig::CommandsFilePath }, 
      { transform: "serviceWithRequestAndResponse", filePath: CodegenConfig::CommandsFilePath }
    ]
  end
end