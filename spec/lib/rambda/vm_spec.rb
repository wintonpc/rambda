require 'rspec'
require 'rambda'
require 'oj'

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

    it 'lambda cons' do
      env = Env.new
      code = <<EOD
(set! cons (lambda (h t) (lambda (x) (if x h t))))
(set! car (lambda (c) (c #t)))
(set! cdr (lambda (c) (c #f)))
EOD
      eval(code, env)
      expect(eval('(car (cons 1 2))', env)).to eql 1
      expect(eval('(cdr (cons 1 2))', env)).to eql 2
    end

    it 'primitives' do
      env = Env.new
      expect(eval('(+ 1 2)', env)).to eql 3
      expect(eval('(* 3 7)', env)).to eql 21
      expect(eval('(* 4 (+ 1 (* 3 7)))', env)).to eql 88
    end

    it 'begin' do
      code = <<EOD
(+ (begin
     (set! a 1)
     (set! b 2)
     (+ a b))
   90)
EOD
      expect(eval(code)).to eql 93
    end

    it 'parameterless lambda' do
      expect(eval('((lambda () 42))')).to eql 42
    end

    it 'ruby-eval' do
      expect(eval('(ruby-eval "$LOAD_PATH")')).to be_a Array
    end

    it 'ruby-call' do
      expect(eval('(ruby-call (ruby-eval "proc { |x| x * 2 }") 7)')).to eql 14
    end

    it 'ruby-call-proc' do
      expect(eval('(ruby-call-proc "|x| x * 2" 15)')).to eql 30
    end

    it '++ (string append)' do
      expect(eval('(++ "foo" "bar")')).to eql 'foobar'
      expect(eval("(++ 'foo 'bar 1)")).to eql 'foobar1'
    end

    it 'apply' do
      p = Rambda.eval('+')
      expect(VM.apply(p, Env.new, [1, 2])).to eql 3
    end

    it 'ruby method sending' do
      code = <<EOD
(set! lp (ruby-eval "$LOAD_PATH"))
(.last lp)
EOD
      expect(eval(code)).to be_a String
    end

    it 'ruby method identifiers' do
      code = <<EOD
(define lps (list (ruby-eval "$LOAD_PATH")))
(map .last lps)
EOD
      r = eval(code)
      expect(r).to be_a Cons
      expect(r.h).to be_a String
      expect(r.t).to be nil
    end

    it 'map' do
      expect(eval("(map (lambda (x) (* x x)) '(1 2 3))")).to eql Cons.from_array([1,4,9])
    end

    it 'persists state intermittently' do
      # (ruby-eval "raise 'oops'")
      # (ruby-eval "puts 'press x to fail, any other key to succeed'")
      # (ruby-eval "if STDIN.readline.start_with?('x'); raise 'oops'; end")
      # (ruby-eval "unless $failed; $failed = true; raise 'oops'; end")
      code = <<EOD
(begin
  (set! a 1)
  (set! b (+ a 2))
  (set! c (+ b 3))
  (ruby-eval "unless $failed; $failed = true; raise 'oops'; end")
  (.call (ruby-eval "->(c) { puts 'c = ' + c.to_s }") c))
EOD

      log = []
      observer = Class.new do
        define_method(:returned) do |state|
          log << state
        end
      end.new
      begin
        eval(code, Env.new, observer)
      rescue => e
        puts e
        last_state = log.last
        rt_state = Oj.load(Oj.dump(last_state, mode: :object, circular: true), mode: :object, circular: true)
        puts "log size: #{log.size}"
        z = VM.resume(rt_state)
        puts "resume returned #{z.inspect}"
      end
    end

    def eval(code, env=Env.new, observer=nil)
      cs = CharStream.from(StringIO.new(code))
      ts = TokenStream.from(cs)
      ss = SexpStream.from(ts)
      result = nil
      ss.each do |exp|
        result = VM.eval(Compiler.new.compile(exp), env, observer: observer)
      end
      result
    end
  end
end
