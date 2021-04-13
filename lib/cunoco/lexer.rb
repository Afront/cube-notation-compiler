module Cunoco
  class Lexer
    attr_reader :symbol_list
    def initialize input
      @symbol_list = []
      @input = input
      lex
    end

    def lex
      input = @input
      turns = input.gsub(/(\t|\r|\n)+/, '') # .gsub(/\s+/, "")

      num_list = [0, 0]
      full_num_list = [] # HC'd this list because I overlooked the period for other algorithms
      prime = false
      turns.each_char do |char|
        c = Char.new(char)
        if c.c == '.' && !num_list.empty?
          abort "Lexical Error: #{c.c} is not valid! (Corner cutting has not been implemented yet 😉)"
    end
        abort "Lexical Error: #{c.c} is not a valid character!" unless c.c == ' ' || c.is_valid_type
        type = c.find_type
        if type == 'S'
          if c.c =~ /[[:digit:]]/
            num_list[0] = num_list[1]
            num_list[1] = c.c
            full_num_list.push c.c

            if prime
              @symbol_list.push(Token.new("'", 'S'))
              prime = false
            end
          else
            prime = !prime
            unless full_num_list.empty? # originally unless num_list == [0,0]
              if @symbol_list[-1].type == 'T'
                @symbol_list.push(Token.new(num_list.join.to_i % 4, 'S'))
              else
                @symbol_list.push(Token.new(full_num_list.join.to_i, 'S'))
              end
              num_list = [0, 0]
              full_num_list.clear
            end
          end
        else
          unless full_num_list.empty? # originally unless num_list == [0,0]
            if @symbol_list[-1].type == 'T'
              @symbol_list.push(Token.new(num_list.join.to_i % 4, 'S'))
            else
              @symbol_list.push(Token.new(full_num_list.join.to_i, 'S'))
            end
            num_list = [0, 0]
            full_num_list.clear
          end

          if prime
            @symbol_list.push(Token.new("'", 'S'))
            prime = false
          end

          next if c.c == ' '

          @symbol_list.push(Token.new(c.c, type))
        end
      end
      unless full_num_list.empty?
        if @symbol_list[-1].type == 'T'
          @symbol_list.push(Token.new(num_list.join.to_i % 4, 'S'))
        else
          @symbol_list.push(Token.new(full_num_list.join.to_i, 'S'))
        end
      end
      if prime
        @symbol_list.push(Token.new("'", 'S'))
        prime = false
      end
    end
  end
end 