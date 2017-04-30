require 'rambda/version'
require 'rambda/char_stream'
require 'rambda/token_stream'
require 'rambda/sexp_stream'
require 'rambda/repl'
require 'rambda/pretty'
require 'rambda/compiler'
require 'rambda/vm'
require 'rambda/env'
require 'rambda/closure'
require 'rambda/built_in'

module Rambda
  def eval(code, env=Env.new, observer: nil)
    cs = CharStream.from(StringIO.new(code))
    ts = TokenStream.from(cs)
    ss = SexpStream.from(ts)
    result = nil
    compiler = Compiler.new(env)
    ss.each do |exp|
      # puts "Rambda.eval #{exp}"
      result = VM.eval(compiler.compile(exp), env, observer: observer)
    end
    result
  end

  def apply(p, *args, env, observer: nil)
    VM.apply(p, env, args, observer: observer)
  end

  extend self
end

def repl
  Rambda::Repl.run
end

class Proc
  def inspect
    fn, line = source_location
    "#<Proc@#{File.basename(fn)}:#{line}>"
  end
end

Rambda::BuiltIn.register_stdlib(Rambda::Env.built_in)
