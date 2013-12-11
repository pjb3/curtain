require 'test_helper'

class FormTest < Curtain::TestCase
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

  class ::AccountView < Curtain::View
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

  def use(lang)
    AccountView.template_directories File.join(File.dirname(__FILE__), "examples", "form", lang)
  end

  %w[erb slim].each do |lang|
    test "form with #{lang}" do
      use lang
      expected = %{<form id="test"><input type="text" name="name"></form>}

      view = AccountView.new(account: Account.new(email: 'mail@paulbarry.com', date_of_birth: Date.parse('1978-07-06')))
      assert_equal expected, strip_lines(view.render)
    end
  end

end
