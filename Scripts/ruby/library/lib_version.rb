require_relative "../constants"

class LibraryVersion
	def self.set(version)
		validate(version)
	    File.open(Constants::LIBRARY_FILE_PATH, 'w') do |file_handler|
	      file_handler.write(version)
	      puts "Updated library file"
	    end
	end

	def self.get
		filePath = Constants::LIBRARY_FILE_PATH
    	version = File.read(filePath)
    	validate(version)
    	return version
	end

	private_class_method def self.validate(version) 
		if version.index("v") != 0
			puts "Unsupported format of version: #{version}"
			puts "It should start with [v] example: v0.17.3"
			exit 1
		end
	end
end