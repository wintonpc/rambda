require 'rspec'
require 'rambda'

module Rambda
  describe Compiler do

    # it 'compiles procedure applications' do
    #   expect(compile('(+ 1 2)')).to eql expected
    # end

    def compile(code)
      cs = CharStream.from(StringIO.new(code))
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      Compiler.compile(ss.first)
    end
  end
end
