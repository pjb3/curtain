require 'active_support/core_ext'
require 'erubis'
require 'tilt'
require 'temple'

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

module Curtain
  class Erubis < ::Erubis::Eruby
    def add_text(src, text)
      return if text.empty?
      src << "@output_buffer.safe_concat('" << escape_text(text) << "');"
    end

    BLOCK_EXPR = /\s+(do|\{)(\s*\|[^|]*\|)?\s*\Z/

    def add_expr_literal(src, code)
      if code =~ BLOCK_EXPR
        src << '@output_buffer.append= ' << code
      else
        src << '@output_buffer.append= (' << code << ');'
      end
    end

    def add_expr_escaped(src, code)
      if code =~ BLOCK_EXPR
        src << "@output_buffer.safe_append= " << code
      else
        src << "@output_buffer.safe_concat((" << code << ").to_s);"
      end
    end

    def add_postamble(src)
      src << '@output_buffer.to_s'
    end
  end
end

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
class View
  attr_accessor :output_buffer

  def initialize
    @output_buffer = Curtain::OutputBuffer.new
  end

  def capture
    original_buffer = @output_buffer
    @output_buffer = Curtain::OutputBuffer.new
    yield
  ensure
    @output_buffer = original_buffer
  end

  def form(attrs={}, &body)
    %{<form>#{capture(&body)}</form>}.html_safe
  end

  def input(attrs={})
    %{<input#{attrs.map{|n,v| %{ #{n}="#{v}"} }.join}/>}.html_safe
  end

  def a(attrs={}, &body)
    %{<a#{Array(attrs).map{|n,v| %{ #{n}="#{v}"} }.join}>#{capture(&body)}</a>}.html_safe
  end
end

template = Tilt.new('example.erb', :buffer => '@output_buffer', :use_html_safe => true, :disable_capture => true, :generator => Temple::Generators::RailsOutputBuffer)
puts template.render(View.new)

template = Tilt.new('example.slim', :buffer => '@output_buffer', :use_html_safe => true, :disable_capture => true, :generator => Temple::Generators::RailsOutputBuffer)
puts template.render(View.new)
