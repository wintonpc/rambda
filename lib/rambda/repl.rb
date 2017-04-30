require 'rambda/pretty'

module Rambda
  module Repl
    def run
      cs = CharStream.from(STDIN)
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      env = Env.new
      print 'λ> '
      ss.each do |exp|
        begin
          puts Pretty.print(VM.eval(Compiler.new.compile(exp), env))
        rescue Env::NoSuchVar => e
          puts "!! Variable #{e.var_name} is not bound"
        end
        print 'λ> '
      end
    end

    extend self
  end
end
