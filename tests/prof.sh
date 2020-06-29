cd ..
export RBS_TEST_TARGET='Token,TurnToken,CodeTkn,Char,Lexer,Parser,CodeGenerator,CodeOptimizer,TargetCodeGenerator,Interpreter'
ruby -r rbs/test/setup tests/prof.rb