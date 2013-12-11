# Curtain

Curtain is a template rendering framework for Ruby.  It is built on top of [Tilt](https://github.com/rtomayko/tilt).  Curtain is not tied to any web framework like Rails or Sinatra, so it can be used standalone in any Ruby project.

# Installation

Add this line to your application's Gemfile:

    gem 'curtain'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install curtain

# Usage

## Rendering Templates

To use Curtain, you define a view and then have that view render templates:

**hello.erb**

``` rhtml
<h1><%= msg %></h1>
```

**my_view.rb**

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
Curtain::View.new.render("hello", msg: "Hello, World!")
```

There is an equivalent shortcut available:

``` ruby
Curtain.render("hello", msg: "Hello, World!")
```

## Partials

Because `render` is a method on the view object, you can call it from within the template to render one template from another:

**main.erb**

``` rhtml
<%= render "partial" %>
```

**partial.erb**

``` rhtml
<h2>I'm a Partial!</h2>
```

```
Curtain.render("main") # => "<h2>I'm a Partial!</h2>"
```

You can also pass local variables to the partial:

**main.erb**

``` rhtml
<%= render "partial", greeting: 'Hello' %>
```

**partial.erb**

``` rhtml
<h2><%= greeting %>, I'm a Partial!</h2>
```

```
Curtain.render("main") # => "<h2>Hello, I'm a Partial!</h2>"
```

## Variables

If you don't want to define a subclass of `Curtain::View` and add attributes to it, you can also use variables.  `Curtain::View` supports the hash-like Ruby method `[]` and `[]=` to define variables that will act as locals in when the template is rendered:

**hello.erb**

``` rhtml
<h1><%= msg %></h1>
```

``` ruby
view = Curtain::View.new
view[:msg] = "Hello"
view.render(:hello) # => "<h1>Hello</h1>"
```

Note that unlike locals, variables exist throughout nested scope of render calls:

**main.erb**

``` rhtml
foo: <%= foo %>
bar: <%= bar %>
<%= render "partial" %>
```

**partial.erb**

``` rhtml
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

This example would result in an error.  As the main template is first rendered, foo is defined as "foo" because it is a variable, bar is "bar" because it is passed in as a local.  Then the partial template is rendered, and foo is still defined as "foo" because it is a variable, but since bar was a local passed to the rendering of main, it doesn't carry through to the rendering of partial.

## HTML Tag Methods

*NOTE: The HTML Tag Methods are only supported in [ERB][erb] and [Slim][slim]*

`Curtain::View` has HTML tag methods to make generating HTML easier. There is a method for every valid HTML tag. The methods for [void tags][void-tags] take an optional Hash of attributes:

**photo.erb**

``` rhtml
<%= img src: image_path %>
```

``` ruby
Curtain.render('photo', image_path: '/pic.jpg') # => <img src="/pic.jpg">
```

The methods for tags that may have body content accept the body content as a string in the first argument:

**link.erb**

``` rhtml
<%= a 'Home', href: path %>
```

``` ruby
Curtain.render('link', path: '/') # => <a href="/">Home</a>
```

or you can pass the body content as a block:

**link.erb**

``` rhtml
<%= a href: path, class: 'btn btn-default' do %>
  <span class="glyphicon glyphicon-home"></span> Home
<% end %>
```

``` ruby
Curtain.render('link', path: '/') # => <a href="/" class="btn btn-default"><span class="glyphicon glyphicon-home"></span> Home</a>
```

## Form Tag Methods

There are some extra tag methods related to forms, as well as enhanced functionality for the form-related tags.

### Input Types

You can create an `input` tag using the `input` method:

``` rhtml
<%= input type: 'text', name: 'first_name' %>
```

but there are shortcut methods for all the valid types for input. Here are some examples:

``` rhtml
<%= text :first_name %>
<%= file :photo %>
<%= email :email %>
<%= password :password %>
<%= url :website %>
```

The equivalent to those examples are:

``` rhtml
<%= input type: 'text', name: 'first_name' %>
<%= input type: 'file', name: 'photo' %>
<%= input type: 'email', name: 'email' %>
<%= input type: 'password', name: 'password' %>
<%= input type: 'url', name: 'website' %>
```

The one exception to this pattern is that this:

``` rhtml
<%= submit "Save" %>
```

generates:

``` html
<button type="submit">Save</button>
```

### Forms

The `form` tag has some special behavior as well. You can use it without an special behavior with no arguments:

``` rhtml
<%= form do %>
<% end %>
```

which generates:

``` html
<form>
</form>
```

or you can pass a Hash of attributes:

``` rhtml
<%= form method: 'patch', action: '/register' do %>
<% end %>
```

which generates:

``` html
<form method="post" action="/register">
  <input type="hidden" name="_method" value="patch">
</form>
```

Because browsers only natively support `GET` and `POST` methods, a hidden parameter is generated for the method if you use something other than `GET` or `POST`.

### Form Builders

When creating forms, it is common to want to have a form field for each attribute of an object and have the value of each input set to the value of the correspoding attribute of the object. You can do that using a Form Builder. Assuming you have something like this in the view:

``` ruby
@person = Person.new(id: 1, first_name: 'Paul')
```

You can use a form builder to create a form using the `for` attribute of the `form` tag method:

``` rhtml
<%= form for: @person do %>
  <%= text :first_name %>
<% end %>
```

This generates:

``` html
<form method="post" action="/people/1">
  <input type="hidden" name="_method" value="PATCH">
  <input type="text" name="person[first_name]" value="Paul">
</form>
```

There are a few things that happen when you use the `for` attribute. First, the method and action are inferred based on the object. If the object has an ID, it is assumed to be a record that already been saved, therefore the method will be `patch` and the action will be the pluralized class name with the ID at the end. If the object does not have an ID, it is assumed to be a new record, so the `post` method is used and the action is just the pluralized class name. You can override the generated method by passing explict values for `method` and `action`

``` rhtml
<%= form for: @person, method: 'post', action: '/profile' do %>
<% end %>
```

The second thing that happens when you use a form builder is that the input names are prefixed with the underscored name of the class and the attribute is in brackets. This is so that all parameters related to the object will be collected into one Hash in the parameters. In the example above, `person` is the underscored name of the class and the attribute is `first_name`, so the name of the input ends up being `person[first_name]`. If you want to use something other than the underscored name of the class, you can use the `as` attributesin the `form` method:

``` rhtml
<%= form for: @person, as: 'account' do %>
  <%= text :first_name %>
<% end %>
```

This will result in the input name being `account[first_name]`.

Finally, the value is set based on the value of the attribute of the object the form is for. As seen in the example above, `value` is `Paul`, because that is that is the value returned by `@person.first_name`.

### Fields

When building forms, it is common to want to have a label and errors messages next to each input. This pattern is supported by the `_field` methods. This example:

``` rhtml
<%= form for: @person do %>
  <%= text_field :first_name %>
<% end %>
```

produces the following HTML:

``` html
<form method="post" action="/people">
  <div class="form-field">
    <label for="first_name">First Name</label>
    <input type="text" name="first_name" value="" id="first_name">
    <span class="error">is required</span>
  </div>
</form>
```

The content of the label can be customized with the `label` attribute. The error only shows up if the form object has an error on that attribute.

There is a corresponding `_field` method for each input tag, so `text_field`, `email_field`, `password_field`, etc. There are also `_field` methods for the other non-input form tag methods, such as `select_field` and `textarea_field`.

### Custom Form Builders

The markup produced by the `_field` methods is controlled by the form builder. The form builder is a class that can be overriden and customized. You can use a different form builder for a specific form:

``` rhtml
<%= form builder: MyFormBuilder do %>
```

The class passed to the `builder` attribute should be a subclass of `Curtain::FormBuilder`.  You can also control which form builder is used in a more broad manner. The default form builder is determined by the `default_form_builder` method on the `View` class. `Curtain::View.default_form_builder` returns `Curtain::FormBuilder`. You can set the default form builder on your view like this:

``` ruby
class MyView < Curtain::View
  default_form_builder MyFormBuilder
end
```

This works throughout the inhereitence chain, so you can create a single view in your application that all views inheret from and then set the default_form_builder on that view in order to make all forms in your application use your custom form builder.

### Pre-built Form Builders

There are already form builders for the [Bootstrap][bootstrap] and [Foundation][foundation] CSS frameworks. To use them, install the gem for the one you wish to use, [curtain-bootstrap][curtain-bootstrap] or [curtain-foundation][curtain-foundation], and then set the default form builder on the view you would like to use them on:

``` ruby
class ApplicationView < Curtain::View
  default_form_builder Curtain::Bootstrap::FormBuilder
end
```

See the documentation for each of those projects to see exactly what markup they generate.

## Caching

Curtain has built-in support for caching via the `cache` method. You use the method like this:

``` rhtml
<%= cache 'hourly-stats', expires_in: 1.hour do %>
  <% get_report_data.each do |row| %>
  ...
  <% end %>
<% end %>
```

To use caching, you just set the cache on the view class:

``` ruby
Curtain::View.cache = Dalli::Client.new
```

You can use anything supported by the [Cache][cache] library for the cache.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[tilt]: http://github.com/rtomayko/tilt
[erb]: http://www.kuwata-lab.com/erubis/#Introduction
[slim]: http://slim-lang.com
[bootstrap]: http://getbootstrap.com
[foundation]: http://foundation.zurb.com
[curtain-bootstrap]: http://rubygems.org/gems/curtain-bootstrap
[curtain-foundation]: http://rubygems.org/gems/curtain-foundation
[cache]: http://rubygems.org/gems/cache
[void-tags]: http://www.w3.org/TR/html-markup/syntax.html#void-element
