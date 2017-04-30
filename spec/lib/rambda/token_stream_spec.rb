require 'rspec'
require 'rambda'
require 'stringio'

module Rambda
  describe TokenStream do
    it 'should do something' do
      verify_tokens 'foo 1 3.14 "a" "a b"',
                    [:foo, 1, 3.14, 'a', 'a b']
      verify_tokens '""', ['']
      verify_tokens '"\\\\"', ['\\']
      verify_tokens '"\\""', ['"']
      verify_tokens '(a . b)', ['(', :a, '.', :b, ')']
    end

    def verify_tokens(code, expected)
      ts = TokenStream.from(CharStream.from(StringIO.new(code)))
      expect(ts.to_a).to eql expected
    end
  end
end
