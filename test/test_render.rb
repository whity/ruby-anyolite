require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'anyolite'

class RenderTest < Minitest::Test
  include Rack::Test::Methods

  attr_reader :app

  def setup
    @app = Anyolite.new(
      templates: "#{__dir__}/templates",
    )

    app.get(
      '/simple',
      to: lambda { |ctx|
        ctx.render_template('simple', locals: {name: 'world'})
      },
    )

    app.get(
      '/inline',
      to: lambda { |ctx|
        ctx.render_template_inline('hello <%= name %>', locals: {name: 'world'})
      },
    )

    app.get(
      '/with-partials',
      to: lambda { |ctx|
        ctx.render_template('with_partials', locals: {name: 'world'})
      },
    )

    app.get(
      '/with-layout',
      to: lambda { |ctx|
        ctx.render_template('simple', layout: 'layout', locals: {name: 'world'})
      }
    )
  end

  def test_render_template_simple
    get('/simple')
    assert_equal("hello world", last_response.body)
  end

  def test_render_template_inline
    get('/inline')
    assert_equal("hello world", last_response.body)
  end

  def test_render_template_with_partials
    get('/with-partials')
    assert_equal("hello WORLD", last_response.body)
  end

  def test_render_template_with_layout
    get('/with-layout')
    assert_equal("header\nhello world\nfooter", last_response.body)
  end
end
