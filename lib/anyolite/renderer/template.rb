# frozen_string_literal: true

require 'erb'

class Anyolite
  module Renderer
    class TemplateNotFoundError < ::StandardError
    end

    class ERB < ::ERB
      class Data
        def initialize(**kwargs)
          @data = kwargs
        end

        def binding # rubocop:disable Lint/UselessMethodDefinition
          super
        end

        def method_missing(name, *)
          @data[name]
        end

        def respond_to_missing?(name, *)
          @data.key?(name)
        end
      end

      def result(**kwargs)
        data = Data.new(**kwargs)
        super(data.binding)
      end
    end

    class << self
      def template(ctx, template, **options)
        template_file = "#{ctx.config[:templates]}/#{template}.html.erb"
        content       = File.read(template_file)
        locals        = options[:locals] || {}
        locals[:c]    = ctx
        body          = ERB.new(content).result(**locals)

        # clean trailing spaces
        body = body.gsub(/(^\s*|\s*$)/, '')

        {
          body:         body,
          content_type: 'text/html',
        }
      end
    end
  end

  class Context
    def render_template(data, **options)
      render(data, type: :template, **options)
    end
  end
end
