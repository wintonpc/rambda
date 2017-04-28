module Rambda
  module VM
    def eval(x, env)
      run(x, env)
    end

    private

    def run(x, e)
      a = r = s = nil
      while x != [:halt]
        if x[0] == :refer
          _, var, x = *x
          a = e.look_up(var)
        end
      end
      a
    end

    extend self
  end
end
