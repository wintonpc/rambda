require 'rambda/cons'

module Rambda
  module SexpStream
    def from(token_stream)
      Enumerator.new do |y|
        ss = []

        emit = proc do |x|
          if ss.empty?
            y << Cons.from_array(x)
          else
            ss.last.push(x)
          end
        end

        token_stream.each do |t|
          case t
          when '(', '['
            ss.push([])
          when ')', ']'
            sexp = ss.pop
            emit.(sexp)
          else
            emit.(t.to_sym)
          end
        end
      end
    end

    extend self
  end
end
