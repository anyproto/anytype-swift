 class DirHelper
  def self.allFiles(dir, fileExtension)
    Dir.entries(dir)
      .map{ |fileName|
        File.join(dir, fileName)
      }
      .select{ |file|
        File.file?(file) && File.extname(file) == ".#{fileExtension}"
      }
  end
end