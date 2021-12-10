class Constants 
	LOCKFILE_VERSION_KEY = "middleware.version"
	REPOSITORY_URL = "https://api.github.com/repos/anytypeio/go-anytype-middleware/releases"
	PROTOBUF_DIRECTORY_NAME = "protobuf"

  	libraryFilePath = File.expand_path("#{__dir__}../../../../Libraryfile")
  	librarylockFilePath = File.expand_path("#{__dir__}../../../../Libraryfile.lock")
  	downloadFilePath = File.expand_path("#{__dir__}../../../../lib.tar.gz")
  	dependenciesDirectoryPath = File.expand_path("#{__dir__}../../../../Dependencies/Middleware")
  	targetDirectoryPath = File.expand_path("#{__dir__}../../../../Modules/ProtobufMessages/Sources/")
end