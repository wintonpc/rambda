require 'rambda/closure'
require 'rambda/cons'

module Rambda
  module BuiltIn
    def primitives
      unless @primitives
        @primitives = {}
        prim(:+) { |*args| args.reduce(0, :+) }
        prim(:-) do |*args|
          if args.size == 1
            -args[0]
          else
            args[0] - args[1..-1].reduce(0, :+)
          end
        end
        prim(:*) { |a, b| a * b }
        prim(:<) { |a, b| a < b }
        prim(:<=) { |a, b| a <= b }
        prim(:>) { |a, b| a > b }
        prim(:>=) { |a, b| a >= b }
        prim(:abs) { |a| a.abs }
        prim(:'++') { |*xs| xs.map(&:to_s).join }
        prim(:eq?) { |a, b| a == b }
        prim(:not) { |a| !a }
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
        prim(:pair?) { |x| x.is_a?(Cons) }
        prim(:'make-map') { |*kvs| kvs.each_slice(2).to_h }
        prim(:gensym) do
          $last_gensym ||= 0
          $last_gensym += 1
          "%#t#{$last_gensym}".to_sym
        end
        prim(:'vector->list') { |v| Cons.from_array1(v) }
        prim(:'list->vector') { |v| Cons.to_array1(v) }
        prim(:'append-lists') do |xss|
          al = nil
          al = proc do |current, rest|
            if current.nil?
              if rest.nil?
                nil
              else
                al.call(rest.h, rest.t)
              end
            else
              Cons.new(current.h, al.call(current.t, rest))
            end
          end
          al.call(nil, xss)
        end

        prim(:void) { Void }
        prim(:puts) { |*args| puts args.join }

        # evaluate ruby code
        prim(:'ruby-eval') { |str| Kernel.eval(str) }

        # pass scheme values into ruby code
        prim(:'ruby-call') { |p, *args| schemify(p.call(*args.map(&method(:rubify)))) }
        prim(:'ruby-call-proc') { |rcode, *args| schemify(Kernel.eval("proc {#{rcode}}").call(*args.map(&method(:rubify)))) }
      end
      @primitives
    end

    def get_sender(method)
      @senders ||= {}
      @senders.fetch(method) do
        @senders[method] = Sender.new(method, lambda { |receiver, *args| schemify(receiver.send(method, *args.map(&method(:rubify)))) })
      end
    end

    def register_stdlib(env)
      Rambda.eval(File.read(File.expand_path('../stdlib.ss', __FILE__)), env)
    end

    private

    def schemify(x)
      if arrayish?(x)
        Cons.from_array1(x)
      else
        x
      end
    end

    def arrayish?(x)
      x.is_a?(Array) || (x.is_a?(Enumerable) && x.respond_to?(:reverse!))
    end

    def rubify(x)
      if x.is_a?(Cons)
        Cons.to_array1(x)
      else
        x
      end
    end

    def prim(name, &block)
      @primitives[name] = Primitive.new(name, block)
    end

    extend self
  end
end
