require 'rspec'
require 'rambda'
require 'stringio'

module Rambda
  describe SexpStream do
    # it 'should do something' do
    #   cs = CharStream.from(StringIO.new("'a"))
    #   ts = TokenStream.from(cs)
    #   ss = SexpStream.from(ts)
    #   ss.each { |s| puts "SEXP: #{Pretty.print(s)}" }
    # end

    it 'reads symbols' do
      verify_reads('a',  [:a])
    end

    it 'reads integers' do
      verify_reads('42', [42])
    end

    it 'reads floats' do
      verify_reads('42.4', [42.4])
    end

    it 'reads strings' do
      verify_reads('"foo"', ['foo'])
    end

    it 'reads booleans' do
      verify_reads('#t', [true])
      verify_reads('#f', [false])
    end

    it 'reads multiple expressions' do
      verify_reads('a b', [:a, :b])
    end

    it 'reads sexps' do
      verify_reads('(a b)', [Cons.from_array([:a, :b])])
    end

    it 'reads nil' do
      verify_reads('()', [nil])
    end

    it 'reads nested sexps' do
      verify_reads('((a b) c)',  [Cons.from_array([[:a, :b], :c])])
    end

    it 'reads quoted symbols' do
      verify_reads("'a",  [Cons.from_array([:quote, :a])])
    end

    it 'reads quoted lists' do
      verify_reads("'(a b) '(c d)",
                   [Cons.from_array([:quote, [:a, :b]]),
                    Cons.from_array([:quote, [:c, :d]])])
    end

    def verify_reads(code, expected)
      cs = CharStream.from(StringIO.new(code))
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      expect(ss.to_a).to eql expected
    end
  end
end
