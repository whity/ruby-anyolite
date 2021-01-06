require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'anyolite'

class Action
  include Anyolite::Action

  def call!(ctx)
    ctx.render_text('action class')
  end
end

class ActionWithMiddleware
  include Anyolite::Action

  class Middleware
    def initialize(app, **options)
      @app = app
    end

    def call!(ctx)
      @app.call!(ctx)

      ctx.render_text(ctx.res.body.upcase)
    end
  end

  use(Middleware)

  def call!(ctx)
    ctx.render_text('action class with middleware')
  end
end

class ActionTest < Minitest::Test
  include Rack::Test::Methods

  attr_reader :app

  def setup
    @app = Anyolite.new

    app.get('/string', to: lambda { |ctx| ctx.render_text('lambda action') })
    app.get('/class_name', to: 'Action')
    app.get('/class_with_middleware', to: ActionWithMiddleware)
  end

  def test_action_block
    get('/string')
    assert_equal('lambda action', last_response.body)
  end

  def test_action_class_name
    get('/class_name')
    assert_equal('action class', last_response.body)
  end

  def test_action_class_with_middleware
    get('/class_with_middleware')
    assert_equal('ACTION CLASS WITH MIDDLEWARE', last_response.body)
  end
end
