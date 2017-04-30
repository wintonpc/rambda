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
      verify 5 do
        <<EOD
(begin
  (define-syntax five (lambda (stx) 5))
  (five))
EOD
      end
    end

    it 'define-syntax top level' do
      verify 5 do
        <<EOD
(define-syntax five (lambda (stx) 5))
(five)
EOD
      end
    end

    it 'define-syntax constant' do
      verify 5 do
        <<EOD
(begin
  (define-syntax five (lambda (stx) 5))
  five)
EOD
      end
    end

    it 'define-syntax - function as transformer' do
      verify 5 do
        <<EOD
(set! f (lambda (stx) 5))
(define-syntax five f)
(five)
EOD
      end
    end

    it 'define - value' do
      verify 5 do
        <<EOD
(define x 5)
x
EOD
      end
    end

    it 'define - procedure' do
      verify 6 do
        <<EOD
(define (add1 x) (+ x 1))
(add1 5)
EOD
      end
    end

    it 'nested define' do
      verify -25 do
        <<EOD
(define (foo x)
  (define (square x)
    (* x x))
  (- (square x)))
(foo 5)
EOD
      end
    end

    it 'let' do
      verify 21 do
        <<EOD
(let ([a 3]
      [b 7])
  (* a b))
EOD
      end
    end

    it 'let*' do
      verify 3 do
        <<EOD
(let* ([a 1]
       [b (+ a 1)]
       [c (+ b 1)])
  c)
EOD
      end
    end

    it 'comments' do
      verify 21 do
        <<EOD
;; multiplies some stuff
(let ([a 3]  ; this is a
      [b 7]) ; this is b
  (* a b))
EOD
      end
    end

    it 'if' do
      verify 1, '(if #t 1 2)'
      verify 2, '(if #f 1 2)'
    end

    it 'single branch if' do
      verify 1, '(if #t 1)'
      verify :'%#void', '(if #f 1)'
    end

    def verify(expected, code=nil)
      Pretty.print(expected)
      code ||= yield
      if expected.is_a?(Class) && expected < Exception
        expect { Rambda.eval(code) }.to raise_error expected
      else
        expect(Rambda.eval(code)).to eql expected
      end
    end
  end
end
