module Rambda
  Env = Struct.new(:parent, :env)
  class Env
    class NoSuchVar < StandardError
      attr_accessor :var_name

      def initialize(var_name)
        @var_name = var_name
      end

      def message
        "NoSuchVar: #{to_s}"
      end

      def to_s
        @var_name.to_s
      end
    end

    def initialize(parent=nil, env={})
      self.env = env
      self.parent = parent
    end

    def hash
      env
    end

    def self.from(hash)
      e = Env.new
      hash.each_pair { |k, v| e.set(k, v)}
      e
    end

    def import(hash)
      env.merge!(hash)
      self
    end

    def set(var, val)
      e = self
      while e
        if e.hash.key?(var)
          e.hash[var] = val
          return val
        end
        e = e.parent
      end
      # if not already bound in any parent env...
      env[var] = val
    end

    def look_up(var)
      env.fetch(var) do
        if parent
          parent.look_up(var)
        elsif self != Env.built_in
          Env.built_in.look_up(var)
        else
          raise NoSuchVar.new(var)
        end
      end
    end

    def try_look_up(var)
      env.fetch(var) do
        if parent
          parent.look_up(var)
        elsif self != Env.built_in
          Env.built_in.try_look_up(var)
        else
          :NoSuchVar
        end
      end
    end

    def self.built_in
      @built_in ||= Env.new(nil, BuiltIn.primitives)
    end

    def inspect
      e = self
      h = {}
      while e
        h = e.hash.merge(h)
        e = e.parent
      end
      "#<Env #{h.map { |(k, v)| "#{k}=#{v.inspect}"}.join(' ')}>"
    end

    def to_s
      inspect
    end
  end
end
