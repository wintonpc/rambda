require 'rambda/closure'
require 'rambda/compiler'

module Rambda
  module VM
    def eval(x, env, observer: nil)
      run(nil, x, env, [], [], observer)
    end

    def apply(p, env, args, observer: nil)
      run(p, Compiler.compile(Cons.from_array1([p, *args])), env, args, [], observer)
    end

    def resume(state, observer: nil)
      run(state[:a], state[:x], state[:e], state[:r], state[:s], observer)
    end

    private

    def run(a, x, e, r, s, observer)
      while x != [:halt]
        # puts "AXERS: #{a.inspect} #{x.inspect} #{e.inspect} #{r.inspect} #{s.inspect}"
        case x[0]
        when :refer
          _, var, x = *x
          a = e.look_up(var)
        when :constant
          _, val, x = *x
          a = val
        when :assign
          _, var, x = *x
          e.set(var, a)
        when :test
          _, con, alt = *x
          x = a ? con : alt
        when :close
          _, vars, body, lambda_exp, x = *x
          a = Closure.new(body, e, vars, lambda_exp)
        when :argument
          _, x = *x
          r.unshift(a)
        when :frame
          _, ret, x = *x
          s = [ret, e, r, s]
          r = []
        when :apply
          if a.is_a?(Closure)
            x = a.body
            e = Env.new(a.env, Cons.to_array1(map_formals(a.formals, Cons.from_array1(r))).to_h)
            r = []
          elsif a.is_a?(Primitive)
            a.val ||= BuiltIn.primitives[a.var].val
            a = a.val.call(*r)
            x = [:return]
          elsif a.is_a?(Sender)
            a.val ||= BuiltIn.get_sender(a.method).val
            a = a.val.call(*r)
            x = [:return]
          else
            raise "I don't know how to apply a #{a.class}: #{a.inspect}"
          end
        when :return
          x, e, r, s = *s
          observer.returned({a: a, x: x, e: e, r: r, s: s}) if observer
        else
          raise "unexpected instruction: #{x}"
        end
      end
      observer.halted if observer
      a
    end

    private

    def map_formals(vars, vals)
      if vars == nil && vals == nil
        nil
      elsif !vars.is_a?(Cons)
        Cons.new([vars, vals], nil)
      else
        Cons.new([vars.h, vals.h], map_formals(vars.t, vals.t))
      end
    end

    extend self
  end
end
