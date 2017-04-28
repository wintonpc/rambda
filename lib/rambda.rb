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
  # Your code goes here...
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
