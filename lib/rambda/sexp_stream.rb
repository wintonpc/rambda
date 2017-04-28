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
            emit.(read_value(t))
          end
        end
      end
    end

    def read_value(x)
      i = try_parse_int(x)
      return i if i
      f = try_parse_float(x)
      return f if f
      x.to_sym
    end

    def try_parse_int(x)
      Integer(x)
    rescue ArgumentError
      nil
    end

    def try_parse_float(x)
      Float(x)
    rescue ArgumentError
      nil
    end

    extend self
  end
end
