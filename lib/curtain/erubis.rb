require 'erubis'
require 'curtain/output_buffer'

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
