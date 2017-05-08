require 'rambda/closure'
require 'rambda/cons'
require 'thread'
require 'securerandom'

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
        prim(:'join') { |delim, xs| xs.join(delim) }
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
        prim(:sleep) { |seconds| sleep(seconds) }
        prim(:'vector->list') { |v| Cons.from_array1(v) }
        prim(:'list->vector') { |v| Cons.to_array1(v) }
        prim(:'string->symbol') { |str| str.to_sym }
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
        prim(:puts) { |*args| print "#{args.join}\n" }
        prim(:pp) { |*args| print "#{args.map { |x| x.is_a?(String) ? x : Pretty.print(x) }.join}\n" }

        # evaluate ruby code
        prim(:'ruby-eval') { |str| Kernel.eval(str) }
        prim(:'rubify') { |x| rubify(x) }

        # pass scheme values into ruby code
        prim(:'ruby-call') { |p, *args| schemify(p.call(*args.map(&method(:rubify)))) }
        prim(:'ruby-call-proc') { |rcode, *args| schemify(Kernel.eval("proc {#{rcode}}").call(*args.map(&method(:rubify)))) }

        special_prim(:'%#current-environment') do |vm_info|
          vm_info.environment
        end

        special_prim(:'%#async') do |vm_info, p|
          unless p.is_a?(Closure)
            raise "async: argument must be a closure but was: #{p.inspect}"
          end
          if p.formals != nil
            raise 'async: argument must be a parameterless closure'
          end
          env = Env.new(vm_info.environment)
          env.read_only = true
          ae = AsyncExpr.new
          ae.proc = p
          ae.env = env
          ae.mutex = Mutex.new
          ae.vm_id = SecureRandom.hex(4)
          spawn_async(ae, vm_info.observer)
        end

        prim(:'wait') do |ae|
          ae.thread.join
          if ae.exception
            raise ae.exception
          else
            ae.value
          end
        end

        prim(:'wait-all') do |aes|
          aes = Cons.to_array1(aes)
          aes.map(&:thread).map(&:join)
          exception = aes.map(&:exception).compact.first
          if exception
            raise exception
          else
            Cons.from_array1(aes.map(&:value))
          end
        end

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

    def spawn_async(ae, observer)
      kick_async(ae) do
        VM.apply(ae.proc, ae.env, nil, observer: observer, vm_id: ae.vm_id)
      end
    end

    def resume_async(ae, state, observer)
      kick_async(ae) do
        VM.resume(state, observer: observer, vm_id: ae.vm_id)
      end
    end

    def kick_async(ae, &block)
      m = ae.mutex
      startup = Mutex.new
      startup.synchronize do
        t = Thread.start do
          startup.synchronize {} # don't let the thread start until ae.thread has been set
          begin
            value = block.call
            m.synchronize { ae.value = value }
            # TODO: need to trigger persist for parent VM to update future
            value
          rescue => e
            m.synchronize { ae.exception = e }
          ensure
            m.synchronize { ae.done = true}
          end
        end
        m.synchronize { ae.thread = t }
      end
      ae
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
      elsif x.is_a?(Hash)
        x.map { |(k, v)| [k, rubify(v)] }.to_h
      else
        x
      end
    end

    def prim(name, &block)
      @primitives[name] = Primitive.new(name, block)
    end

    def special_prim(name, &block)
      @primitives[name] = Primitive.new(name, block, true)
    end

    extend self
  end
end
