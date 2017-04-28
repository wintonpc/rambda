module Rambda
  module BuiltIn
    def primitives
      @primitives ||= {
          '+': lambda { |a, b| a + b },
          '*': lambda { |a, b| a * b },

          'ruby-eval': lambda { |str| Kernel.eval(str) }
      }
    end

    extend self
  end
end
