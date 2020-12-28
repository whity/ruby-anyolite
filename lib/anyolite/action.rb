# frozen_string_literal: true

require_relative 'context'

class Anyolite
  module Action
    module ClassMethods
      def use(middleware, **options)
        _middleware.unshift({ klass: middleware, options: options })
        self
      end

      def middleware
        _middleware.dup
      end

      protected

      def _middleware
        @middleware ||= []
      end
    end

    def self.included(other)
      other.extend(ClassMethods)
    end

    def call(env)
      context = env['stack.context']
      app     = Runner.new(self)

      self.class.middleware.each do |mdl|
        middleware = mdl[:klass].new(app, **mdl[:options])
        app        = Runner.new(middleware)
      end

      app.call!(context)
      app = nil

      context.res.finish
    end
  end

  class Runner
    def initialize(app)
      @app = app
    end

    def call!(ctx)
      catch :halt do
        @app.call!(ctx)
      end
    rescue StandardError => e
      ctx.error = e
    end
  end

  class Callable
    include Action

    def initialize(app)
      @app = app
    end

    def call!(ctx)
      return @app.call(ctx) if @app.is_a?(Proc)

      @app.new.call!(ctx)
    end
  end
end
