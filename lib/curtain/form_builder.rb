module Curtain
  class FormBuilder
    include HTMLHelpers

    attr_accessor :object

    def initialize(object=nil)
      self.object = object
    end

    def form_object(object)
      prev_object = self.object
      self.object = object
      yield
      self.object = prev_object
      object
    end

    def label(content=nil, attrs={}, &body)
      if content.is_a?(Symbol)
        attrs = { for: content }.merge(attrs)
        content = content.to_s.titleize
      end
      content_tag(:label, content, attrs, &body)
    end

    NO_VALUE_INPUT_TYPES = %w[checkbox file password radio]

    def input(name=nil, attrs={})
      if name.is_a?(Hash)
        name = nil
        attrs = name
      end

      if name
        new_attrs = { name: name }

        if object && !NO_VALUE_INPUT_TYPES.include?(attrs[:type])
          new_attrs[:value] = object.try(name)
        end

        unless attrs.has_key?(:id) && !attrs[:id]
          attrs = attrs.merge(id: name)
        end

        attrs = new_attrs.merge(attrs)
      end

      void_tag(:input, attrs)
    end

    # @!method color(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="color"
    # @!method date(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="date"
    # @!method datetime(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="datetime"
    # @!method datetime_local(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="datetime_local"
    # @!method email(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="email"
    # @!method file(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="file"
    # @!method hidden(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="hidden"
    # @!method image(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="image"
    # @!method month(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="month"
    # @!method number(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="number"
    # @!method password(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="password"
    # @!method range(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="range"
    # @!method search(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="search"
    # @!method tel(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="tel"
    # @!method text(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="text"
    # @!method time(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="time"
    # @!method url(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="url"
    # @!method week(name, attrs={})
    #   @param name [String] The value for the name attribute
    #   @param attrs [Hash] The attributes for the tag
    #   @return [String] HTML input tag with type="week"P
    INPUT_TAG_NAMES = [
      :checkbox,
      :color,
      :date,
      :datetime,
      :datetime_local,
      :email,
      :file,
      :hidden,
      :image,
      :month,
      :number,
      :password,
      :radio,
      :range ,
      :search,
      :tel,
      :text,
      :time ,
      :url,
      :week
    ].each do |tag|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{tag}(name, attrs={})
          input(name, { type: '#{tag.to_s.gsub('_','-')}' }.merge(attrs))
        end
      METHOD
    end

    #@param name [String] The value for the name attribute
    #@param attrs [Hash] The attributes for the tag
    #@return [String] HTML input tag with type="checkbox"
    def checkbox(name, attrs={})
      input(:checkbox, { type: 'checkbox', value: 'true', checked: !!object.try(name) }.merge(attrs))
    end

    #@param name [String] The value for the name attribute
    #@param attrs [Hash] The attributes for the tag
    #@return [String] HTML input tag with type="radio"
    def radio(name, attrs={})
      input(:radio, { type: 'radio', checked: (attrs.has_key?(:value) && attrs[:value].to_s == object.try(name).to_s) }.merge(attrs))
    end

    def select(name, attrs={}, &body)
      attrs = attrs.dup
      if name.is_a?(Hash)
        name = nil
        attrs = name
      end

      selected = attrs[:selected]
      if name
        new_attrs = { name: name }

        selected ||= object.try(name) if object

        unless attrs.has_key?(:id) && !attrs[:id]
          attrs = attrs.merge(id: name)
        end

        attrs = new_attrs.merge(attrs)
      end

      if options = attrs.delete(:options)
        content = "\n".html_safe
        options.each do |o|
          if o.is_a?(Array)
            text = o.first
            value = o.last
          else
            text = o
            value = o
          end
          content << option(text, value: value, selected: (!selected.nil? && value.to_s == selected.to_s))
          content << "\n"
        end
      end

      content_tag(:select, content, attrs, &body)
    end

    def textarea(name, attrs={}, &body)
      content_tag(:textarea, object.try(name), attrs, &body)
    end

    def button(content=nil, attrs={}, &body)
      content_tag(:button, content, attrs, &body)
    end

    def submit(content=nil, attrs={}, &body)
      button(content, { type: 'submit' }.merge(attrs), &body)
    end

  end
end
