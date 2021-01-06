require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'anyolite'

class MethodsTest < Minitest::Test
  include Rack::Test::Methods

  attr_reader :app

  def setup
    @app = Anyolite.new

    %i[get post put patch delete options trace].each do |verb|
      @app.send(
        verb,
        "/#{verb}",
        to: lambda { |ctx| ctx.render_text("method #{verb}")},
      )
    end
  end

  %i[get post put patch delete options trace].each do |verb|
    define_method("test_method_#{verb.to_s.upcase}") do |*args|
      self.send(verb, "/#{verb}")

      assert_equal(200, last_response.status)
      assert_equal("method #{verb}", last_response.body)
    end
  end

  def trace(uri, params = {}, env = {}, &block)
    custom_request('TRACE', uri, params, env, &block)
  end
end
