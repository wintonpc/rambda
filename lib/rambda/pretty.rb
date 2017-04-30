require 'rambda/cons'
require 'stringio'

module Rambda
  module Pretty
    def print(x, quoted=true)
      case x
      when Cons
        if x.h == :quote
          "'#{print(x.t.h)}"
        elsif x.h == :quasiquote
          "`#{print(x.t.h)}"
        elsif x.h == :unquote
          ",#{print(x.t.h)}"
        elsif x.h == :'unquote-splicing'
          ",@#{print(x.t.h)}"
        else
          s = StringIO.new
          s << "'" unless quoted
          s << '('
          s << print(x.h, true)
          x = x.t
          loop do
            if x.is_a?(Cons)
              s << " #{print(x.h, true)}"
              x = x.t
            elsif x.nil?
              break
            else
              s << " . #{print(x, true)}"
              break
            end
          end
          s << ')'
          s.string
        end
      when Rambda::Void
        ''
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
