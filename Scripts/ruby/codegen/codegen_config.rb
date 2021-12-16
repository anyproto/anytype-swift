class CodegenConfig
  ProtobufDirectory = File.expand_path("#{__dir__}/../../../Modules/ProtobufMessages/Sources") + "/"
  CommandsFilePath = ProtobufDirectory + "commands.pb.swift"
  ModelsFilePath = ProtobufDirectory + "models.pb.swift"
  EventsFilePath = ProtobufDirectory + "events.pb.swift"
  LocalstoreFilePath = ProtobufDirectory + "localstore.pb.swift"
end