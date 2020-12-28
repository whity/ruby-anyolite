# frozen_string_literal: true

require 'hanami/router'
require 'rack/builder'

class Anyolite < Hanami::Router
  attr_reader :context

  def initialize(options = {}, &blk)
    @middleware = []
    @context    = {}

    if self.class.superclass != self.class
      options[:namespace] = self.class if options[:namespace].nil?
    end

    super(options, &blk)

    startup if respond_to?(:startup)

    define_singleton_method(:call) do |env|
      _app.call(env)
    end
  end

  def use(middleware, *options)
    @middleware.push({ klass: middleware, options: options })
    self
  end

  %i[get post put patch delete options trace].each do |verb|
    define_method(verb) do |path, **options|
      options[:to] = _wrap_action(options[:to])
      super(path, **options)
    end
  end

  protected

  def _wrap_action(to)
    return to if to.is_a?(::String)

    Callable.new(to)
  end

  def _app
    return @app if !@app.nil?

    router     = self.class.instance_method(:call).bind(self)
    context    = @context
    middleware = @middleware
    @app       = Rack::Builder.new do
      middleware.each do |item|
        use(item[:klass], *item[:options])
      end

      use(Middleware::Context, **context)

      run(router)
    end

    @app
  end
end

require_relative 'anyolite/action'
require_relative 'anyolite/middleware/context'
