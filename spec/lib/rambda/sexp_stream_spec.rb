require 'rspec'
require 'rambda'
require 'stringio'

module Rambda
  describe SexpStream do
    it 'should do something' do
      cs = CharStream.from(StringIO.new('#f'))
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      ss.each { |s| puts "SEXP: #{Pretty.print(s)}" }
    end
  end
end
