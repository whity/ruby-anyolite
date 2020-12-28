# frozen_string_literal: true

require 'erb'
require_relative '../context'

class Anyolite
  module Renderer
    class ERB < ::ERB
      class Data
        def initialize(**kwargs)
          # for each key in hash create a instance variable
          kwargs.each do |key, value|
            var_name = "@#{key}".to_sym
            instance_variable_set(var_name, value)
            self.class.send(:attr_reader, key)
          end
        end

        def binding
          super
        end
      end

      def result(**kwargs)
        data = Data.new(**kwargs)
        super(data.binding)
      end
    end

    class << self
      def template(ctx, template, **options)
        template_file = "#{ctx.config[:views]}/#{template}.html.erb"
        content       = File.read(template_file)

        locals     = options[:locals] || {}
        locals[:c] = ctx

        {
          body:         [ERB.new(content).result(**locals)],
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
