require 'rambda/cons'
require 'stringio'

module Rambda
  module Pretty
    def print(x, quoted=false)
      case x
      when Cons
        s = StringIO.new
        s << "'" unless quoted
        s << '('
        s << print(x.h, true)
        x = x.t
        while x != nil
          s << " #{print(x.h, true)}"
          x = x.t
        end
        s << ')'
        s.string
      when Symbol
        "#{quoted ? '' : "'"}#{x.to_s}"
      when Numeric
        x.to_s
      end
    end

    extend self
  end
end
