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

    def self.from_array1(x)
      c = nil
      x.reverse_each do |v|
        c = Cons.new(v, c)
      end
      c
    end

    def self.to_array(x)
      return [] if x.nil?
      return x unless x.is_a?(Cons)
      a = []
      while x != nil
        a << to_array(x.h)
        x = x.t
      end
      a
    end

    def self.to_array1(x)
      return [] if x.nil?
      return x unless x.is_a?(Cons)
      a = []
      while x != nil
        a << x.h
        x = x.t
      end
      a
    end

    def self.map(c, &block)
      if c.nil?
        nil
      else
        Cons.new(block.call(c.h), map(c.t, &block))
      end
    end

    def to_s
      Pretty.print(self)
    end

    def inspect
      Pretty.print(self)
    end
  end
end
