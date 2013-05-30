require 'tilt'

module Curtain

  class MustacheRenderer < ::Mustache
    def initialize(view, template_file)
      @view = view
      @template_file = template_file
    end

    def respond_to?(method_name)
      super || @view.respond_to?(method_name)
    end

    def method_missing(name, *args, &block)
      if @view.respond_to?(name)
        @view.send(name, *args, &block)
      else
        super
      end
    end
  end

  module Rendering
    # Renders the template
    #
    # @example Render the default template
    #   view.render
    #
    # @example Render the foo template
    #   view.render "foo.erb"
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

      # Apparently Tilt doesn't support mustache?
      # TODO: There has to be an implementation out there,
      # if not, write one
      if ext == 'mustache'
        mustache = MustacheRenderer.new(self, template_file)
        mustache.render
      else
        template = Tilt.new(template_file)
        template.render(self, variables.merge(locals))
      end
    end
  end
end
