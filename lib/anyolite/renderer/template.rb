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
      def template(ctx, template, **options, &block)
        options[:layout] ||= ctx.config[:layout]
        options.delete(:layout) if ctx[:__in_render__] > 1

        locals     = options[:locals] || {}
        locals[:c] = ctx

        # render template
        template_file = "#{ctx.config[:templates]}/#{template}.html.erb"
        content       = File.read(template_file)
        content       = ERB.new(content).result(**locals, &block)

        # clean trailing spaces
        content = content.gsub(/(^\s*|\s*$)/, '')

        result = {
          body:         content,
          content_type: 'text/html',
        }

        return result if !options[:layout]

        layout = options.delete(:layout)
        template(ctx, layout, options) { main }
      end
    end
  end

  class Context
    def render_template(data, **options)
      render(data, type: :template, **options)
    end
  end
end
