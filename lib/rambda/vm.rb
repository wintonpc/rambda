require 'rambda/closure'

module Rambda
  module VM
    def eval(x, env, persister: proc{})
      run(nil, x, env, [], [], persister)
    end

    def resume(state, persister: proc{})
      puts 'VM.resume'
      run(state[:a], state[:x], state[:e], state[:r], state[:s], persister)
    end

    private

    def run(a, x, e, r, s, persister)
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
          persister.call({a: a, x: x, e: e, r: r, s: s})
          if a.is_a?(Closure)
            x = a.body
            if a.formals.size != r.size
              raise "procedure of arguments #{a.formals} was passed the wrong number of arguments: #{r}"
            end
            e = Env.new(a.env, a.formals.zip(r).to_h)
            r = []
          elsif a.is_a?(Primitive)
            a.val ||= BuiltIn.primitives[a.var].val
            a = a.val.call(*r)
            x = [:return]
          elsif a.is_a?(Sender)
            a.val ||= BuiltIn.get_sender(a.method).val
            a = a.val.call(*r)
            x = [:return]
          elsif a.is_a?(Proc) # TODO: remove
            a = a.call(*r)
            x = [:return]
          else
            raise "I don't know how to apply a #{a.class}: #{a.inspect}"
          end
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
