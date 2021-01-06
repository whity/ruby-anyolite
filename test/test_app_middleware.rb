require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'anyolite'

class AppMiddlewareTest < Minitest::Test
  include Rack::Test::Methods

  attr_reader :app

  def setup
    @app = Anyolite.new
    @app.get(
      '/',
      to: lambda { |ctx|
        ctx.render_text('index')
      }
    )
  end

  def test_app_middleware
    middleware = Class.new do
      def initialize(app, options = {})
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        body = body.map(&:upcase)

        [status, headers, body]
      end
    end

    app.use(middleware)

    get('/')

    assert_equal(last_response.body, 'INDEX')
  end
end
