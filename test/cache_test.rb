require 'test_helper'

class CacheTest < Curtain::TestCase
  class ::CacheView < Curtain::View
  end

  def use(lang)
    CacheView.template_directories File.join(File.dirname(__FILE__), "examples", "cache", lang)
  end

  %w[erb slim].each do |lang|
    test "cache with #{lang}" do
      use lang
      assert_equal %{<h1>Test</h1>}, strip_lines(CacheView.render)
    end
  end
end
