require 'test_helper'

class HTMLTest < Curtain::TestCase
  class ::HTMLView < Curtain::View
  end

  def use(lang)
    HTMLView.template_directories File.join(File.dirname(__FILE__), "examples", "html", lang)
  end

  %w[erb slim].each do |lang|
    test "void tag with #{lang}" do
      use lang
      assert_equal '<br>', render(:void_tag)
    end

    test "void tag with attributes with #{lang}" do
      use lang
      assert_equal %{<img src="/logo.png" alt="Logo">}, render(:void_tag_with_attributes)
    end

    test "content tag with #{lang}" do
      use lang
      assert_equal %{<p></p>}, render(:content_tag)
    end
  end

  protected
  def render(*args)
    strip_lines(HTMLView.new.render(*args))
  end
end
