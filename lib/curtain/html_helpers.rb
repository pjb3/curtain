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

      body = if block
        capture(&block)
      else
        attributes_or_body.to_s
      end
      result << body

      result << "</#{name}>"

      result
    end
  end
end
