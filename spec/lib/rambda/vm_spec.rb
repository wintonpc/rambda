require 'rspec'
require 'rambda'

module Rambda
  describe VM do
    it 'refer' do
      expect(eval('a', Env.from(a: 42))).to eql 42
    end

    it 'constant' do
      expect(eval('33', Env.new)).to eql 33
    end

    it 'quote' do
      expect(eval("'a", Env.new)).to eql :a
    end

    it 'assign' do
      expect(eval('(set! a 44) a', Env.new)).to eql 44
    end

    it 'close' do
      expect(eval('(lambda (x) x)', Env.new)).to be_a Closure
    end

#     it 'lambda test' do
#       code = <<EOD
# (set! p (lambda (x) x))
#
# EOD
#       expect(eval('(lambda (x) x)', Env.new)).to be_a Closure
#     end

    def eval(code, env)
      cs = CharStream.from(StringIO.new(code))
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      result = nil
      ss.each do |exp|
        result = VM.eval(Compiler.compile(exp), env)
      end
      result
    end
  end
end
