class Constants 
	LOCKFILE_VERSION_KEY = "middleware.version"
	REPOSITORY_URL = "https://api.github.com/repos/anytypeio/go-anytype-middleware/releases"
	PROTOBUF_DIRECTORY_NAME = "protobuf"

  	LIBRARY_FILE_PATH = File.expand_path("#{__dir__}/../../Libraryfile")
  	LIBRARY_LOCK_FILE_PATH = File.expand_path("#{__dir__}/../../Libraryfile.lock")
  	DOWNLOAD_FILE_PATH = File.expand_path("#{__dir__}/../../lib.tar.gz")
  	DEPENDENCIES_DIR_PATH = File.expand_path("#{__dir__}/../../Dependencies/Middleware")
  	TARGET_DIR_PATH = File.expand_path("#{__dir__}/../../Modules/ProtobufMessages/Sources/")
end