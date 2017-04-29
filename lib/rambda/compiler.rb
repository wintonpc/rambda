require 'rambda/closure'

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
        when :begin # TODO: implement with macro
          exprs = Cons.to_array1(x.t)
          exprs.reverse.reduce(nxt) do |c, expr|
            compile(expr, c)
          end
        when :if
          test, con, alt = *Cons.to_array1(x.t)
          conc = compile(con, nxt)
          altc = compile(alt, nxt)
          compile(test, [:test, conc, altc])
        else
          application =
              if x.h.is_a?(Symbol) && x.h.to_s.start_with?('.')
                method = x.h.to_s[1..-1]
                p = Sender.new(method)
                [:constant, p, [:apply]]
              else
                compile(x.h, [:apply])
              end

          args = Cons.to_array1(x.t)
          c = args.reduce(application) do |c, arg|
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
