# frozen_string_literal: true

require_relative '../context'

class Anyolite
  module Middleware
    class Context
      def initialize(app, **options)
        @app     = app
        @options = options
      end

      def call(env)
        result = nil

        begin
          klass                = @options[:class] || Anyolite::Context
          env['stack.context'] = klass.new(env, **@options)
          result               = @app.call(env)
        ensure
          env.delete('stack.context')
        end

        result
      end
    end
  end
end
