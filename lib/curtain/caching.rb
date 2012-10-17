module Curtain
  class CacheNotSet < RuntimeError; end

  module Caching
    module ClassMethods
      def cache
        if defined? @cache
          @cache
        elsif superclass.respond_to?(:cache)
          superclass.cache
        end
      end

      def cache=(cache)
        @cache = cache
      end
    end

    def self.included(cls)
      cls.extend(ClassMethods)
    end

    def cache(key, ttl=nil, &block)
      if self.class.cache
        unless value = self.class.cache.get(key)
          value = capture(&block)
          self.class.cache.set(key, value, ttl)
        end
        concat(value)
      else
        raise CacheNotSet.new("Cache not set, set it with Curtain.cache = Cache.new")
      end
    end
  end
end
