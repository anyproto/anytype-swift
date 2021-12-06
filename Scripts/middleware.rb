require_relative 'ruby/middleware_updater'
require_relative 'ruby/options_parser'

class Main
  def self.exec(arguments)
    options = OptionsParser.new.parse_options(arguments)
    ShellExecutor.setup options[:dry_run]
    Pipeline.start(options)
  end
end

Main.exec(ARGV)