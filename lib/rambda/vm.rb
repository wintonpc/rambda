require 'rambda/closure'

module Rambda
  module VM
    def eval(x, env)
      run(x, env)
    end

    private

    def run(x, e)
      a = r = s = nil
      while x != [:halt]
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
        else
          raise "unexpected instruction: #{x}"
        end
      end
      a
    end

    extend self
  end
end
