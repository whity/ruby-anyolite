# frozen_string_literal: true

require 'rack/utils'

class Anyolite
  module Http
    class Status
      ALL = ::Rack::Utils::HTTP_STATUS_CODES.dup.merge({
        103 => %q[Checkpoint],
        122 => %q[Request-URI too long],
        413 => %q[Payload Too Large],
        414 => %q[URI Too Long],
        416 => %q[Range Not Satisfiable],
        418 => %q[I'm a teapot],
        420 => %q[Enhance Your Calm],
        444 => %q[No Response],
        449 => %q[Retry With],
        450 => %q[Blocked by Windows Parental Controls],
        451 => %q[Wrong Exchange server],
        499 => %q[Client Closed Request],
        506 => %q[Variant Also Negotiates],
        598 => %q[Network read timeout error],
        599 => %q[Network connect timeout error],
      }).freeze

      class << self
        def for_code(code)
          ALL.assoc(code)
        end

        def message_for(code)
          ALL[code]
        end
      end
    end
  end
end
