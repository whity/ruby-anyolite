# frozen_string_literal: true

require 'erb'

class Anyolite
  module Renderer
    class TemplateNotFoundError < ::StandardError
    end

    class ERB < ::ERB
      class Context
        def initialize(**kwargs)
          @data = kwargs
        end

        def render(template, **kwargs)
          c.render(template, type: :template, locals: kwargs)
        end

        def get_binding
          binding
        end

        def method_missing(name, *)
          @data[name]
        end

        def respond_to_missing?(name, *)
          @data.key?(name)
        end
      end

      def result(**kwargs, &block)
        context = Context.new(**kwargs)
        super(context.get_binding(&block))
      end
    end

    class << self
      def template(ctx, template, **options)
        options[:layout] ||= ctx.config[:layout]
        options.delete(:layout) if ctx[:__in_render__] > 1

        locals     = options[:locals] || {}
        locals[:c] = ctx

        # render template
        main = _read_template(ctx, template)
        main = ERB.new(main).result(**locals)

        # clean trailing spaces
        main = main.gsub(/(^\s*|\s*$)/, '')

        result = {
          body:         main,
          content_type: 'text/html',
        }

        return result if !options[:layout]

        layout = _read_template(ctx, options[:layout])
        layout = ERB.new(layout).result(**locals) { main }

        # clean trailing spaces
        layout = layout.gsub(/(^\s*|\s*$)/, '')

        {
          body:         layout,
          content_type: 'text/html',
        }
      end

      protected

      def _read_template(ctx, name)
        template_file = "#{ctx.config[:templates]}/#{name}.html.erb"
        File.read(template_file)
      end
    end
  end

  class Context
    def render_template(data, **options)
      render(data, type: :template, **options)
    end
  end
end
