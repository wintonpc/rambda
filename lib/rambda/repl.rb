require 'rambda/pretty'

module Rambda
  module Repl
    def run
      cs = CharStream.from(STDIN)
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      print 'λ> '
      ss.each do |exp|
        puts Pretty.print(exp)
        print 'λ> '
      end
    end

    extend self
  end
end
