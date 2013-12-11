require 'test_helper'

class BasicTest < Curtain::TestCase

  # Using the top-level to test default template name behavior
  class ::TestView < Curtain::View
    attr_accessor :name

    def shout(s)
      s.upcase
    end
  end

  class SubdirView < Curtain::View
    template :index
  end

  def use(lang)
    TestView.template_directories = File.join(File.dirname(__FILE__), "examples", "basic", lang)

    SubdirView.template_directories = [
      File.join(File.dirname(__FILE__), "examples", "basic", lang, "subdir"),
      File.join(File.dirname(__FILE__), "examples", "basic", lang)
    ]
  end

  %w[erb slim].each do |lang|
    test "render default with #{lang}" do
      use lang
      view = TestView.new
      assert_equal "<h1>TEST</h1>", strip_lines(view.render)
    end

    test "render default with locals with #{lang}" do
      use lang
      view = TestView.new
      assert_equal "<h1>TEST</h1><p>Hello, World!</p>", strip_lines(view.render(:msg => "Hello, World!"))
    end

    test "render template with #{lang}" do
      use lang
      view = TestView.new
      assert_equal "<h1>default</h1>", strip_lines(view.render(:index))
    end

    test "render template with locals with #{lang}" do
      use lang
      view = TestView.new
      assert_equal "<h1>Hello, World!</h1>", strip_lines(view.render(:index, :msg => "Hello, World!"))
    end

    test "variables and render within template with #{lang}" do
      use lang
      view = TestView.new
      view[:msg] = "Hello, World!"
      assert_equal "<html><body><h1>Hello, World!</h1></body></html>", strip_lines(view.render("layout", :main => "body"))
    end

    test "render multiple template directories with #{lang}" do
      use lang
      view = SubdirView.new
      assert_equal "<h1>Subdir</h1>", strip_lines(view.render)
    end
  end

end
