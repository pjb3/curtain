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
      expected = File.read(File.expand_path("examples/form/account.html", File.dirname(__FILE__)))

      assert_html_equal expected, AccountView.render("bootstrap", main: 'account')
    end

    test "form with data with #{lang}" do
      use lang
      expected = File.read(File.expand_path("examples/form/account_with_data.html", File.dirname(__FILE__)))

      account_data = YAML.load_file(File.expand_path("examples/form/account.yml", File.dirname(__FILE__)))
      account = Account.new(account_data)
      view = AccountView.new(account: account)
      assert_equal "mail@paulbarry.com", view.account.email
      assert_html_equal expected, view.render("bootstrap", main: 'account')
    end
  end

end
