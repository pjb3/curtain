module Curtain
  module BlockHelpers
    def capture(&block)
      if respond_to?(:capture_haml)
        capture_haml(&block)
      else
        original_buffer = @output_buffer
        @output_buffer = ""
        yield
        result = @output_buffer
        result
      end
    ensure
      @output_buffer = original_buffer
    end

    def concat(s)
      if respond_to?(:haml_concat)
        haml_concat(s)
      else
        @output_buffer << s
      end
    end
  end
end
