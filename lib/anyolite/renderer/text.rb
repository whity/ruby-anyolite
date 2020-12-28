# frozen_string_literal: true

require 'json'
require_relative '../context'

class Anyolite
  module Renderer
    class << self
      def text(_ctx, data, **)
        {
          body:         [data.nil? ? '' : data],
          content_type: 'text/plain',
        }
      end
    end
  end

  class Context
    def render_text(data, **options)
      render(data, type: :text, **options)
    end
  end
end
