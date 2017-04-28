module Rambda
  Cons = Struct.new(:h, :t)
  class Cons
    def self.from_array(x)
      return x unless x.is_a?(Array)
      c = nil
      x.reverse_each do |v|
        c = Cons.new(Cons.from_array(v), c)
      end
      c
    end

    def self.to_array(x)
      return x unless x.is_a?(Cons)
      a = []
      while x != nil
        a << to_array(x.h)
        x = x.t
      end
      a
    end

    def inspect
      to_pretty_sexp(Cons.to_array(self))
    end

    def to_pretty_sexp(x)
      case x
      when Array
        "(#{x.map(&method(:to_pretty_sexp)).join(' ')})"
      else
        x.to_s
      end
    end

  end
end
