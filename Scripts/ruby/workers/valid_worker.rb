class AlwaysValidWorker < Workers::BaseWorker
  def is_valid?
    true
  end
end