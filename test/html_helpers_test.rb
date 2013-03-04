require 'test_helper'

class HTMLHelpersTest < Test::Unit::TestCase
  include Curtain::BlockHelpers
  include Curtain::HTMLHelpers

  def test_content_tag_no_body
    assert_equal "<p></p>", content_tag(:p)
  end

  def test_content_tag_body
    assert_equal "<p>foo</p>", content_tag(:p, "foo")
  end

  def test_content_tag_body_attributes
    assert_equal %{<p bar="baz">foo</p>}, content_tag(:p, "foo", :bar => "baz")
  end

  def test_content_tag_no_body_attributes
    assert_equal %{<p bar="baz"></p>}, content_tag(:p, :bar => "baz")
  end

  def test_content_tag_block_body_attributes
    assert_equal(%{<p>foo</p>}, content_tag(:p){ "foo" })
  end
end
