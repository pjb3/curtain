module Curtain
  class NamedRoutesNotSet < RuntimeError; end
  class UnknownNamedRoute < RuntimeError; end

  module UrlHelpers

    # When a class includes {Curtain::UrlHelpers}, that class also extends
    # this module, which makes these methods class methods on the class.
    # These methods act as class-level attributes that accept
    # a value at any level of a class hierarchy,
    # using the value set on the specific class if it has one,
    # otherwise it delegates it's way up the inheritance chain.
    # The general pattern of these methods is that the getter accepts an
    # option argument, which sets the value of the attribute.
    # This style supports a natural DSL-like way of defining the
    # values for the attribute definition in the class definition
    #
    # @example
    #   class MyView
    #     include Curtain::UrlHelpers
    #     default_host "example.com"
    #   end
    #
    module ClassMethods

      def named_routes(*args)
        if args.empty?
          if defined? @named_routes
            @named_routes
          elsif superclass.respond_to?(:named_routes)
            superclass.named_routes
          end
        else
          self.named_routes = args.first
        end
      end

      def named_routes=(named_routes)
        @named_routes = named_routes
      end

      def default_host(*args)
        if args.empty?
          if defined? @default_host
            @default_host
          elsif superclass.respond_to?(:default_host)
            superclass.default_host
          end
        else
          self.default_host = args.first
        end
      end

      def default_host=(default_host)
        @default_host = default_host
      end

      def default_port(*args)
        if args.empty?
          if defined? @default_port
            @default_port
          elsif superclass.respond_to?(:default_port)
            superclass.default_port
          end
        else
          self.default_port = args.first
        end
      end

      def default_port=(default_port)
        @default_port = default_port
      end
    end

    def self.included(cls)
      cls.extend(ClassMethods)
    end

    # Generates a URL
    #
    # @param [String, Symbol] route
    #   If this is a String, this will just use the same value in the path.
    #   If this is a Symbol, the path will be looked up in the named_routes
    # @param [Hash] options
    # @option options [String] :scheme
    #   The scheme to use for the URL, defaults to 'http'
    # @option options [String] :host
    #   The host to use for the URL, uses the class-level attribute
    #   {Curtain::UrlHelpers::ClassMethods#default_host} as the default
    # @option options [String] :port
    #   The port to use for the URL, uses the class-level attribute
    #   {Curtain::UrlHelpers::ClassMethods#default_host} as the default.
    #   The port is omitted if the scheme is 'http' and the port is 80
    #   or if the scheme is 'https' and the port is 443
    # @option options [String] :fragment
    #   Sets the fragment portion of the URL, also known as the anchor
    # @option options [String] :params
    #   A hash of parameters to include in the query string
    # @return [String] The URL
    # @example
    #   url("/posts",
    #     :scheme => 'http',
    #     :host => 'foo.com',
    #     :params => { :id => 30, :limit => 5 },
    #     :fragment => "time=1305298413")
    #   # => "http://foo.com/posts?id=30&limit=5#time=1305298413"
    def url(route, options={})
      options ||= {}
    end

    # Generates a relative path
    #
    # @param [String, Symbol] route
    #   If this is a String, this will just use the same value in the path.
    #   If this is a Symbol, the path will be looked up in the named_routes
    def path(route, params={})
      params ||= {}

      path = case route
      when String then route.dup
      when Symbol
        if self.class.named_routes
          if p = self.class.named_routes[route]
            p.dup
          else
            raise UnknownNamedRoute.new("Could not find named route for #{route.inspect}")
          end
        else
          raise NamedRoutesNotSet.new("You must setup the named routes like 'Curtain::View.named_routes = {}'")
        end
      end

      # You are going to need this, this is how you interpolate a params into a route
      # and get back a subset of params that didn't match a route param
      query_params = params.inject({}) do |acc,(k,v)|
        unless path.sub!(/:#{k.to_param}(\/|\?|#|\Z)/,"#{v.to_param}\\1")
          acc[k] = v
        end
        acc
      end

      if query_params.blank?
        path
      else
        "#{path}?#{query_params.to_query}"
      end
    end
  end
end
