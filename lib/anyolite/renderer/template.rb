# frozen_string_literal: true

require 'erb'

class Anyolite
  module Renderer
    class TemplateNotFoundError < ::StandardError
    end

    class ERB < ::ERB
      class Context
        def initialize(**kwargs)
          @_out_buf = ''
          @data     = kwargs
        end

        def render(template, **kwargs)
          c.render(template, type: :template, locals: kwargs)
        end

        def content_for(key, value = nil, options = {}, &block)
          block ||= proc { |*| value }
          clear_content_for(key) if options[:flush]
          content_blocks[key.to_sym] ||= []
          content_blocks[key.to_sym].push(block)
        end

        def content_for?(key)
          content_blocks.key?(key.to_sym)
        end

        def content_blocks
          c[:__in_render_shared__][:__content_blocks__] ||= {}
          c[:__in_render_shared__][:__content_blocks__]
        end

        def clear_content_for(key)
          content_blocks.delete(key.to_sym)
        end

        def yield_content(key, *args, &block)
          return if !content_blocks.key?(key.to_sym) && !block

          if content_blocks.key?(key.to_sym)
            content_blocks[key.to_sym].each do |bl|
              bl.binding.eval('@_out_buf = ""')
              @_out_buf += bl.call(*args).to_s
              bl.call(*args).to_s
            end

            return nil
          end

          return if !block

          out_buf = @_out_buf
          block.binding.eval('@_out_buf = ""')
          @_out_buf = out_buf + block.call(*args)

          nil
        end

        def get_binding # rubocop:disable Naming/AccessorMethodName
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
        inline  = options.delete(:inline)
        content = template

        if !inline
          template_file = "#{ctx.config[:templates]}/#{template}.html.erb"
          content       = File.read(template_file)
        end

        content = ERB.new(
          content,
          eoutvar: '@_out_buf',
        ).result(**locals, &block)

        # clean trailing spaces
        content = content.gsub(/^\s*/, '')
        content = content.gsub(/\s*$/, '')

        result = {
          body:         content,
          content_type: 'text/html',
        }

        return result if !options[:layout]

        layout = options.delete(:layout)
        template(ctx, layout, options) { content }
      end
    end
  end

  class Context
    def render_template(data, **options)
      render(data, type: :template, **options)
    end

    def render_template_inline(data, **options)
      render_template(data, **options, inline: true)
    end
  end
end
