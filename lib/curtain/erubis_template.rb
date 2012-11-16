require 'tilt'
require 'curtain/erubis'

module Curtain
  class ErubisTemplate < Tilt::Template
    DEFAULT_OUTPUT_VARIABLE = '@output_buffer'

    def self.engine_initialized?
      defined? ::ERB
    end

    def initialize_engine
      require_template_library 'erubis'
    end

    def prepare
      @engine = Curtain::Erubis.new(data, options)
    end

    def precompiled_template(locals)
      @engine.src
    end
  end
end

Tilt.prefer Curtain::ErubisTemplate, 'erb'
