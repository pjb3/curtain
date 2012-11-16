module Curtain
  module BlockHelpers
    def capture
      original_buffer = @output_buffer
      @output_buffer = Curtain::OutputBuffer.new
      yield
    ensure
      @output_buffer = original_buffer
    end
  end
end
