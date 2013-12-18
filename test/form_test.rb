require 'test_helper'

class FormTest < Curtain::TestCase
  class Account
    attr_accessor :email, :password, :first_name, :last_name, :website, :phone, :photo, :gender, :favorite_color, :language, :date_of_birth, :bio, :notifications

    def initialize(attrs={})
      if attrs
        attrs.each do |attr, value|
          send("#{attr}=", value)
        end
      end
    end
  end

  class ::AccountView < Curtain::View
    attr_accessor :account
  end

  def use(lang)
    AccountView.template_directories File.join(File.dirname(__FILE__), "examples", "form", lang)
  end

  %w[erb slim].each do |lang|
    test "form with #{lang}" do
      use lang
      expected = %{<form id="test"><input type="text" name="name"></form>}

      assert_equal expected, strip_lines(AccountView.render)
    end

    test "form with fields with #{lang}" do
      use lang
      expected = %{<form id="test"><input type="text" name="name"></form>}

      assert_equal expected, strip_lines(AccountView.render)
    end

    test "form for with #{lang}" do
      use lang
      expected = %{<form id="test"><input type="text" name="name"></form>}

      view = AccountView.new(account: Account.new(email: 'mail@paulbarry.com', date_of_birth: Date.parse('1978-07-06')))
      assert_equal expected, strip_lines(view.render)
    end

    test "form for with fields with #{lang}" do
      use lang
      expected = %{<form id="test"><input type="text" name="name"></form>}

      view = AccountView.new(account: Account.new(email: 'mail@paulbarry.com', date_of_birth: Date.parse('1978-07-06')))
      assert_equal expected, strip_lines(view.render)
    end
  end

end
