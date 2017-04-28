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
              when '('
                s = []
                while true
                  s << read.()
                  if token_stream.peek == ')'
                    token_stream.next
                    break
                  end
                end
                Cons.from_array(s)
              when "'"
                Cons.from_array([:quote, read.()])
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

    extend self
  end
end
