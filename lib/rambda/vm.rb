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
        # to_s
        # puts "AXER: #{a} #{x} #{e} #{r}"
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
          x = a.body
          if a.formals.size != r.size
            raise "procedure of arguments #{a.formals} was passed the wrong number of arguments: #{r}"
          end
          e = Env.new(a.env, a.formals.zip(r).to_h)
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
