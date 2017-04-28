require 'rambda/closure'

module Rambda
  module VM
    def eval(x, env)
      run(x, env)
    end

    private

    def run(x, e)
      a = nil # accumulator
      r = [] # argument "rib"
      s = [] # stack
      while x != [:halt]
        to_s
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
        when :close
          _, vars, body, lambda_exp, x = *x
          a = Closure.new(body, e, vars, lambda_exp)
        when :argument
          _, x = *x
          r.unshift(a)
        when :frame
          _, ret, x = *x
          r = []
          s = [ret, e, r, s]
        when :apply
          x = a.body
          e = Env.new(e, a.formals.zip(r).to_h)
          r = []
        when :return
          x, e, r, s = *s
        else
          raise "unexpected instruction: #{x}"
        end
      end
      a
    end

    extend self
  end
end
