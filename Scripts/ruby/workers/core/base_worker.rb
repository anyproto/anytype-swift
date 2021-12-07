require_relative '../../library/shell_executor'

class BaseWorker
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
    is_valid?
  end

  def action
    ''
  end

  def work
    unless can_run?
      puts "Tool #{tool} does not exist. Please, install it or select alternatives."
      exit(1)
    end
    perform_work
  end

  def perform_work
    executor.run_command_line action
  end
end