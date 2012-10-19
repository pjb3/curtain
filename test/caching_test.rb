require 'test/unit'
require 'slim'
require 'curtain'

class CurtainTest < Test::Unit::TestCase

  class TestCache

    def initialize
      flush
    end

    def get(k, opts={})
      @store[k]
    end

    def set(k, v, ttl=nil, opts={})
      @store[k] = v
    end

    def flush
      @store = {}
    end

  end

  class CacheView < Curtain::View
    cache TestCache.new
    template_directories File.join(File.dirname(__FILE__), "examples")
    template :cache
  end

  def setup
    CacheView.cache.flush
  end

  def test_cache_erb
    view = CacheView.new
    assert_equal "  <h1>foo</h1>\n", view.render
    assert_equal "  <h1>foo</h1>\n", view.class.cache.get("foo")
  end

  def test_cache_haml
    view = CacheView.new
    assert_equal "<h1>foo</h1>\n\n", view.render("cache.haml")
    assert_equal "<h1>foo</h1>\n", view.class.cache.get("foo")
  end

  def test_cache_slim
    view = CacheView.new
    assert_equal "<h1>foo</h1>", view.render("cache.slim")
    assert_equal "<h1>foo</h1>", view.class.cache.get("foo")
  end
end
