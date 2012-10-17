# Curtain

Curtain is a template rendering framework for Ruby.  It is built on top of [Tilt](https://github.com/rtomayko/tilt).  Curtain is not tied to any web framework like Rails or Sinatra, so it can be used standalone in any Ruby project.

## Installation

Add this line to your application's Gemfile:

    gem 'curtain'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install curtain

## Usage

The use Curtain, you define a view and then have that view render templates:

    # hello.erb
    <h1><%= msg %></h1>

    # my_view.rb
    class MyView < Struct.new(:msg)
      include Curtain
    end

    view = MyView.new("Hello, World!")
    view.render("hello") # => <h1>Hello, World!</h1>

The template is rendered in the scope of the view object, so any methods defined in the view are available to the template.  You don't have to create a subclass if you don't need to:

    Curtain::View.new.render("hello", msg: "Hello, World!")

There is an equivalent shortcut available:

    Curtain.render("hello", msg: "Hello, World!")

Curtain includes many useful methods.  Here's a more realistic example that shows some of the built-in methods:

    # friends.erb
    <% cache "friends-#{current_user.id}", ttl: 5.minutes do %>
      <% friends.each do |friend| %>
        <%= render "profile", profile: friend %>
      <% end %>
    <% end %>

    # profile.erb
    <ul>
      <li><%= link_to friend.name, path_for(:profile, id: friend.id) %></li>
    </ul>

    class ApplicationView < Curtain::View
      attr_accessor :current_user
    end

    class FriendsView < Curtain::View
      delegate :friends, :to => :current_user
    end

    view = FriendsView.new(current_user: User.first)

    # The default template name is based on the name of the class of the view
    view.render

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
