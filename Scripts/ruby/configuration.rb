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

module MiddlewareUpdater
  module Configuration
    BaseCommand = Commands::BaseCommand
    module Commands
      class InstallCommand < BaseCommand
      end
      class UpdateCommand < BaseCommand
        attr_accessor :version
        def initialize(version = nil)
          self.version = version
        end
      end
      class ListCommand < BaseCommand
      end
      class CurrentVersionCommand < BaseCommand
      end
    end

    
    class EnvironmentVariables
      AVAILABLE_VARIABLES = {
        ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN: 'Access token to a middelware repositry'
      }
      def self.token
        ENV['ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN']
      end
      def self.variables_description
        AVAILABLE_VARIABLES.collect{|k, v| "#{k} -- #{v}"}.join('\n')
      end
    end
  end
end