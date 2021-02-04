module Workers
  class BasicWorker
    attr_reader :executor
    def executor
      @executor || ShellExecutor
    end

    def tool
      ''
    end

    def is_valid?
      %x(which #{tool}) != ""
    end

    def can_run?
      is_valid? || executor.dry?
    end

    def action
      ''
    end

    def work
      unless can_run?
        puts "Tool #{tool} does not exist. Please, install it or select alternatives."
        exit(0)
      end
      perform_work
    end

    def perform_work
      executor.run_command_line action
    end
  end

  class TravelerWorker < BasicWorker
    attr_accessor :path
    def initialize(path)
      self.path = path
    end

    def tool
      "Ruby::Dir.chdir"
    end

    def is_valid?
      # check that tool is valid by following.
      # 1. file path exists.
      # 2. it is a directory.
      puts "Path is: #{path}"
      File.exists?(path) && Dir.exists?(path)
    end
    def perform_work
      Dir.chdir path
    end
  end
end