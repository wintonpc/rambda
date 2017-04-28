module Rambda
  module Compiler
    def compile(x, nxt=[:halt])
      if x.is_a?(Symbol)
        [:refer, x, nxt]
      elsif x.is_a?(Cons)
        case x.h
        when :set!
          var = x.t.h
          exp = x.t.t.h
          compile(exp, [:assign, var, nxt])
        when :quote
          obj = Cons.to_array(x.t)[0]
          [:constant, obj, nxt]
        when :lambda
          vars = Cons.to_array(x.t.h)
          body = x.t.t.h
          [:close, vars, compile(body, [:return]), x, nxt]
        else
          p = x.h
          args = Cons.to_array(x.t)
          c = args.reduce(compile(p, [:apply])) do |c, arg|
            compile(arg, [:argument, c])
          end
          if nxt == [:return]
            c
          else
            [:frame, nxt, c]
          end
        end
      else
        [:constant, x, nxt]
      end
    end

    extend self
  end
end
