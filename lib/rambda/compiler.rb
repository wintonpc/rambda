require 'rambda/closure'
require 'rambda/vm'

module Rambda
  module Compiler
    def compile(x, nxt=[:halt], env=Env.new)
      if x.is_a?(Symbol)
        if (tx = try_tx(x, env))
          compile(expand_tx(tx.exp, x, env), nxt, env)
        else
          [:refer, x, force(nxt)]
        end
      elsif x.is_a?(Cons)
        case x.h
        when :set!
          var, exp = *Cons.to_array1(x.t)
          compile(exp, [:assign, var, force(nxt)], env)
        when :'define-syntax'
          var = x.t.h
          transformer_exp = x.t.t.h
          env.set(var, Transformer.new(transformer_exp))
          force(nxt)
        when :quote
          obj = Cons.to_array1(x.t)[0]
          [:constant, obj, force(nxt)]
        when :quasiquote
          compile(expand_qq(x), nxt, env)
        when :lambda
          vars = x.t.h
          bodies = x.t.t
          [:close, vars, compile(Cons.new(:begin, bodies), [:return], env), x, force(nxt)]
        when :begin
          exprs = x.t
          if exprs.nil?
            force(nxt)
          else
            compile(exprs.h, proc { compile(Cons.new(:begin, exprs.t), nxt, env) }, env)
          end
        when :if
          test, con, alt = *Cons.to_array1(x.t)
          conc = compile(con, nxt, env)
          altc = compile(alt, nxt, env)
          compile(test, [:test, conc, altc], env)
        else
          application =
              if x.h.is_a?(Symbol) && x.h.to_s.start_with?('.')
                method = x.h.to_s[1..-1]
                p = Sender.new(method)
                [:constant, p, [:apply]]
              else
                if x.h.is_a?(Symbol) && (tx = try_tx(x.h, env))
                  compile(expand_tx(tx.exp, x, env), nxt, env)
                else
                  compile(x.h, [:apply], env)
                end
              end

          args = Cons.to_array1(x.t)
          c = args.reduce(application) do |c, arg|
            compile(arg, [:argument, c], env)
          end
          if nxt == [:return]
            c
          else
            [:frame, force(nxt), c]
          end
        end
      else
        [:constant, x, force(nxt)]
      end
    end

    private

    def try_tx(var, env)
      tx = env.try_look_up(var)
      tx.is_a?(Transformer) && tx
    end

    def force(nxt)
      nxt.is_a?(Proc) ? nxt.call : nxt
    end

    def expand_tx(tx, x, env)
      c = compile(Cons.from_array1([tx, Cons.from_array1([:quote, x])]), [:halt], env)
      VM.eval(c, env)
    end

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
