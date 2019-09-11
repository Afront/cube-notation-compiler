### Grammar

\<turn> -> "U" | "D" | "L" | "R" | "F" | "B" |  "M" | "E" | "S" | "u" | "d" | "l" | "r" | "f" | "b"	 | "X" | "x" | "Y" | "y" | "Z" | "z" 
<symbol> ->  "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "'" 
<move> -> <turn><symbol> | <turn>
<subalg>-> <move>*
<alg-block> -> \(sub-alg\)<symbol> | \(sub-alg\)
<alg> -> (<alg-block> | <subalg>)*

<turn><symbol>|<turn> -> <move>


##### Rule 1: Turn -> Move
T -> t
tS -> t

##### Rule 2: Moves -> Sub-alg
t -> a
at -> a

##### Rule 3: Sub-alg ->  Alg block
(a) -> b
bS -> b

##### Rule 4 Alg-block and Sub-alg -> Alg
a -> A
b -> A
Aa -> A
