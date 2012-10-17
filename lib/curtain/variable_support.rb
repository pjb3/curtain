module Curtain
  module VariableSupport

    def variables
      @variables ||= HashWithIndifferentAccess.new
    end

    def [](var)
      variables[var]
    end

    def []=(var,val)
      variables[var] = val
    end

  end
end
