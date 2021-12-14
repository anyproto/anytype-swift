require_relative "../constants"

class LibraryFile
	def self.set(version)
		validate_library_file_path()
		validate(version)
	    File.open(Constants::LIBRARY_FILE_PATH, 'w') do |file_handler|
	      file_handler.write(version)
	      puts "Updated version #{version} in library file"
	    end
	end

	def self.get
		validate_library_file_path()
    	version = File.read(Constants::LIBRARY_FILE_PATH)
    	validate(version)
    	puts "Version in the library file: #{version}"
    	return version
	end

	private_class_method def self.validate_library_file_path
	    unless File.exists? Constants::LIBRARY_FILE_PATH
	      puts "I can't find library file at #{libraryFilePath}."
	      exit 1
	    end
	end

	private_class_method def self.validate(version) 
		if version.index("v") != 0
			puts "Unsupported format of version: #{version}"
			puts "It should start with [v] example: v0.17.3"
			exit 1
		end
	end
end