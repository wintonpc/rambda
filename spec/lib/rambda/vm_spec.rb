require 'rspec'
require 'rambda'

module Rambda
  describe VM do
    it 'refer' do
      expect(eval('a', Env.from(a: 42))).to eql 42
    end

    it 'constant' do
      expect(eval('33')).to eql 33
    end

    it 'quote' do
      expect(eval("'a")).to eql :a
    end

    it 'assign' do
      expect(eval('(set! a 44) a')).to eql 44
    end

    it 'close' do
      expect(eval('(lambda (x) x)')).to be_a Closure
    end

    it 'if' do
      expect(eval('(if #t 1 2)')).to eql 1
      expect(eval('(if #f 1 2)')).to eql 2
    end

    it 'lambda test' do
      code = <<EOD
(set! p (lambda (x) x))
(p 42)
EOD
      expect(eval(code, Env.new)).to eql 42
    end
#
#     it 'lambda cons' do
#       code = <<EOD
# (set! cons (lambda (h t) (lambda ()))
# (p 42)
# EOD
#       expect(eval(code, Env.new)).to eql 42
#     end

    def eval(code, env=Env.new)
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
