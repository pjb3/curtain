module Curtain
  class FormBuilder
    include HTMLHelpers

    attr_accessor :object

    def initialize(object=nil)
    end

    def form_object(object)
      prev_object = self.object
      self.object = object
      yield
      self.object = prev_object
      object
    end

    def input(attrs={})
      void_tag(:input, attrs)
    end

    def text(attrs={})
      input({ type: 'text' }.merge(attrs))
    end

    # Maybe we have text_field and text_tag,
    # where text_field has the wrapping div, the label, the error,
    # and text_input is just the text_input?
    # Makes sense because text, email, password, etc. aren't real HTML tags
    # and results in a few less terms we use up in the namespace.
    #
    # checkbox_field
    # radio_field
    #
    # Doesn't really work for non inputs though:
    # textarea_field
    # textarea_input
    # select_field, select_input
    #
    # Maybe input doesn't do the wrapping? So you can do
    #
    # text name: name
    #
    # that results in
    #
    # <div class="form-group">
    #   <label for="name">Name</label>
    #   <input type="text" name="name" value="" class="form-control" id="name" />
    # </div>
    #
    # but if you don't want all that
    #
    # input type: 'text', name: 'name'
    #
    # gives you
    #
    # <input type="text" name="name" />
    #
    # I like that, but still, what about select/textarea?
  end
end
