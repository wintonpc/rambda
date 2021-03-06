require 'rambda/cons'

module Rambda
  module SexpStream
    def from(token_stream)
      Enumerator.new do |y|
        begin
          while true
            read = lambda do
              t = token_stream.next
              case t
              when '(', '[', '{'
                s = nil
                while true
                  if token_stream.peek == ')' || token_stream.peek == ']' || token_stream.peek == '}'
                    token_stream.next
                    s = reverse_list(s, nil)
                    break
                  elsif token_stream.peek == '.'
                    token_stream.next # .
                    last = read.()
                    closer = token_stream.next
                    raise 'Invalid dotted notation' if closer != ')' && closer != ']' && closer != '}'
                    s = reverse_list(s, last)
                    break
                  else
                    s = Cons.new(read.(), s)
                  end
                end
                if t == '{'
                  zs = Cons.to_array1(s).each_slice(2).map do |(k, v)|
                    [k.is_a?(Symbol) ? Cons.from_array1([:quote, k]) : k, v]
                  end.flatten
                  zs.unshift(:'make-map')
                  Cons.from_array1(zs)
                else
                  s
                end
              when "'"
                Cons.from_array([:quote, read.()])
              when '`'
                Cons.from_array([:quasiquote, read.()])
              when ','
                Cons.from_array([:unquote, read.()])
              when ',@'
                Cons.from_array([:'unquote-splicing', read.()])
              else
                t
              end
            end
            y << read.()
          end
        rescue StopIteration
        end
      end
    end

    private

    def reverse_list(list, tail)
      if list.nil?
        tail
      else
        reverse_list(list.t, Cons.new(list.h, tail))
      end
    end

    extend self
  end
end
