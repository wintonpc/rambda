module Rambda
  module Compiler
    def compile(x, nxt=[:halt])
      if x.is_a?(Symbol)
        [:refer, x, nxt]
      elsif x.is_a?(Cons)
        case x.h
        when :set!
          var, exp = *Cons.to_array(x.t)
          compile(exp, [:assign, var, nxt])
        else
          raise "unexpected car: #{x.h}"
        end
      else
        [:constant, x, nxt]
      end
    end

    extend self
  end
end
