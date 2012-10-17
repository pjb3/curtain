require 'test/unit'
require 'slim'
require 'curtain'

class TestView < Curtain::View
  self.template_directories = File.join(File.dirname(__FILE__), "examples")

  attr_accessor :name

  def shout(s)
    s.upcase
  end
end

class SubdirView < Curtain::View
  template :index
end

SubdirView.template_directories = [File.join(File.dirname(__FILE__), "examples", "subdir")] + Curtain::View.template_directories

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

class CacheView < TestView; end
CacheView.cache = TestCache.new

class CurtainTest < Test::Unit::TestCase

  def setup
    CacheView.cache.flush
  end

  def test_render_default
    view = TestView.new
    assert_equal "<h1>TEST</h1>\n", view.render
  end

  def test_render_default_with_locals
    view = TestView.new
    assert_equal "<h1>TEST</h1>\n  <p>Hello, World!</p>\n", view.render(:msg => "Hello, World!")
  end

  def test_render_template
    view = TestView.new
    assert_equal "<h1>default</h1>\n", view.render(:index)
  end

  def test_render_template_with_locals
    view = TestView.new
    assert_equal "<h1>Hello, World!</h1>\n", view.render(:index, :msg => "Hello, World!")
  end

  def test_render_multiple_template_directories
    view = SubdirView.new
    assert_equal "<h1>Subdir</h1>\n", view.render
  end

  def test_variables_and_render_within_template
    view = TestView.new
    view[:msg] = "Hello, World!"
    assert_equal "<html><body><h1>Hello, World!</h1>\n</body></html>\n", view.render("layout", :main => "body")
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
