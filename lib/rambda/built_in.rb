require 'rambda/closure'
require 'rambda/cons'

module Rambda
  module BuiltIn
    def primitives
      unless @primitives
        @primitives = {}
        prim(:+) { |a, b| a + b }
        prim(:*) { |a, b| a * b }
        prim(:eq?) { |a, b| a == b }
        prim(:nil?) { |a| a.nil? }
        prim(:cons) { |h, t| Cons.new(h, t) }
        prim(:car) do |c|
          c.is_a?(Cons) or raise "Not a pair: #{Pretty.print(c)}"
          c.h
        end
        prim(:cdr) do |c|
          c.is_a?(Cons) or raise "Not a pair: #{Pretty.print(c)}"
          c.t
        end
        prim(:list) { |*vs| Cons.from_array1(vs) }
        prim(:'vector->list') { |v| Cons.from_array1(v) }

        # evaluate ruby code
        prim(:'ruby-eval') { |str| Kernel.eval(str) }

        # pass scheme values into ruby code
        prim(:'ruby-call') { |p, *args| p.call(*args) }
        prim(:'ruby-call-proc') { |rcode, *args| Kernel.eval("proc {#{rcode}}").call(*args) }
      end
      @primitives
    end

    def get_sender(method)
      @senders ||= {}
      @senders.fetch(method) do
        @senders[method] = Sender.new(method, lambda { |receiver, *args| receiver.send(method, *args) })
      end
    end

    def register_stdlib(env)
      Rambda.eval(File.read(File.expand_path('../stdlib.ss', __FILE__)), env)
    end

    private

    def prim(name, &block)
      @primitives[name] = Primitive.new(name, block)
    end

    extend self
  end
end
