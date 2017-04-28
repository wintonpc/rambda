module Rambda
  module BuiltIn
    def primitives
      @primitives ||= {
          '+': lambda { |a, b| a + b },
          '*': lambda { |a, b| a * b },
      }
    end

    extend self
  end
end
