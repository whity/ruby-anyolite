require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'anyolite'

class TemplateContentForTest < Minitest::Test
  include Rack::Test::Methods

  attr_reader :app

  def setup
    @app = Anyolite.new(
      templates: "#{__dir__}/templates",
    )

    app.get(
      '/content-for',
      to: lambda { |ctx|
        ctx.render_template('content_for', layout: 'layout_content_for')
      }
    )

    app.get(
      '/content-for-default',
      to: lambda { |ctx|
        ctx.render_template('content_for_default', layout: 'layout_content_for')
      }
    )
  end

  def test_render_template_content_for
    get('/content-for')
    assert_equal(
      "header\ntest content_for\ncontent_for template\nfooter",
      last_response.body,
    )
  end

  def test_render_template_content_for_default
    get('/content-for-default')
    assert_equal(
      "header\ntest content_for default\ntemplate\nfooter",
      last_response.body,
    )
  end
end
