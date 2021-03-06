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

    it 'reads dotted pairs' do
      verify_reads('(a . b)', [Cons.new(:a, :b)])
    end

    it 'reads quoted dotted pairs' do
      verify_reads('(quote (a . b))', [Cons.new(:quote, Cons.new(Cons.new(:a, :b), nil))])
    end

    it 'reads quoted2 dotted pairs' do
      verify_reads("'(a . b)", [Cons.new(:quote, Cons.new(Cons.new(:a, :b), nil))])
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

    it 'reads quote' do
      verify_reads("'a", [Cons.from_array([:quote, :a])])
    end

    it 'reads quasiquote' do
      verify_reads("`a", [Cons.from_array([:quasiquote, :a])])
    end

    it 'reads unquote' do
      verify_reads(",a", [Cons.from_array([:unquote, :a])])
    end

    it 'reads unquote-splicing' do
      verify_reads(",@a", [Cons.from_array([:'unquote-splicing', :a])])
    end

    it 'reads maps' do
      verify_reads('{}', [Cons.from_array1([:'make-map'])])
      verify_reads('{1 2}', [Cons.from_array1([:'make-map', 1, 2])])
    end

    def verify_reads(code, expected)
      cs = CharStream.from(StringIO.new(code))
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      actual = ss.to_a
      expect(actual).to eql expected
    end
  end
end
