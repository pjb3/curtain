require 'tilt'
require 'temple'

module Curtain

  module Rendering
    # Renders the template
    #
    # @example Render the default template
    #   view.render
    #
    # @example Render the foo template
    #   view.render "foo.slim"
    #
    # @example You can use symbols and omit the extension
    #   view.render :foo
    #
    # @example You can specify what the local variables for the template should be
    #   view.render :foo, :bar => "baz"
    #
    # @example You can use the default template an specify locals
    #   view.render :bar => "baz"
    #
    # @param [String, Symbol] name The name of the template.
    #   The extension can be omitted.
    #   This parameter can be omiitted and the default template will be used.
    # @param [Hash] locals
    # @return [String] The result of rendering the template
    # @see #default_template_name
    def render(*args)
      name = if args.length == 0 || args.first.is_a?(Hash)
        self.class.template
      else
        args.first.to_s
      end

      locals = args.last.is_a?(Hash) ? args.last : {}

      # TODO: Cache Template objects
      template_file = self.class.find_template(name)
      ext = template_file.split('.').last

      orig_buffer = @output_buffer
      @output_buffer = Curtain::OutputBuffer.new
      case ext
      when 'slim'
        template = ::Slim::Template.new(template_file, :buffer => '@output_buffer', :use_html_safe => true, :disable_capture => true, :generator => Temple::Generators::RailsOutputBuffer )
      when 'erb'
        template = ::Curtain::ErubisTemplate.new(template_file, :buffer => '@output_buffer', :use_html_safe => true, :disable_capture => true, :generator => Temple::Generators::RailsOutputBuffer )
      else
        raise "Curtain cannot process .#{ext} templates"
      end
      template.render(self, variables.merge(locals))
      @output_buffer
    ensure
      @output_buffer = orig_buffer
    end
  end
end
