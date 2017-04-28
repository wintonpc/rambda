require 'rambda/cons'
require 'stringio'

module Rambda
  module Pretty
    def print(x, quoted=false)
      case x
      when Cons
        s = StringIO.new
        s << "'" unless quoted
        s << '('
        s << print(x.h, true)
        x = x.t
        while x != nil
          s << " #{print(x.h, true)}"
          x = x.t
        end
        s << ')'
        s.string
      when Symbol
        "#{quoted ? '' : "'"}#{x.to_s}"
      when Numeric
        x.to_s
      when String
        x.inspect
      when TrueClass
        '#t'
      when FalseClass
        '#f'
      when NilClass
        "'()"
      when Closure
        text = Pretty.print(x.lambda_exp, true)
        if text.size < 100
          "#<procedure #{text}>"
        else
          '#<procedure>'
        end
      end
    end

    extend self
  end
end
