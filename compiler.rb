# frozen_string_literal: true

Token = Struct.new(:token, :type)
TurnToken = Struct.new(:token, :symbol, :type) do
  def simplify_symbols
    aSymbols = symbol
    num = -1
    if aSymbols.length == 1
      num = if aSymbols[0] == "'"
              3
            else
              aSymbols[0]
            end
    elsif aSymbols.length == 2
      num = aSymbols[0] == "'" ? 3 * (aSymbols[1] % 2) : 4 - (aSymbols[0] % 4)
      num = 1 if num == 0
    elsif aSymbols.empty?
      num = 0
    end	# no else
    return num unless num == -1
  end
end

CodeTkn = Struct.new(:turn, :symbol)

class Char
  attr_reader :c

  def initialize(c)
    @c = c
  end

  def isTurn
    @c =~ /U|D|L|R|F|B/
  end

  def isSlice
    @c =~ /M|E|S/
  end

  def isWide
    @c =~ /u|d|l|r|f|b/
  end

  def isRotation
    @c =~ /[X-Z]|[x-z]/
  end

  def isMove
    isTurn || isSlice || isWide || isRotation
  end

  def isSymbol
    @c =~ /([0-9]|')/
  end

  def isBracket
    @c =~ /[(-)]/
  end

  def is_valid_type
    isMove || isSymbol || isBracket
  end

  def find_type
    return 'T' if isMove
    return 'S' if isSymbol
    return 'B' if isBracket
  end
end

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

class Parser
  attr_reader :parse_stack
  def initialize(symbol_list)
    @symbol_list = symbol_list
    @parse_stack = []
    @type_stack = []
    @i = 0
    @next_s = ''
    @stop = false
    @prev_is_exp = false
    parse
  end

  def shift(symbol)
    @parse_stack.push(symbol)
    symbol.type == 'B' ? @type_stack.push(symbol.token) : @type_stack.push(symbol.type)
  end

  def rule_finder(string)
    # Rule 1: Turn+Symbol to Move
    index = (string =~ /(TS*)|(T|t)(S)+/)
    return [1, index] if index

    # Rule 2: Sub-alg ->  Alg block
    index = (string =~ /(\((A|t)+\)|bS)/)
    return [2, index] if index

    # Rule 3 Alg-block and Sub-alg -> Alg
    index = (string =~ /A*(b|t)+/)
    return [3, index] if index

    # Does not obey any rule
    0
  end

  def rule1
    # puts "#Rule 1: Turn+Symbol to Move"
    symbols = []
    while @i < @type_stack.length
      type = @type_stack[@i]
      token = @parse_stack[@i].token
      if type == 'T' || type == 't'
        turn = token
        if type == 't'
          @parse_stack[@i].symbol.each do |symbol|
            symbols.push(symbol) if symbol
          end
        end
      elsif type == 'S'
        if (token.is_a? Numeric) && (@next_s.token.is_a? Numeric)
          abort 'Syntax Error: Integer cannot follow another Integer! '
   end
        if @prev_is_exp	&& (@next_s.token.is_a? Numeric)
          abort "Syntax Error: An integer cannot follow an expression with both an integer and a symbol (n' and 'n)!"
   end
        a = @prev_is_exp
        @prev_is_exp = !a && (token == "'") ^ (@next_s.token == "'")
        symbols.push(token)
      else
        print "This shouldn't happen"
      end
      @type_stack.delete_at(@i)
      @parse_stack.delete_at(@i)
    end
    if symbols.length == 3
      abort "Syntax Error: A prime symbol (') cannot follow an expression with an integer and a symbol (n') due to ambiguity!"
 end
    symbols.push 1 unless (@next_s.type == 'S') || !symbols.empty?
    @type_stack.push('t')
    @parse_stack.push(TurnToken.new(turn, symbols, 't'))
  end

  def rule2
    #		puts "#Rule 2: Alg ->  Alg block"
    turns = []
    symbols = []

    while @i < @type_stack.length
      type = @type_stack[@i]
      token = @parse_stack[@i].token
      if type == 'b'
        turns = token
      elsif type == 'S'
        symbols.push(token)
      elsif type == '(' ||	type == ')'
      elsif type == 'A'
        turns += token
      else
        print type
        print "This shouldn't happen"
      end
      @type_stack.delete_at(@i)
      @parse_stack.delete_at(@i)
    end
    symbols.push 1 unless (@next_s.type == 'S') || !symbols.empty?
    @type_stack.push('b')
    @parse_stack.push(TurnToken.new(turns, symbols, 'b'))
  end

  def rule3
    #		puts "#Rule 3 Alg-block and turns -> Alg"
    turns = []
    return @stop = true if @next_s.type == 'S'

    while @i < @type_stack.length
      type = @type_stack[@i]
      token = @parse_stack[@i].token
      if type == 'A'
        turns = token
      elsif type == 'b' || type == 't'
        turns.push(@parse_stack[@i])
      elsif type == '$'
      else
        print type
        print "This shouldn't happen"
      end
      @type_stack.delete_at(@i)
      @parse_stack.delete_at(@i)
    end
    @type_stack.push('A')
    @parse_stack.push(Token.new(turns, 'A'))
  end

  def reduce
    rule = rule_finder(@type_stack.join)
    act_rule = rule[0]
    @i = rule[1].to_i
    return if act_rule == 0

    case act_rule
    when 1
      rule1
    when 2
      rule2
    when 3
      rule3
    else
      puts "This shouldn't happen"
    end
  end

  def accept
    if @type_stack == ['A'] then nil
    else
      print @type_stack
      puts 'YOOOOOOOOOO'
      @type_stack.each do |c|
        next unless c

        print 'Syntax error: ' + c + 'is not paired!'	if c != 'A'
      end
    end
  end

  def parse
    @symbol_list.push Token.new('$', '$')
    @symbol_list.each_cons(2) do |s, next_s|
      #			p "Current symbol: #{s.token} with type #{s.type}; Next symbol: #{next_s.token} with type #{next_s.type}"
      shift(s)
      @next_s = next_s
      reduce while (rule_finder(@type_stack.join) != 0) && !@stop
      @stop = false
    end
    accept
  end
end

class CodeGenerator
  attr_reader :code

  def initialize(parse_stack)
    @parse_stack = parse_stack
    @code = []
    generate
  end

  def simplifyToken(token_a)
    code = []
    if token_a.type == 't'
      return [CodeTkn.new(token_a.token, token_a.simplify_symbols)] unless token_a.simplify_symbols == 0
    elsif token_a.type == 'A'
      token_a.token.each do |token|
        code.push *simplifyToken(token)
      end
    elsif token_a.type == 'b'
      token_a.symbol = token_a[1] % 2 ? "'" : '' if token_a.symbol[0] == "'" && (token_a[1].is_a? Integer)
      if token_a.symbol.include? "'"
        token_a.token = token_a.token.reverse
        token_a.token.each do |subtoken|
          if subtoken.symbol.include? "'"
            subtoken.symbol.pop if subtoken.symbol[-1] == "'"
            subtoken.symbol.push(1) if subtoken.symbol.empty?
          elsif subtoken.symbol.length == 1
            subtoken.symbol = [4 - (subtoken.symbol[0] % 4)]
          else
            abort "This shouldn't happen!"
          end
        end
        token_a.symbol.pop
        token_a.symbol.push(1) if token_a.symbol.empty?
      end

      token_a.symbol[0].times do |_time|
        token_a.token.each do |token|
          code.push *simplifyToken(token)
        end
      end
    else
      raise "This shouldn't happen"
    end
    code
  end

  def generate
    @code = simplifyToken(@parse_stack[0])
  	raise if @code.nil?
  end
end

class CodeOptimizer
  attr_reader :optimized_code

  def initialize(generated_code)
    @generated_code = generated_code
    @optimized_code = []
    optimize
  end

  def optimize
    turn_list = []
    symbol_list = []
    @generated_code.each do |token|
      if token.turn != turn_list[-1]
        turn_list.push token.turn
        symbol_list.push token.symbol
      else
        symbol_list[-1] = (symbol_list[-1] + token.symbol)
      end
    end
    @optimized_code = [turn_list, symbol_list]
  end
end

class TargetCodeGenerator
  attr_reader :target_code

  def initialize(optimized_code)
    @optimized_code = optimized_code
    @target_code_a = []
    generate
    @target_code = @target_code_a.join
    IO.write('.output', @target_code)
#    File.delete('.input') if File.exist?('.input')
  end

  def generate
    @optimized_code[0].length.times do |token|
      @target_code_a.push @optimized_code[0][token]
      @target_code_a.push @optimized_code[1][token]
    end
  end
end

class Interpreter
  attr_reader :final_code

  def initialize(text = File.read('.input'))
    @text = text
    lexer = Lexer.new text
    parser = Parser.new lexer.symbol_list 
    code_generator = CodeGenerator.new parser.parse_stack
    code_optimizer = CodeOptimizer.new code_generator.code
    target_code_generator = TargetCodeGenerator.new code_optimizer.optimized_code
  end
end

i = Interpreter.new
