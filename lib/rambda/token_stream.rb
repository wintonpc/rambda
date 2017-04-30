module Rambda
  module TokenStream
    def from(char_stream)
      Enumerator.new do |y|
        t = ''

        flush = proc do
          unless t.empty?
            y << read_value(t)
            t = ''
          end
        end

        emit = proc do |t|
          y << t
        end

        read_string = nil
        eat_comment = nil

        read_tokens = proc do
          while true
            c = char_stream.next
            case c
            when '(', ')', '[', ']', "'", '`'
              flush.()
              emit.(c)
            when ','
              flush.()
              if char_stream.peek == '@'
                char_stream.next
                emit.(',@')
              else
                emit.(c)
              end
            when '"'
              t += '"'
              read_string.()
              flush.()
            when ';'
              eat_comment.()
            when ' ', "\n"
              flush.()
            else
              if c == '.' && t == '' && char_stream.peek == ' '
                flush.()
                emit.(c)
              else
                t += c
              end
            end
          end
        end

        read_string = proc do
          escaped = false
          while true
            c = char_stream.next
            if c == '"' && !escaped
              break
            elsif c == "\\" && !escaped
              escaped = true
            else
              t += c
              escaped = false
            end
          end
        end

        eat_comment = proc do
          until char_stream.next == "\n"; end
        end

        begin
          read_tokens.()
        rescue StopIteration
        end
        flush.()
      end
    end

    def read_value(x)
      i = try_parse_int(x)
      return i if i
      f = try_parse_float(x)
      return f if f
      str = try_parse_string(x)
      return str if str
      b = try_parse_bool(x)
      return b unless b.nil?
      x.to_sym
    end

    def try_parse_int(x)
      Integer(x)
    rescue ArgumentError
      nil
    end

    def try_parse_float(x)
      Float(x)
    rescue ArgumentError
      nil
    end

    def try_parse_string(x)
      x[1..-1] if x[0] == '"'
    end

    def try_parse_bool(x)
      case x
      when '#t'
        true
      when '#f'
        false
      else
        nil
      end
    end

    extend self
  end
end
