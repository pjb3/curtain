require 'erubis'
require 'active_support/core_ext/string/output_safety'

template = %{<html>
  <body>
    <%= content_tag :div do %>
      <h1>Hello</h1>
      <%= title %>
    <% end %>
  </body>
</html>}

class OutputBuffer < ActiveSupport::SafeBuffer
  def <<(value)
    super(value.to_s)
  end
  alias :append= :<<
  alias :safe_append= :<<
  alias :safe_contact :<<
end

class MyErubis < ::Erubis::Eruby
  def add_preamble(src)
    src << "@output_buffer = output_buffer;"
  end

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

class View
  def content_tag(name, &body)
    orig_buffer = @output_buffer
    temp_buffer = OutputBuffer.new
    @output_buffer = temp_buffer
    body.call
    @output_buffer = orig_buffer
    "<#{name}>#{temp_buffer}</#{name}>\n".html_safe
  end

  def title
    "Pauls' < Stuff"
  end

  def output_buffer
    @output_buffer ||= OutputBuffer.new
  end
end

erb = MyErubis.new(template)
puts erb.src

puts "---"

puts erb.evaluate(View.new)
