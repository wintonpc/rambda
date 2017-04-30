require 'rambda/cons'
require 'stringio'

module Rambda
  module Pretty
    def print(x, quoted=true)
      case x
      when Cons
        if x.h == :quote
          "'#{print(x.t.h)}"
        else
          s = StringIO.new
          s << "'" unless quoted
          s << '('
          s << print(x.h, true)
          x = x.t
          while x != nil
            s << " #{print(x.h, true)}"
            if x.t.is_a?(Cons) || x.t.nil?
              x = x.t
            else
              s << " . #{print(x.t, true)}"
              break
            end
          end
          s << ')'
          s.string
        end
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
        '()'
      when Closure
        text = Pretty.print(x.lambda_exp, true)
        if text.size < 100
          "#<procedure #{text}>"
        else
          '#<procedure>'
        end
      when Transformer
        "#<syntax-transformer #{Pretty.print(x.exp)}>"
      when Primitive
        "#<procedure:#{x.var}>"
      when Sender
        "#<procedure:#{x.method}>"
      else
        "#<ruby:#{x.inspect}>"
      end
    end

    extend self
  end
end
