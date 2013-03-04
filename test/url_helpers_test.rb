require 'test_helper'

class UrlHelpersTest < Test::Unit::TestCase

  class TestView < Curtain::View
    named_routes :home => "/home",
                 :profile => "/profiles/:id",
                 :post => "/:year/:month/:day/:slug"
  end

  def setup
    @view = TestView.new
  end

  def test_path_with_named_route
    assert_equal "/home", @view.path(:home)
  end

  def test_path_with_named_route_with_params
    assert_equal "/home?q=foo", @view.path(:home, :q => "foo")
  end

  def test_path_with_named_route_with_route_params
    assert_equal "/profiles/42", @view.path(:profile, :id => 42)
  end

  def test_path_with_named_route_with_multiple_route_params
    assert_equal "/2012/10/19/first-post",
      @view.path(:post,
                :year => 2012,
                :month => 10,
                :day => 19,
                :slug => "first-post")
  end

  def test_path_with_named_route_with_multiple_route_params_and_query_params
    assert_equal "/2012/10/19/first-post?tag=foo",
      @view.path(:post,
                :year => 2012,
                :month => 10,
                :day => 19,
                :slug => "first-post",
                :tag => "foo")
  end
end
