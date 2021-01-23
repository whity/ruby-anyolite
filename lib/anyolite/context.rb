# frozen_string_literal: true

class Anyolite
  class Context
    attr_reader :req, :res, :error

    def initialize(env, **options)
      @req      = Request.new(env)
      @res      = Response.new
      @options  = options
      @error    = nil
      @data     = {}
      @rendered = false
    end

    def halt(code, message = nil)
      message ||= Http::Status.message_for(code)
      render_text(message, status: code)
      throw :halt
    end

    def redirect_to(url, status: 302)
      @res.headers['Location'] = ::String.new(url)
      halt(status)
    end

    def params
      @req.env['router.params'].dup
    end

    def render(data, type: :template, **options)
      begin
        self[:__in_render__] ||= 0
        self[:__in_render__] += 1
        self[:__in_render_shared__] ||= {}

        result = Renderer.send(type.to_sym, self, data, **options)
      ensure
        self[:__in_render__] -= 1
      end

      # if already inside the template, return the rendered string.
      return result[:body] if self[:__in_render__].positive?

      delete(:__in_render_shared__)

      @rendered   = true
      @res.status = options[:status] || 200
      @res.body   = result[:body]

      @res.set_header('Content-Type', result[:content_type])

      true
    end

    def config
      @options.dup
    end

    def error=(error)
      @error = error
      render_text("#{error}\n#{error.backtrace.join("\n")}", status: 500)
    end

    def []=(key, value)
      @data[key] = value
    end

    def [](key)
      @data[key]
    end

    def delete(key)
      @data.delete(key)
    end

    def rendered?
      @rendered
    end

    def session
      # TODO: if the env does not have the session hash,
      #   raise as method not defined
    end
  end
end

require_relative 'request'
require_relative 'response'
require_relative 'http/status'
require_relative 'renderer/template'
require_relative 'renderer/json'
require_relative 'renderer/text'
