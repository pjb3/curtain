module Curtain

  class TemplateNotFound < RuntimeError; end

  module Templating
    module ClassMethods

      def default_template_directories
        [Dir.pwd]
      end

      def template_directories(*args)
        if args.empty?
          if defined? @template_directories
            @template_directories
          elsif superclass.respond_to?(:template_directories)
            superclass.template_directories
          else
            @template_directories ||= default_template_directories
          end
        else
          self.template_directories = args
        end
      end

      def template_directories=(directories)
        @template_directories = Array(directories).map{|d| File.expand_path(d) }.uniq
      end

      def find_template(name)
        # Try exact match in each directory first
        template_directories.each do |dir|
          if file = Dir[File.join(dir.to_s, name.to_s)].first
            return file
          end
        end

        # Try wildcard matches in each directory
        template_directories.each do |dir|
          if file = Dir[File.join(dir, "#{name}.*")].first
            return file
          end
        end

        raise TemplateNotFound.new("Could not find a template matching '#{name}' in #{Array(template_directories).map{|d| File.expand_path(d) }}")
      end

      def template(*args)
        if args.empty?
          @template ||= name.underscore.sub(/_view$/,'')
        else
          @template = args.first
        end
      end

      def template=(template)
        @template = template
      end
    end

    def self.included(cls)
      cls.extend(ClassMethods)
    end

  end
end
