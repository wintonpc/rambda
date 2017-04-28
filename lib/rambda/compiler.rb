module Rambda
  module Compiler
    def compile(x, nxt=[:halt])
      if x.is_a?(Symbol)
        [:refer, x, nxt]
      elsif x.is_a?(Cons)
        case x.h
        when :set!
          var, exp = *Cons.to_array1(x.t)
          compile(exp, [:assign, var, nxt])
        when :quote
          obj = Cons.to_array1(x.t)[0]
          [:constant, obj, nxt]
        when :lambda
          vars, body = *Cons.to_array1(x.t)
          vars = Cons.to_array(vars)
          [:close, vars, compile(body, [:return]), x, nxt]
        when :if
          test, con, alt = *Cons.to_array1(x.t)
          conc = compile(con, nxt)
          altc = compile(alt, nxt)
          compile(test, [:test, conc, altc])
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
