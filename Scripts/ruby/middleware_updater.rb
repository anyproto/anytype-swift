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
require_relative 'pipeline'

module MiddlewareUpdater
  class AlwaysValidWorker < Workers::BaseWorker
    def is_valid?
      true
    end
  end

  # version=`curl -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" -sL https://$GITHUB/repos/$REPO/releases | jq ".[] | select(.tag_name == \"$MIDDLEWARE_VERSION_BY_TAG_NAME\")"`
  class GetRemoteInformationWorker < AlwaysValidWorker
    attr_accessor :token, :url
    def initialize(token, url)
      self.token = token
      self.url = url
    end
    def is_valid?
      (self.token || '').empty? == false
    end
    def work
      unless can_run?
        puts <<-__REASON__
        Access token does not exist. 
        Please, provide it by cli argument or environment variable. 
        Run `ruby #{$0} --help`
        __REASON__
        exit(1)
      end
      perform_work
    end
    def perform_work
      # fetch curl -H "Authorization: token Token" -H "Accept: application/vnd.github.v3+json" -sL https://api.github.com/repos/anytypeio/go-anytype-middleware/releases
      uri = URI(url)
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "token #{token}"
      request["Accept"] = "application/vnd.github.v3+json"
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http|
        http.request(request)
      }
      if Integer(response.code) >= 400
        puts "Code: #{response.code} and response: #{JSON.parse(response.body)}"
        exit(1)
      end
      JSON.parse(response.body)
    end
  end

  class GetRemoteAvailableVersionsWorker < AlwaysValidWorker
    attr_accessor :json_list
    def initialize(json_list)
      self.json_list = json_list
    end
    def perform_work
      json_list.map{|v| v["tag_name"]}
    end
  end

  class GetRemoteVersionWorker < AlwaysValidWorker
    attr_accessor :json_list
    def initialize(json_list)
      self.json_list = json_list
    end
    def perform_work
      entry = json_list.first
      version = entry["tag_name"]
      if version.empty?
        puts "I can't find version at remote!"
        exit(1)
      end
      version
    end
  end

  class GetRemoteAssetURLWorker < AlwaysValidWorker
    attr_accessor :json_list, :version, :prefix
    def initialize(json_list, version, prefix)
      self.json_list = json_list
      self.version = version
      self.prefix = prefix
    end
    def perform_work
      entry = json_list.find {|v| v["tag_name"] == version}
      assets = entry["assets"]
      asset = assets.find{|v| v["name"] =~ %r"#{prefix}"}
      asset["url"]
    end
  end

  class DownloadFileAtURLWorker < Workers::BaseWorker
    attr_accessor :token, :url, :filePath
    def initialize(token, url, filePath)
      self.token = token
      self.url = url
      self.filePath = filePath
    end
    def tool
      "curl"
    end
    def action
      headers = {}
      headers["Authorization"] = "token #{token}"
      headers["Accept"] = "application/octet-stream"
      headersString = headers.map{|k, v| "-H '#{k}: #{v}'"}.join(' ')
      "#{tool} -L -o #{filePath} #{headersString} #{url}"
    end
  end

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