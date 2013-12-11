module Curtain
  module FormHelpers

    def self.included(cls)
      cls.class_eval do
        attr_accessor :current_form

        delegate :button, :checkbox, :color, :date, :datetime, :email, :file, :hidden, :image, :input, :label, :month, :number, :password, :radio, :range, :reset, :search, :select, :submit, :tel, :text, :textarea, :time, :url, :week, :to => :current_form
      end
    end

    def form(attrs={}, &body)
      # Have a property for a default form builder
      # Accept builder and object attrs
      # Allow for custom builder classes
      self.current_form = FormBuilder.new
      content = content_tag(:form, attrs, &body)
      self.current_form = nil
      content
    end
  end
end
