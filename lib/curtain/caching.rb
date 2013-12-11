module Curtain
  module Caching
    def cache(key, opts={}, &body)
      content = capture(&body)
      # TODO: Implement Me!
      content.html_safe
    end
  end
end
