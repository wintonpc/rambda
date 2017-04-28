module Rambda
  module TokenStream
    def from(char_stream)
      Enumerator.new do |y|
        t = ''
        flush = proc do
          unless t.empty?
            y << t
            t = ''
          end
        end
        emit = proc do |t|
          y << t
        end
        char_stream.each do |c|
          case c
          when '(', ')', '[', ']'
            flush.()
            emit.(c)
          when ' ', "\n"
            flush.()
          else
            t += c
          end
        end
        flush.()
      end
    end

    extend self
  end
end
