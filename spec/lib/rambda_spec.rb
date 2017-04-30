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

    it 'lambda L' do
      verify Cons.from_array([1,2]),
             '((lambda L L) 1 2)'
    end

    it 'quote' do
      verify Cons.from_array([1,2,3]),
             "'(1 2 3)"
    end

    it 'append-lists' do
      verify Cons.from_array([1,2,3,4,5,6]),
             "(append-lists '((1 2) (3 4) (5 6)))"
    end

    it 'quasiquote - works like quote' do
      verify Cons.from_array([1,2,3]),
             '`(1 2 3)'
      verify :x, '`x'
    end

    it 'quasiquote - unquote' do
      verify Cons.from_array([1,2,3]) do
        <<EOD
(set! c 3)
`(1 2 ,c)
EOD
      end
    end

    it 'quasiquote - unquote-splicing' do
      verify Cons.from_array([1,2,3,4]) do
        <<EOD
(set! c '(3 4))
`(1 2 ,@c)
EOD
      end
    end

    it 'quasiquote - nested' do
      verify Cons.from_array([1,2,3,[4,5]]) do
        <<EOD
(set! a 2)
(set! b 5)
`(1 ,a ,@(list 3 `(4 ,b)))
EOD
      end
    end

    it '+' do
      verify 0, '(+)'
      verify 5, '(+ 5)'
      verify 3, '(+ 1 2)'
      verify 6, '(+ 1 2 3)'
    end

    it '-' do
      verify -5, '(- 5)'
      verify 4, '(- 5 1)'
      verify 1, '(- 5 1 3)'
    end

    it 'compose' do
      verify 2, "((compose car cdr) '(1 2 3))"
    end

    it 'compose-many' do
      verify Cons.from_array([1,2,3]), "((compose-many (list)) '(1 2 3))"
      verify 1, "((compose-many (list car)) '(1 2 3))"
      verify 2, "((compose-many (list car cdr)) '(1 2 3))"
      verify 3, "((compose-many (list car cdr cdr)) '(1 2 3))"
    end

    it 'foldr' do
      verify Cons.from_array([1,2,3]),
             "(foldr cons '() '(1 2 3))"

      verify 0, "(foldr + 0 '())"
      verify 1, "(foldr + 0 '(1))"
      verify 3, "(foldr + 0 '(1 2))"
      verify 6, "(foldr + 0 '(1 2 3))"
    end

    it 'define-syntax' do

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
