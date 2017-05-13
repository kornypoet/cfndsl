# Global CfnDsl options
module CfnDsl
  module_function

  def reserved_items
    %w[Resource Parameter Output].freeze
  end

  def debug(msg)
    warn msg if debug?
  end

  def debug?
    @debug
  end

  def debug!
    @debug = true
  end
end
