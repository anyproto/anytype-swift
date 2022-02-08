require 'shellwords'

class ShellExecutor
  def self.run_command_line(line)
    puts "execute #{line}"
    run_command_line_silent(line)
  end

  def self.run_command_line_silent(line)

    result = %x(#{line})
    
    if $?.to_i != 0
      puts "Failed < #{result} > \n because of < #{$?} >"
      exit($?.to_i)
    end
    
    result
  end
end