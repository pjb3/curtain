require 'cgi'

module Curtain
  module HTMLHelpers
    def h(html)
      CGI::escapeHTML(html)
    end

    def content_tag(name, attributes_or_body=nil, attributes=nil, &block)
      result = "<#{name}"

      if attributes_or_body.is_a?(Hash)
        attributes = attributes_or_body
      end

      if attributes
        result << " #{attributes.map{|k,v| %{#{k}="#{h(v)}"} }.join(' ')}>"
      else
        result << ">"
      end

      if block
        result << capture(&block)
      elsif !attributes_or_body.is_a?(Hash)
        result << attributes_or_body.to_s
      end

      result << "</#{name}>"

      result
    end
  end
end
