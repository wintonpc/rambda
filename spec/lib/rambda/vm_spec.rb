require 'rspec'
require 'rambda'

module Rambda
  describe VM do
    it 'refer' do
      eval("a", Env.from(a: 42))
    end

    def eval(code, env)
      VM.eval(compile(code), env)
    end

    def compile(code)
      cs = CharStream.from(StringIO.new(code))
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      Compiler.compile(ss.first)
    end
  end
end
