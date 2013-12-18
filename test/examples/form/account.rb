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
