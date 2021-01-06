require 'bundler/setup'
require 'minitest/autorun'
require 'anyolite'

class LoadTest < Minitest::Test
  def test_that_loads
    assert(Kernel.const_get(:Anyolite))
  end
end
