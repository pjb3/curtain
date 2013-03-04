require 'active_support/core_ext'
require 'curtain/templating'
require 'curtain/rendering'
require 'curtain/block_helpers'
require 'curtain/url_helpers'
require 'curtain/caching'
require 'curtain/variable_support'
require 'curtain/html_helpers'
require 'curtain/version'

module Curtain

  def self.included(cls)
    cls.class_eval do
      include Curtain::Templating
      include Curtain::Rendering
      include Curtain::BlockHelpers
      include Curtain::UrlHelpers
      include Curtain::Caching
      include Curtain::VariableSupport
      include Curtain::HTMLHelpers
    end
  end

  class View
    include Curtain

    def initialize(attrs={})
      attrs.each do |k,v|
        send("#{k}=", v)
      end
    end
  end

end
