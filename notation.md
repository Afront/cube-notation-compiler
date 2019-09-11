### Extended Singmaster Notation

*Important Note: Does not support conjugates and commutators yet*

The notation this program uses is an extended form of the standard Singmaster Notation.
The moves in the Extended Singmaster Notation are the following:

* Face turns: F/B, L/R, U/D
* Double-face turns : f/b, l/r, u/d
* Rotations: x,y,z
* Slice moves: M, E, S, Fs/Bs, Ls/Rs, Us/Ds
* Anti-slice: Fa/Ba, La/Ra, Ua/Da
* Conjugate: [A: B] (= A B A')
* Commutator: [A, B] (= A B A' B')

Face slice and anti-slice moves, conjugates, and commutators have not been implemented to the parser as of now.

The moves can be paired with a symbol, which can be an integer or a prime symbol (').

This is how the symbol works in this notation:
* Positive Integer (n): Does a move n times
* Negative Integer (n): Does the move the other way n times, equivalent to n' (Not yet implemented) 
* Prime symbol ('): Does the inverse of the object it is applied to.

Combining the symbols with each other will result in the following:
* Integer + Integer: Error
* Integer + Prime symbol (n'): Equivalent to 4-(n%4), Does a move n amount of times the other way.
* Prime symbol + Integer ('n): Equivalent to ''''...''' where ' is repeated n amount of times.
* Prime symbol + Prime symbol (''): Equivalent to not having a prime symbol. An inverse of an inverse will result in the original state.

The following combinations are invalid:
* n (Integer) + n (Integer)
* n' (Integer + Prime symbol) + n (Integer)
* 'n (Integer + Prime symbol) + n (Integer)
* 'n (Integer + Prime symbol) + ' (Prime symbol): Due to ambiguity
