module Rambda
  module CharStream
    def from(io)
      Enumerator.new do |y|
        begin
          while true
            c = io.readchar
            # puts "CharStream read #{c.inspect}"
            y << c
          end
        rescue EOFError
          # puts 'CharStream got EOFError'
        end
      end
    end

    extend self
  end
end
