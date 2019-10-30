# Cube Notation Compiler
*Version 1.0*

*Note: I'm currently working on Version 2.0, which is rewritten from scratch. It will be ported to C++ and/or Rust later on. It will be released by the end of November.*


This Ruby script compiles the Extended Singmaster Notation for the Rubik's cube into a simpler notation. The Extended Singmaster Notation is further explained in [notation.md](notation.md). In the simplified notation, there are no parentheses, and a turn is always paired with the number of times the turn would be done. The grammar used for the lexer and the parser is in [grammar.md](grammar.md). This compiler is originally written for the Cubing Analysis and Testing Suite (cats).

## Known Issues and Possible Improvements
Here are some current issues with the project:
  - Does not support face slice and anti-slice moves, conjugates, and commutators yet
  - Has not been refactored and optimized therefore it has a lot of code smell and can be made shorter (possibly down to 200 lines from 413 lines).
  - Can possibly skip and merge some steps like code optimization since the grammar is simple.
  - Uses Ruby, which might be an issue for some people due to it being an interpreted language.
  - Determining the modularity/period of an algorithm can make the program compile faster.
  - Has not been tested or validated fully yet
  
## Getting Started
The compiler is originally written for software that doesn't use Ruby, so it requires an external file called '.input' that contains a string of moves. The output would be the simplified string of moves stored in the file '.output'. It is important to note that the program  deletes the input file afterwards. 

## License
This project is licensed under the BSD 3-Clause Clear License (License.MD would be uploaded later).
