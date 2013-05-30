puts $:
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

  class Account
    attr_accessor :email, :password, :first_name, :last_name, :gender, :date_of_birth

    def initialize(attrs={})
      if attrs
        attrs.each do |attr, value|
          send("#{attr}=", value)
        end
      end
    end
  end

  class ::RegistrationView < TestView

    attr_accessor :account, :errors

    delegate :email, :first_name, :last_name, :gender, :date_of_birth, :to => :account

    def date_of_birth_day_options
      [{}] + (1..31).map do |day|
        { text: day, value: day, selected: day == date_of_birth.try(:day) }
      end
    end

    def date_of_birth_month_options
      Date::ABBR_MONTHNAMES.each_with_index.map do |month, i|
        { text: month, value: i > 0 ? 1 : nil, selected: i == date_of_birth.try(:month) ? 'selected' : nil }
      end
    end

    def date_of_birth_year_options
      [{}] + 13.years.ago.year.downto(113.years.ago.year).map do |year|
        { text: year, value: year, selected: year == date_of_birth.try(:year) ? 'selected' : nil }
      end
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

  def test_mustache_form
    expected = remove_whitespace(%{<h2>Register</h2>
<form action="/register">
  <label class="block">
    Email:
    <input type="type" name="email" value="mail@paulbarry.com" />
  </label>
  <label class="block">
    Password:
    <input type="password" name="password" />
  </label>
  <label class="block">
    First Name:
    <input type="text" name="first_name" value="" />
  </label>
  <button type="submit" class="btn btn-primary">Log In</button>
</form>})

    view = RegistrationView.new(account: Account.new(email: 'mail@paulbarry.com', date_of_birth: Date.parse('1978-07-06')))
    puts view.render
    assert_equal expected, remove_whitespace(view.render)
  end

  private
  def remove_whitespace(s)
    s.to_s.split("\n").map(&:strip).reject(&:blank?).join("\n")
  end

end
