module Curtain
  module UrlHelpers
    # Want to make it easy to convert a Hash to a QueryString,
    # but also want to support URI stuff like scheme directly
    #   url(:foo, params: { x: 1 })
    #   url("/foo", scheme: "https")
    def url(url, options={})
    end
  end
end
