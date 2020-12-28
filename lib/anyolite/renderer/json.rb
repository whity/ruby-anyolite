# frozen_string_literal: true

require 'json'
require_relative '../context'

class Anyolite
  module Renderer
    class << self
      def json(_ctx, data, **)
        {
          body:         [data.to_json],
          content_type: 'application/json',
        }
      end
    end
  end

  class Context
    def render_json(data, **options)
      render(data, type: :json, **options)
    end
  end
end
