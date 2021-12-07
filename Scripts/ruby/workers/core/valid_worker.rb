require_relative 'base_worker'

class AlwaysValidWorker < BaseWorker
  def is_valid?
    true
  end
end