module Curtain
  class NamedRoutesNotSet < RuntimeError; end
  class UnknownNamedRoute < RuntimeError; end

  module UrlHelpers
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
    end

    def self.included(cls)
      cls.extend(ClassMethods)
    end

    #
    #
    # @param [String, Symbol] route
    #   If this is a String, this will just use the same value in the path.
    #   If this is a Symbol, the path will be looked up in the named_routes
    # @param [Hash] options
    # @option options [String] :params
    #   A hash of parameters to include in the query string
    # @return [String] The URL
    def url(route, options={})
      options ||= {}
    end

    #
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
