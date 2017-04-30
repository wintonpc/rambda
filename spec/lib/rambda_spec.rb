require 'rspec'
require 'rambda'

module Rambda
  describe Rambda do
    it 'lambda creates new environment' do
      verify Rambda::Env::NoSuchVar,
             '(lambda () (set! a 5)) a'
    end

    it 'begin does not create new environment' do
      verify 5,
             '(begin (set! a 5)) a'
    end

    it 'multiple-body lambda' do
      verify 7 do
        <<EOD
(begin
  (set! a 5)
  ((lambda ()
    (set! a 6)
    (set! a 7)))
  a)
EOD
      end
    end

    it 'list' do
      verify Cons.from_array1([1,2,3]), '(list 1 2 3)'
    end

    it 'dotted pair' do
      verify Cons.new(1, 2), "'(1 . 2)"
    end

    it 'dotted list' do
      verify Cons.new(1, Cons.new(2, 3)), "'(1 2 . 3)"
    end

    it 'bad dotted list' do
      verify RuntimeError, "'(1 2 . 3 4)"
    end

  it 'lambda varargs' do
    verify Cons.from_array([1,2,[3,4]]) do
      <<EOD
((lambda (a b . c)
   (list a b c))
 1 2 3 4)
EOD
    end
  end

    def verify(expected, code=nil)
      code ||= yield
      if expected.is_a?(Class) && expected < Exception
        expect { Rambda.eval(code) }.to raise_error expected
      else
        expect(Rambda.eval(code)).to eql expected
      end
    end
  end
end
