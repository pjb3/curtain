require 'active_support/core_ext'
require 'curtain/templating'
require 'curtain/rendering'
require 'curtain/variable_support'
require 'curtain/version'

module Curtain

  def self.included(cls)
    cls.class_eval do
      include Curtain::Templating
      include Curtain::Rendering
      include Curtain::VariableSupport
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
