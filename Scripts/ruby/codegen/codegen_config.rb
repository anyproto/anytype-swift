class CodegenConfig
  ProtobufDirectory = File.expand_path("#{__dir__}/../../../Modules/ProtobufMessages/Sources/Generated") + "/"
  CommandsFilePath = ProtobufDirectory + "commands.pb.swift"
  ModelsFilePath = ProtobufDirectory + "models.pb.swift"
  EventsFilePath = ProtobufDirectory + "events.pb.swift"
  LocalstoreFilePath = ProtobufDirectory + "localstore.pb.swift"

  CodegenTemplatesPath = File.expand_path("#{__dir__}/../../../Templates/Middleware")
  CodegenPath = File.expand_path("#{__dir__}/../../../Tools/anytype-swift-codegen")
end