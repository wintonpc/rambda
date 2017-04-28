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

    def to_s
      Pretty.print(self)
    end

    def inspect
      Pretty.print(self)
    end
  end
end
