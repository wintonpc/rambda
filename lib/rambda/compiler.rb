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
        when :quasiquote
          compile(expand_qq(x), nxt)
        when :lambda
          vars = x.t.h
          bodies = x.t.t
          [:close, vars, compile(Cons.new(:begin, bodies), [:return]), x, nxt]
        when :begin
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

    private

    def expand_qq(x)
      x = x.t.h
      if !x.is_a?(Cons)
        Cons.from_array1([:quote, x])
      else
        Cons.from_array1([:'append-lists', Cons.new(:list, Cons.map(x, &method(:expand_qq_element)))])
      end
    end

    def expand_qq_element(x)
      if x.is_a?(Cons) && x.h == :unquote
        Cons.from_array1([:list, x.t.h])
      elsif x.is_a?(Cons) && x.h == :'unquote-splicing'
        x.t.h
      else
        Cons.from_array1([:list, expand_qq(Cons.from_array1([:quasiquote, x]))])
      end
    end

    extend self
  end
end
