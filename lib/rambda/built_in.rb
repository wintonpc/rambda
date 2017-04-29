require 'rambda/closure'

module Rambda
  module BuiltIn
    def primitives
      unless @primitives
        @primitives = {}
        prim(:+) { |a, b| a + b }
        prim(:*) { |a, b| a * b }

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

    private

    def prim(name, &block)
      @primitives[name] = Primitive.new(name, block)
    end

    extend self
  end
end
