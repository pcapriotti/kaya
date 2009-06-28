require 'test/unit'
require 'plugins/loader'

class TestEngineLoader < Test::Unit::TestCase
  def setup
    @ploader = PluginLoader.new
    @loader = @ploader.get_matching(:engine_loader).new
  end
  
  def test_protocol_list
    assert_equal ['GNUShogi', 'XBoard'],
      @ploader.get_all_matching(:engine).
               map {|klass| klass.data(:protocol) }.
               uniq.sort
  end
end
