require 'test_helper'

class CurtainTest < Test::Unit::TestCase

  # Using the top-level to test default template name behavior
  class ::TestView < Curtain::View
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

end
