module Rambda
  class Env
    class NoSuchVar < StandardError
      attr_accessor :var_name

      def initialize(var_name)
        @var_name = var_name
      end

      def to_s
        @var_name
      end
    end

    def initialize(parent=nil)
      @env = {}
      @parent = parent
    end

    def self.from(hash)
      e = Env.new
      hash.each_pair { |k, v| e.set(k, v)}
      e
    end

    def set(var, val)
      @env[var] = val
    end

    def look_up(var)
      @env.fetch(var) do
        if @parent
          @parent.look_up(var)
        else
          raise NoSuchVar.new(var)
        end
      end
    end
  end
end
