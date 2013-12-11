require 'active_support/core_ext'
require 'curtain/version'
require 'curtain/templating'
require 'curtain/rendering'
require 'curtain/variable_support'
require 'curtain/output_buffer'
require 'curtain/erubis'
require 'curtain/erubis_template'
require 'curtain/html_helpers'
require 'curtain/form_helpers'
require 'curtain/form_builder'
require 'curtain/caching'

module Curtain

  def self.included(cls)
    cls.class_eval do
      include Curtain::Templating
      include Curtain::Rendering
      include Curtain::VariableSupport
      include Curtain::HTMLHelpers
      include Curtain::FormHelpers
      include Curtain::Caching
    end
  end

  class View
    include Curtain

    def initialize(attrs={})
      @output_buffer = Curtain::OutputBuffer.new
      attrs.each do |k,v|
        send("#{k}=", v)
      end
    end

    def self.render(*args)
      new.render(*args)
    end
  end

  def self.render(*args)
    View.render(*args)
  end

end
