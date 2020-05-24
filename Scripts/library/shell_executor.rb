require 'shellwords'

class ShellExecutor
  @@dry_run = false
  class << self
    # setup
    def setup (dry_run = false)
      @@dry_run = dry_run
    end

    def dry?
      @@dry_run
    end

    def run_command_line(line)
      # puts "#{line}"
      if dry?
        puts "#{line} -> Skip. Dry run."
      else
        # if run
        puts "run #{line}"
        result = %x(#{line})
        # puts "result is " + result.to_s
        if $?.to_i != 0
          puts "Failing < #{result} > \n because of < #{$?} >"
          exit($?.to_i)
        end
        result
      end
    end
  end
end