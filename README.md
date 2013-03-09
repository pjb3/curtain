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

To use Curtain, you define a view and then have that view render templates:

### hello.erb
``` erb
<h1><%= msg %></h1>
```

### my_view.rb
``` ruby
class MyView
  include Curtain
  
  attr_accessor :msg
  
  def initialize(msg)
    @msg = msg
  end
end
```

``` ruby
view = MyView.new("Hello, World!")
view.render("hello") # => <h1>Hello, World!</h1>
```

The template is rendered in the scope of the view object, so any methods defined in the view are available to the template.  You don't have to create a subclass if you don't need to:

``` ruby
Curtain::View.new.render("hello", :msg => "Hello, World!")
```

There is an equivalent shortcut available:

``` ruby
Curtain.render("hello", :msg => "Hello, World!")
```

Curtain includes many useful methods.  Here's a more realistic example that shows some of the built-in methods.  If you have templates like this:

### friends.erb
``` erb
<% cache "friends-#{current_user.id}", ttl: 5.minutes do %>
  <% friends.each do |friend| %>
    <%= render "profile", :profile => friend %>
  <% end %>
<% end %>
```

### profile.erb
``` erb
<ul>
  <li><%= link_to profile.name, path(:profile, :id => profile.id) %></li>
</ul>
```

You can use them in this way:

``` ruby
class ApplicationView < Curtain::View
  attr_accessor :current_user
end

class FriendsView < Curtain::View
  delegate :friends, :to => :current_user
end

view = FriendsView.new(:current_user => User.first)

# The default template name is based on the name of the class of the view
view.render
```

### Variables

If you don't want to define a subclass of `Curtain::View` and add attributes to it, you can also use variables.  `Curtain::View` supports the hash-like Ruby method `[]` and `[]=` to define variables that will act as locals in when the template is rendered:

### hello.erb
``` erb
<h1><%= msg %></h1>
```

``` ruby
view = Curtain::View.new
view[:msg] = "Hello"
view.render(:hello) # => "<h1>Hello</h1>"
```
    
Note that unlike locals, variables exist throughout nested scope of render calls:

### main.erb
``` erb
foo: <%= foo %>
bar: <%= bar %>
<%= render "partial" %>
```
    
### partial.erb
``` erb
foo: <%= foo %>
bar: <%= bar %>
```

``` ruby    
class MainView < Curtain::View
end

view = MainView.new
view[:foo] = "foo"
view.render :bar => "bar"
```

This example would result in an error.  As the main template is first rendered, foo is defined as "foo" because it is a variable, the bar is "bar" because it is passed in as a local.  Then the partial template is rendered, and foo is still defined as "foo" because it is a variable, but since bar was a local passed to the rendering of main, it doesn't carry through to the rendering of partial.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
