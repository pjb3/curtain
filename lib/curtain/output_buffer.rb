require 'active_support/core_ext/string/output_safety'

module Curtain
  class OutputBuffer < ActiveSupport::SafeBuffer
    def <<(value)
      super(value.to_s)
    end
    alias :append= :<<
    alias :safe_append= :<<
    alias :safe_contact :<<
  end
end
