module Curtain
  module HTMLHelpers
    def capture
      original_buffer = @output_buffer
      @output_buffer = Curtain::OutputBuffer.new
      yield
    ensure
      @output_buffer = original_buffer
    end

    # Generates a tag that has no content.
    #
    # @example Tag with no attributes
    #   view.void_tag(:br) # => "<br>"
    #
    # @example Tag with attributes
    #   view.void_tag(:img, src: "/logo.png") # => '<img src="/logo.png">'
    #
    # @param name [Symbol, String] The name of the tag
    # @param attrs [Hash] The attributes of the tag
    #
    # @return [String] The HTML tag
    #
    def void_tag(name, attrs={})
      tag_opening(name, attrs) << ">".html_safe
    end

    # Generates a with opening and closing tags and potentially content.
    #
    # @example Tag with no attributes, no content
    #   content_tag(:p) # => "<p></p>"
    #
    # @example Tag with content
    #   content_tag(:p, "Hello") # => "<p>Hello</p>"
    #
    # @example Tag with block content
    #   content_tag(:p) { "Hello" } # => "<p>Hello</p>"
    #
    # @example Tag with content and attributes
    #   content_tag(:a, "Log In", href: "/log_in") # => "<a href="/log_in">Log In</a>"
    #
    # @example Tag with content block and attributes
    #   content_tag(:a, href: "/log_in") { "Log In" } # => "<a href="/log_in">Log In</a>"
    #
    # @param name [Symbol, String] The name of the tag
    # @param attrs [Hash] The attributes of the tag
    #
    # @return [String] The HTML tag
    #
    def content_tag(name, content=nil, attrs={}, &body)
      if content.is_a?(Hash)
        attrs = content
        content = nil
      end

      if block_given?
        content = capture(&body)
      end

      tag = tag_opening(name, attrs)
      tag << ">".html_safe
      tag << content
      tag << "</#{name}>".html_safe
    end

    # Tags

    # @!method br(attrs={})
    #   @param attrs [Hash] The attributes
    #   @return [String] HTML br tag
    # @!method hr(attrs={})
    # @!method img(attrs={})
    VOID_TAGS = [
      :br,
      :hr,
      :img
    ].each do |tag|
      class_eval %{
        def #{tag}(attrs={})
          void_tag(#{tag.inspect}, attrs)
        end
      }
    end

    # @!method a(content=nil, attrs={}, &body)
    #   @return [String] HTML a tag
    # @!method b(content=nil, attrs={}, &body)
    #   @return [String] HTML b tag
    # @!method dd(content=nil, attrs={}, &body)
    #   @return [String] HTML dd tag
    # @!method div(content=nil, attrs={}, &body)
    #   @return [String] HTML div tag
    # @!method dl(content=nil, attrs={}, &body)
    #   @return [String] HTML dl tag
    # @!method dt(content=nil, attrs={}, &body)
    #   @return [String] HTML dt tag
    # @!method h1(content=nil, attrs={}, &body)
    #   @return [String] HTML h1 tag
    # @!method h2(content=nil, attrs={}, &body)
    #   @return [String] HTML h2 tag
    # @!method h3(content=nil, attrs={}, &body)
    #   @return [String] HTML h3 tag
    # @!method h4(content=nil, attrs={}, &body)
    #   @return [String] HTML h4 tag
    # @!method h5(content=nil, attrs={}, &body)
    #   @return [String] HTML h5 tag
    # @!method h6(content=nil, attrs={}, &body)
    #   @return [String] HTML h6 tag
    # @!method i(content=nil, attrs={}, &body)
    #   @return [String] HTML i tag
    # @!method p(content=nil, attrs={}, &body)
    #   @return [String] HTML p tag
    # @!method table(content=nil, attrs={}, &body)
    #   @return [String] HTML table tag
    # @!method tbody(content=nil, attrs={}, &body)
    #   @return [String] HTML tbody tag
    # @!method td(content=nil, attrs={}, &body)
    #   @return [String] HTML td tag
    # @!method tfoot(content=nil, attrs={}, &body)
    #   @return [String] HTML tfoot tag
    # @!method th(content=nil, attrs={}, &body)
    #   @return [String] HTML th tag
    # @!method thead(content=nil, attrs={}, &body)
    #   @return [String] HTML thead tag
    # @!method tr(content=nil, attrs={}, &body)
    #   @return [String] HTML tr tag#
    CONTENT_TAGS = [
      :a,
      :b,
      :dd,
      :div,
      :dl,
      :dt,
      :h1,
      :h2,
      :h3,
      :h4,
      :h5,
      :h6,
      :i,
      :p,
      :table,
      :tbody,
      :td,
      :tfoot,
      :th,
      :thead,
      :tr
    ].each do |tag|
      class_eval %{
        def #{tag}(content=nil, attrs={}, &body)
          content_tag(#{tag.inspect}, content, attrs, &body)
        end
      }
    end

    private
    def tag_opening(name, attrs={})
      tag = "<#{name}".html_safe

      if attrs
        attrs.each do |name, value|
          tag << %{ #{name}="}.html_safe
          tag << value
          tag << '"'.html_safe
        end
      end

      tag
    end
  end
end
