require 'optparse'
require 'shellwords'
require 'pathname'

require 'tmpdir'

require 'net/http'

require 'yaml'
require 'json'

require_relative 'library/shell_executor'
require_relative 'library/voice'
require_relative 'library/workers'
require_relative 'library/semantic_versioning'
require_relative 'library/commands'

require_relative 'configuration'

require_relative 'workers/remote_info_worker'
require_relative 'workers/valid_worker'
require_relative 'workers/available_versions_worker'
require_relative 'workers/remote_version_worker'
require_relative 'workers/asset_url_worker'
require_relative 'workers/download_file_worker'

module MiddlewareUpdater
  class GetTemporaryDirectoryWorker < AlwaysValidWorker
    def perform_work
      Dir.mktmpdir
    end
  end

  class UncompressFileToTemporaryDirectoryWorker < Workers::BaseWorker
    attr_accessor :filePath, :temporaryDirectory
    def initialize(filePath, temporaryDirectory)
      self.filePath = filePath
      self.temporaryDirectory = temporaryDirectory
    end
    def tool
      "tar"
    end
    def action
      "#{tool} -zxf #{filePath} -C #{temporaryDirectory}"
    end
  end

  class CleanupDependenciesDirectoryWorker < AlwaysValidWorker
    attr_accessor :directoryPath
    def initialize(directoryPath)
      self.directoryPath = directoryPath
    end
    def perform_work
      FileUtils.remove_entry directoryPath
      FileUtils.mkdir_p directoryPath
    end
  end

  class CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker < AlwaysValidWorker
    attr_accessor :temporaryDirectoryPath, :filesNames, :targetDirectoryPath
    def initialize(temporaryDirectoryPath, filesNames = [], targetDirectoryPath)
      self.temporaryDirectoryPath = temporaryDirectoryPath
      self.filesNames = filesNames
      self.targetDirectoryPath = targetDirectoryPath
    end
    def perform_work
      if filesNames.empty?
        puts "filesNames are empty!"
        return
      end
      files = filesNames.map{|x| File.join(temporaryDirectoryPath, x)}
      FileUtils.mv(files, targetDirectoryPath)
    end
  end

  class CopyProtobufFilesWorker < AlwaysValidWorker
    attr_accessor :dependenciesDirectoryPath, :protobufDirectoryName, :targetDirectoryPath
    def initialize(dependenciesDirectoryPath, protobufDirectoryName, targetDirectoryPath)
      self.dependenciesDirectoryPath = dependenciesDirectoryPath
      self.protobufDirectoryName = protobufDirectoryName
      self.targetDirectoryPath = targetDirectoryPath
    end
    def protobuf_files
      [
        "commands.pb.swift",
        "events.pb.swift",
        "models.pb.swift",
        "localstore.pb.swift"
      ]
    end
    def perform_work
      directory = File.join([self.dependenciesDirectoryPath, self.protobufDirectoryName])
      files = protobuf_files.map{|v| File.join([directory, v])}
      target_directory = self.targetDirectoryPath
      FileUtils.mv(files, target_directory)
    end
  end

  class RunCodegenScriptWorker < Workers::BaseWorker
    attr_accessor :scriptPath
    def initialize(scriptPath)
      self.scriptPath = scriptPath
    end
    def tool
      "ruby"
    end
    def action
      "#{tool} #{scriptPath}"
    end
  end

  class RemoveDirectoryWorker < AlwaysValidWorker
    attr_accessor :directoryPath
    def initialize(directoryPath)
      self.directoryPath = directoryPath
    end
    def perform_work
      FileUtils.remove_entry directoryPath
    end
  end

  class GetLockfileVersionWorker < AlwaysValidWorker
    attr_accessor :filePath, :key
    def initialize(filePath, key)
      self.key = key
      self.filePath = filePath
    end
    def perform_work
      (YAML.load File.open(filePath))[key]
    end
  end

  class SetLockfileVersionWorker < AlwaysValidWorker
    attr_accessor :filePath, :key, :value
    def initialize(filePath, key, value)
      self.filePath = filePath
      self.key = key
      self.value = value
    end
    def perform_work
      result = {key => value}.to_yaml
      result = result.gsub(/^---\s+/, '')
      File.open(filePath, 'w') do |file_handler|
        file_handler.write(result)
      end
    end
  end

  class GetLibraryfileVersionWorker < AlwaysValidWorker
    attr_accessor :filePath, :key
    def initialize(filePath, key)
      self.filePath = filePath
      self.key = key
    end
    def perform_work
      value = (YAML.load File.open(filePath))[key]
      SemanticVersioning::Parsers::Parser.parse(value)
    end
  end

  class SemanticCompareVersionsWorker < AlwaysValidWorker
    attr_accessor :semantic_versioning_parsed, :versions
    def initialize(semantic_versioning_parsed, versions)
      self.semantic_versioning_parsed = semantic_versioning_parsed
      self.versions = versions
    end
    def perform_work
      versions.find{|x| self.semantic_versioning_parsed.is_allowed?(SemanticVersioning::Version.parse(x))}
    end
  end
end