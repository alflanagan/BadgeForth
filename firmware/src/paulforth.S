/*  -*- asm -*-
	 _______ _______         _       _______ _______ ________________
	(  ____ |  ___  )\     /( \     (  ____ (  ___  |  ____ )__   __/\     /|
	| (    )| (   ) | )   ( | (     | (    \/ (   ) | (    )|  ) (  | )   ( |
	| (____)| (___) | |   | | |     | (__   | |   | | (____)|  | |  | (___) |
	|  _____)  ___  | |   | | |     |  __)  | |   | |     __)  | |  |  ___  |
	| (     | (   ) | |   | | |     | (     | |   | | (\ (     | |  | (   ) |
	| )     | )   ( | (___) | (____/\ )     | (___) | ) \ \__  | |  | )   ( |
	|/      |/     \(_______|_______//      (_______)/   \__/  )_(  |/     \|


	(Credit for ASCII art: http://patorjk.com/software/taag/)

	-----------------------------------------------------------------------------------
	jonesforth is a combination tutorial/implementation for the Forth language which
	runs on i386 under Linux. Paulforth is essentially a port of jonesforth for the
	MIPS32 architecture. The original credit for jonesforth is:
	-----------------------------------------------------------------------------------
	A sometimes minimal FORTH compiler and tutorial for Linux / i386 systems.
	By Richard W.M. Jones <rich@annexia.org> http://annexia.org/forth
	This is PUBLIC DOMAIN (see public domain release statement below).
	-----------------------------------------------------------------------------------
	Port to MIPS32 assembly by Paul Bruggeman (paul@killercats.com).
	-----------------------------------------------------------------------------------
	Documentation adapted for MIPS32 by Adrian L. Flanagan.
	-----------------------------------------------------------------------------------
	All additions/modifications to this file are also covered by the original license
	statement below.

	INTRODUCTION ----------------------------------------------------------------------

	FORTH is one of those alien languages which most working programmers regard in the same
	way as Haskell, LISP, and so on.  Something so strange that they'd rather any thoughts
	of it just go away so they can get on with writing this paying code.  But that's wrong
	and if you care at all about programming then you should at least understand all these
	languages, even if you will never use them.

	LISP is the ultimate high-level language, and features from LISP are being added every
	decade to the more common languages.  But FORTH is in some ways the ultimate in low level
	programming.  Out of the box it lacks features like dynamic memory management and even
	strings.  In fact, at its primitive level it lacks even basic concepts like IF-statements
	and loops.

	Why then would you want to learn FORTH?  There are several very good reasons.  First and
	foremost, FORTH is minimal.  You really can write a complete FORTH in, say, 2000 lines of
	code.  I don't just mean a FORTH program, I mean a complete FORTH operating system,
	environment and language.  You could boot such a FORTH on a bare PC and it would come up
	with a prompt where you could start doing useful work.  The FORTH you have here isn't
	minimal but does run on a "bare" MIPS32 system. It's possible to completely understand the
	system.  Who can say they completely understand how Linux works, or gcc?

	Secondly FORTH has a peculiar bootstrapping property.  By that I mean that after writing
	a little bit of assembly to talk to the hardware and implement a few primitives, all the
	rest of the language and compiler is written in FORTH itself.  Remember I said before
	that FORTH lacked IF-statements and loops?  Well of course it doesn't really because
	such a lanuage would be useless, but my point was rather that IF-statements and loops are
	written in FORTH itself.

	Now of course this is common in other languages as well, and in those languages we call
	them 'libraries'.  For example in C, 'printf' is a library function written in C.  But
	in FORTH this goes way beyond mere libraries.  Can you imagine writing C's 'if' in C?
	And that brings me to my third reason: If you can write 'if' in FORTH, then why restrict
	yourself to the usual if/while/for/switch constructs?  You want a construct that iterates
	over every other element in a list of numbers?  You can add it to the language.  What
	about an operator which pulls in variables directly from a configuration file and makes
	them available as FORTH variables?  Or how about adding Makefile-like dependencies to
	the language?  No problem in FORTH.  How about modifying the FORTH compiler to allow
	complex inlining strategies -- simple.  This concept isn't common in programming languages,
	but it has a name (in fact two names): "macros" (by which I mean LISP-style macros, not
	the lame C preprocessor) and "domain specific languages" (DSLs).

	This tutorial isn't about learning FORTH as the language.  I'll point you to some references
	you should read if you're not familiar with using FORTH.  This tutorial is about how to
	write FORTH.  In fact, until you understand how FORTH is written, you'll have only a very
	superficial understanding of how to use it.

	So if you're not familiar with FORTH or want to refresh your memory here are some online
	references to read:

	http://en.wikipedia.org/wiki/Forth_%28programming_language%29

	http://galileo.phys.virginia.edu/classes/551.jvn.fall01/primer.htm

	http://wiki.laptop.org/go/Forth_Lessons

	http://www.albany.net/~hello/simple.htm

	Here is another "Why FORTH?" essay: http://www.jwdt.com/~paysan/why-forth.html

	Discussion and criticism of jonesforth here: http://lambda-the-ultimate.org/node/2452

	Discussion and criticism of paulforth currently takes place on the HackRVA mailing list
	http://lists.hackrva.org/mailman/listinfo/hack.rva. HackRVA is the original makerspace
	for Richmond, Virginia. We have a yearly project to produce electronic badges for the
	RVASec security conference (http://rvasec.com). Those badges (principal designer: Paul
	Bruggeman) use MicroChip PIC32MX microcontrollers. Paulforth was originally ported as
	a fun alternative to C programming for the badge.


	ACKNOWLEDGEMENTS ----------------------------------------------------------------------

	This code (including these comments) is completely based on jonesforth. The original
	acknowledgements for jonesforth follow.

	This code draws heavily on the design of LINA FORTH (http://home.hccnet.nl/a.w.m.van.der.horst/lina.html)
	by Albert van der Horst.  Any similarities in the code are probably not accidental.

	Some parts of this FORTH are also based on this IOCCC entry from 1992:
	http://ftp.funet.fi/pub/doc/IOCCC/1992/buzzard.2.design.  I was very proud when Sean
	Barrett, the original author of the IOCCC entry, commented in the LtU thread
	http://lambda-the-ultimate.org/node/2452#comment-36818 about this FORTH.

	And finally I'd like to acknowledge the (possibly forgotten?) authors of ARTIC FORTH because
	their original program which I still have on original cassette tape kept nagging away at me
	all these years.  http://en.wikipedia.org/wiki/Artic_Software

	PUBLIC DOMAIN -------------------------------------------------------------------------

	We, the copyright holders* of this work, hereby release it into the public domain. This applies worldwide.

	In case this is not legally possible, we grant any entity the right to use this work for any
	purpose, without any conditions, unless such conditions are required by law.

	* The copyright holder for the MIPS32 code is Paul Bruggeman. The holder for much of the Forth code is
	probably still Walter Jones, and he also has copyright to the vast majority of the comments.

	SETTING UP ----------------------------------------------------------------------------

	Let's get a few housekeeping things out of the way.  Firstly because I need to draw lots of
	ASCII-art diagrams to explain concepts, the best way to look at this is using a window which
	uses a fixed width font and is at least this wide:

 <------------------------------------------------------------------------------------------------------------------------>

	Secondly make sure TABS are set to 8 characters.  The following should be a vertical
	line.  If not, sort out your tabs.

		|
	        |
	    	|

	Thirdly I assume that your screen is at least 50 characters high.

	ASSEMBLING ----------------------------------------------------------------------------

	If you want to actually run this FORTH, rather than just read it, you will need a MIPS32
	microprocessor, a device to program it, and software to turn it into an appropriate binary
	image. NOTE: if you want to run this on Linux on the x86 architecture (certainly easier),
	you want the original jonesforth by Walter Jones.

	For purposes of this discussion, I assume the assembler is based on the GNU assembler, gas,
	and will refer to it by that name. (Have to call it something). If this doesn't compile and
	work as-is, you'll need to discover the notation used by your assembler and change it
	accordingly.

	Unfortunately for tutorial purposes, I can't guess what commands and procedures are needed
	to get Paulforth onto your hardware environment. You would know much better than I would.

	ASSEMBLER ----------------------------------------------------------------------

	(You can just skip to the next section -- you don't need to be able to read assembler to
	follow this tutorial).

	However if you do want to read the assembly code here are a few notes about MIPS32 assembly
	code:

	(1) Register names are prefixed with '$', and there are 32 of them, each 32 bits in size.
	    A couple of them have special functions in the hardware, and the rest are divided by
	    convention for use for various purposes. The ones the Forth system will use are $S4 through
	    $S8, and as far as the hardware is concerned they all behave alike; the difference is only
	    in how we use each one.

	(2) Add, mv, etc. take arguments in the form DEST,SRC.  So mv $S6,$S7 moves $S7 ->
	    $S8. Think of it like the program statement "$S7 = $S8".

	(3) gas has a funky syntax for local labels, where '1f' (etc.) means label '1:' "forwards"
	    and '1b' (etc.) means label '1:' "backwards".  Notice that these labels might be mistaken
	    for hex numbers (eg. you might confuse 1b with $0x1b).

	(4) The macro syntax here is based on gas, the GNU assembler. Your development tool may
	    support a different dialect, check your documentation.

	Now the tutorial starts in earnest.

	THE DICTIONARY ----------------------------------------------------------------------

	In FORTH as you will know, functions are called "words", and just as in other languages they
	have a name and a definition.  Here are two FORTH words:

	: DOUBLE DUP + ;		\ name is "DOUBLE", definition is "DUP +"
	: QUADRUPLE DOUBLE DOUBLE ;	\ name is "QUADRUPLE", definition is "DOUBLE DOUBLE"

	Words, both built-in ones and ones which the programmer defines later, are stored in a dictionary
	which is just a linked list of dictionary entries.

	<--- DICTIONARY ENTRY (HEADER) ----------------------->
	+------------------------+--------+---------- - - - - +----------- - - - -
	| LINK POINTER           | LENGTH/| NAME	      | DEFINITION
	|			 | FLAGS  |     	      |
	+--- (4 bytes) ----------+- byte -+- n bytes  - - - - +----------- - - - -

	I'll come to the definition of the word later.  For now just look at the header.  The first
	4 bytes are the link pointer.  This points back to the previous word in the dictionary, or,
	for the first word in the dictionary it is just a NULL pointer.  Then comes a length/flags
	byte.  The length of the word can be up to 31 characters (5 bits used) and the top three
	bits are used for various flags which I'll come to later.  This is followed by the name
	itself, and in this implementation the name is rounded up to a multiple of 4 bytes by
	padding it with zero bytes.  That's just to ensure that the definition starts on a 32 bit
	boundary.

	A FORTH variable called LATEST contains a pointer to the most recently defined word, in
	other words, the head of this linked list.

	DOUBLE and QUADRUPLE might look like this:

	  pointer to previous word
	   ^
	   |
	+--|------+---+---+---+---+---+---+---+---+------------- - - - -
	| LINK    | 6 | D | O | U | B | L | E | 0 | (definition ...)
	+---------+---+---+---+---+---+---+---+---+------------- - - - -
	   ^       len                         padding
	   |
	+--|------+---+---+---+---+---+---+---+---+---+---+---+---+------------- - - - -
	| LINK    | 9 | Q | U | A | D | R | U | P | L | E | 0 | 0 | (definition ...)
	+---------+---+---+---+---+---+---+---+---+---+---+---+---+------------- - - - -
	   ^       len                                     padding
	   |
	   |
	  LATEST

	You should be able to see from this how you might implement functions to find a word in the
	dictionary (just walk along the dictionary entries starting at LATEST and matching the names
	until you either find a match or hit the NULL pointer at the end of the dictionary); and add
	a word to the dictionary (create a new definition, set its LINK to LATEST, and set LATEST to
	point to the new word).  We'll see precisely these functions implemented in assembly code
	later on.

	One interesting consequence of using a linked list is that you can redefine words, and a
	newer definition of a word overrides an older one.  This is an important concept in FORTH
	because it means that any word (even "built-in" or "standard" words) can be overridden with
	a new definition, either to enhance it, to make it faster or even to disable it.  However
	because of the way that FORTH words get compiled, which you'll understand below, words
	defined using the old definition of a word continue to use the old definition.  Only words
	defined after the new definition use the new definition.

	DIRECT THREADED CODE ----------------------------------------------------------------------

	Now we'll get to the really crucial bit in understanding FORTH, so go and get a cup of tea
	or coffee and settle down.  It's fair to say that if you don't understand this section, then
	you won't "get" how FORTH works, and that would be a failure on my part for not explaining
	it well.  So if after reading this section a few times you don't understand it, please email
	me (rich@annexia.org). (Or his humble MIPS32 translator, a.lloyd.flanagan@gmail.com).

	Let's talk first about what "threaded code" means.  Imagine a peculiar version of C where
	you are only allowed to call functions without arguments.  (Don't worry for now that such a
	language would be completely useless!)  So in our peculiar C, code would look like this:

	f ()
	{
	  a ();
	  b ();
	  c ();
	}

	and so on.  How would a function, say 'f' above, be compiled by a standard C compiler?
	Probably into assembly code like this.  On the right hand side I've written the actual
	MIPS32 machine code (in little-endian order).

	f:
	  JAL	a			0C 00 00 08
	  JAL	b			0C 00 00 1C
	  JAL	c			0C 00 00 2C
	  ; ignore the return from the function for now
	  ; your assembler may print the machine code "backwards" depending on endianness it uses

	"0C" is the machine code to "jump and link" a function.  The entire opcode is actually the
	first 6 bits; the remaining 26 bits are the funtion address.

	In the first 20 years of computing memory was
	hideously expensive and we might have worried about the wasted space being used by the
	repeated "0C" six bits.  We can save 18.75% in code size (and therefore, in expensive
	memory) by compressing this into just:

	08 00 00		Just the function addresses, without
	1C 00 00		the jal prefix.
	2C 00 00

	On a 16-bit machine like the ones which originally ran FORTH the savings are even greater - 33%.

	[Historical note: If the execution model that FORTH uses looks strange from the following
	paragraphs, then it was motivated entirely by the need to save memory on early computers.
	This code compression isn't so important now when our machines have more memory in their L1
	caches than those early computers had in total, but the execution model still has some
	useful properties].

	Of course this code won't run directly on the CPU any more.  Instead we need to write an
	interpreter which takes each set of bytes and calls it.

	On a MIPS32 machine it turns out that we can write this interpreter rather easily, in just
	two assembly instructions which turn into just 8 bytes of machine code.  Let's store the
	pointer to the next word to execute in the $S7 register:

		08 00 00 00	<- We're executing this one now.  $S7 is the _next_ one to execute.
	$S7 ->	1C 00 00 00
		2C 00 00 00

	The all-important MIPS instructions are called LW and ADDIU. LW reads the memory at $S7 into
	the accumulator ($S6).  ADDIU increments $S7 by 4 bytes.  So after LW, ADDIU, the situation
	now looks like this:

		08 00 00 00	<- We're still executing this one
		1C 00 00 00	<- $S6 now contains this address (0x0000001C)
	$S7 ->	2C 00 00 00

	Now we just need to jump to the address in $S6. Since MIPS is a RISC chip, that takes 2
	instructions, load memory to register (LW) and jump (JR) And after doing the jump, the
	situation looks like:

		08 00 00 00
		1C 00 00 00	<- Now we're executing this subroutine.
	$S7 ->	2C 00 00 00

	To make this work, each subroutine is followed by the four instructions:

	lw	$s6, 0($s7)
	addiu	$s7, $s7, 4
	lw	$t0, 0($s6)
	jr	$t0

	Note the use of one of the "temporary" registers, $T0, to hold the destination address.

	And that brings us to our first piece of actual code!  Well, it's a macro.


*/
/* NEXT macro. */
	.macro NEXT
	lw	$s6, 0($s7)
	addiu	$s7, $s7, 4
	lw	$t0, 0($s6)
	jr	$t0
	.endm

/*	The macro is called NEXT.  That's a FORTH-ism.  It expands to those four instructions.

	Every FORTH primitive that we write has to be ended by NEXT.  Think of it kind of like
	a return.

	The above describes what is known as direct threaded code.

	To sum up: We compress our function calls down to a list of addresses and use a somewhat
	magical macro to act as a "jump to next function in the list".  We also use one register ($S7)
	to act as a kind of instruction pointer, pointing to the next function in the list.

	I'll just give you a hint of what is to come by saying that a FORTH definition such as:

	: QUADRUPLE DOUBLE DOUBLE ;

	actually compiles (almost, not precisely but we'll see why in a moment) to a list of
	function addresses for DOUBLE, DOUBLE and a special function called EXIT to finish off.

	At this point, REALLY EAGLE-EYED ASSEMBLY EXPERTS are saying "JONES, YOU'VE MADE A MISTAKE!".

	I lied about
	lw	$s6, 0($s7)
	lw	$t0, 0($s6)
	jr	$t0

	INDIRECT THREADED CODE ----------------------------------------------------------------------

	It turns out that direct threaded code is interesting but only if you want to just execute
	a list of functions written in assembly language.  So QUADRUPLE would work only if DOUBLE
	was an assembly language function.  In the direct threaded code, QUADRUPLE would look like:

		+------------------+
		| addr of DOUBLE  --------------------> (assembly code to do the double)
		+------------------+                    NEXT
	$S7 ->	| addr of DOUBLE   |
		+------------------+

	We can add an extra indirection to allow us to run both words written in assembly language
	(primitives written for speed) and words written in FORTH themselves as lists of addresses.

	The extra indirection is the reason for the double load with parentheses in lw $s6, 0($s7),
	lw $t0, 0($S6).

	Let's have a look at how QUADRUPLE and DOUBLE really look in FORTH:

		: QUADRUPLE DOUBLE DOUBLE ;

		+------------------+
		| codeword         |		   : DOUBLE DUP + ;
		+------------------+
		| addr of DOUBLE  ---------------> +------------------+
		+------------------+               | codeword         |
		| addr of DOUBLE   |		   +------------------+
		+------------------+		   | addr of DUP   --------------> +------------------+
		| addr of EXIT	   |		   +------------------+            | codeword      -------+
		+------------------+	   $S7 ->  | addr of +     --------+	   +------------------+   |
						   +------------------+	   |	   | assembly to    <-----+
						   | addr of EXIT     |    |       | implement DUP    |
						   +------------------+	   |	   |	..	      |
									   |	   |    ..            |
									   |	   | NEXT             |
									   |	   +------------------+
									   |
									   +-----> +------------------+
										   | codeword      -------+
										   +------------------+   |
										   | assembly to   <------+
										   | implement +      |
										   |	..            |
										   |	..            |
										   | NEXT      	      |
										   +------------------+

	This is the part where you may need an extra cup of tea/coffee/favourite caffeinated
	beverage.  What has changed is that I've added an extra pointer to the beginning of
	the definitions.  In FORTH this is sometimes called the "codeword".  The codeword is
	a pointer to the interpreter to run the function.  For primitives written in
	assembly language, the "interpreter" just points to the actual assembly code itself.
	They don't need interpreting, they just run.

	In words written in FORTH (like QUADRUPLE and DOUBLE), the codeword points to an interpreter
	function.

	I'll show you the interpreter function shortly, but let's recall our indirect lw $s6,
	0($s7), lw $t0, 0($s6), jr $t0 with the "extra" parentheses.  Take the case where we're
	executing DOUBLE as shown, and DUP has been called.  Note that $S7 is pointing to the
	address of +.

	The assembly code for DUP eventually does a NEXT.  That:

	(1) reads the address of + into $S6		$S6 points to the codeword of +
	(2) increments $S7 by 4
	(3) jumps to the indirect $S6			jumps to the address in the codeword of +,
							ie. the assembly code to implement +

		+------------------+
		| codeword         |
		+------------------+
		| addr of DOUBLE  ---------------> +------------------+
		+------------------+               | codeword         |
		| addr of DOUBLE   |		   +------------------+
		+------------------+	   	   | addr of DUP   --------------> +------------------+
		| addr of EXIT	   |		   +------------------+            | codeword      -------+
		+------------------+	   	   | addr of +     --------+	   +------------------+   |
						   +------------------+	   |	   | assembly to    <-----+
					   $S7 ->  | addr of EXIT     |    |       | implement DUP    |
						   +------------------+	   |	   |	..	      |
									   |	   |    ..            |
									   |	   | NEXT             |
									   |	   +------------------+
									   |
									   +-----> +------------------+
										   | codeword      -------+
										   +------------------+   |
									now we're  | assembly to    <-----+
									executing  | implement +      |
									this	   | 	..            |
									function   | 	..            |
										   | NEXT      	      |
										   +------------------+

	So I hope that I've convinced you that NEXT does roughly what you'd expect.  This is
	indirect threaded code.

	I've glossed over four things.  I wonder if you can guess without reading on what they are?

	.
	.
	.

	My list of four things are: (1) What does "EXIT" do?  (2) which is related to (1) is how do
	you call into a function, ie. how does $S7 start off pointing at part of QUADRUPLE, but
	then point at part of DOUBLE.  (3) What goes in the codeword for the words which are written
	in FORTH?  (4) How do you compile a function which does anything except call other functions
	ie. a function which contains a number like : DOUBLE 2 * ; ?

	THE INTERPRETER AND RETURN STACK ------------------------------------------------------------

	Going at these in no particular order, let's talk about issues (3) and (2), the interpreter
	and the return stack.

	Words which are defined in FORTH need a codeword which points to a little bit of code to
	give them a "helping hand" in life.  They don't need much, but they do need what is known
	as an "interpreter", although it doesn't really "interpret" in the same way that, say,
	Java bytecode used to be interpreted (ie. slowly).  This interpreter just sets up a few
	machine registers so that the word can then execute at full speed using the indirect
	threaded model above.

	One of the things that needs to happen when QUADRUPLE calls DOUBLE is that we save the old
	$S7 ("instruction pointer") and create a new one pointing to the first word in DOUBLE.
	Because we will need to restore the old $S7 at the end of DOUBLE (this is, after all, like
	a function call), we will need a stack to store these "return addresses" (old values of $S7).

	As you will have seen in the background documentation, FORTH has two stacks, an ordinary
	stack for parameters, and a return stack which is a bit more mysterious.  But our return
	stack is just the stack I talked about in the previous paragraph, used to save $S7 when
	calling from a FORTH word into another FORTH word.

	In this FORTH, we are using our "normal" stack pointer ($S5) for the parameter stack.
	We will another stack pointer ($S4, also just a general-purpose register)
	for our return stack.

	I've got two macros which just wrap up the details of using $S4 for the return stack.
	You use them as for example "PUSHRSP $S7" (push $S7 on the return stack) or "POPRSP $S8"
	(pop top of return stack into $S8).
*/

/* Macros to deal with the forth stack. */
/* forth stack grows down */
	.macro PUSH	reg
	addiu	$s5, $s5, -4
	sw	\reg, 0($s5)
	.endm

	.macro POP	reg
	lw	\reg, 0($s5)
	addiu	$s5,$s5,4
	.endm

/* return stack grows up */
	.macro PUSHRSP reg
	addiu	$s4, $s4, 4
	sw	\reg, 0($s4)
	.endm

	.macro POPRSP reg
	lw	\reg, 0($s4)
	addiu	$s4, $s4, -4
	.endm

	/**

	Macros to interface with C functions, or assembly language routines that use C's calling
	conventions. We use $S8 to store the return address, because the default register ($31, or
	ra) is being used in the normal way by the C code. So use $S8 instead, saving the existing
	value on the return stack and popping it back after the call to the C function.

	*/

	.macro CALL	label
	PUSHRSP	$s8
	la	$t0, \label
	jalr	$s8, $t0 	// stores return address in $S8, jumps to address in $0
	POPRSP	$s8		// previous instruction set $S8 to point here, restore original
	.endm

	/**

	We'll define a number of assembly language subroutines and use CALL to call them. They need
	to end with this instruction to correctly return.

	*/
	.macro RETURN
	jr	$s8		// just jump to the return address stored in $S8
	.endm

/*
	And with that we can now talk about the interpreter.

	In FORTH the interpreter function is often called DOCOL (I think it means "DO COLON" because
	all FORTH definitions start with a colon, as in : DOUBLE DUP + ;

	The "interpreter" (it's not really "interpreting") just needs to push the old $S7 on the
	stack and set $S7 to the first word in the definition.  Remember that we jumped to the
	function using lw $s6, 0($s7); lw $t0, 0($s6); jr $t0?  Well a consequence of that is that
	conveniently $S6 contains the address of this codeword, so just by adding 4 to it we get the
	address of the first data word.  Finally after setting up $S7, it just does NEXT which
	causes that first word to run.
*/

	.text
	.align 4

/* DOCOL - the interpreter! */
DOCOL:
	PUSHRSP $s7
	addiu	$s6, $s6, 4	// incr jmp address
	move	$s7, $s6	// load new routine addr
	NEXT

/*
	Just to make this absolutely clear, let's see how DOCOL works when jumping from QUADRUPLE
	into DOUBLE:

		QUADRUPLE:
		+------------------+
		| codeword         |
		+------------------+		   DOUBLE:
		| addr of DOUBLE  ---------------> +------------------+
		+------------------+        $s6 -> | addr of DOCOL    |
	$s7 ->	| addr of DOUBLE   |		   +------------------+
		+------------------+		   | addr of DUP      |
		| addr of EXIT	   |		   +------------------+
		+------------------+               | etc.             |

	First, the call to DOUBLE calls DOCOL (the codeword of DOUBLE).  DOCOL does this:  It
	pushes the old $s7 on the return stack.  $s6 points to the codeword of DOUBLE, so we
	just add 4 on to it to get our new $s7:

		QUADRUPLE:
		+------------------+
		| codeword         |
		+------------------+		   DOUBLE:
		| addr of DOUBLE  ---------------> +------------------+
top of return	+------------------+        $s6 -> | addr of DOCOL    |
stack points ->	| addr of DOUBLE   |	    + 4 =  +------------------+
		+------------------+	    $s7 -> | addr of DUP      |
		| addr of EXIT	   |		   +------------------+
		+------------------+               | etc.             |

	Then we do NEXT, and because of the magic of threaded code that increments $s7 again
	and calls DUP.

	Well, it seems to work.

	One minor point here.  Because DOCOL is the first bit of assembly actually to be defined
	in this file (the others were just macros), and because I usually compile this code with the
	text segment starting at address 0, DOCOL has address 0.  So if you are disassembling the
	code and see a word with a codeword of 0, you will immediately know that the word is
	written in FORTH (it's not an assembler primitive) and so uses DOCOL as the interpreter.

	STARTING UP ----------------------------------------------------------------------

	Now let's get down to nuts and bolts.  When we start the program we need to set up
	a few things like the return stack.  But as soon as we can, we want to jump into FORTH
	code (albeit much of the "early" FORTH code will still need to be written as
	assembly language primitives).

	This is what the set up code does.
	a) sets up some error reporting variables
	b) sets initial values of LATEST, HERE, BASE, and STATE
	c) sets up parameter and return stacks
	d) sets a flag to indicate initialization was done
	e) sets up stack for RESUME from C
	f) jumps to a FORTH word called QUIT.  Despite its name, QUIT doesn't quit anything.  It
	resets some internal state and starts reading and interpreting commands.  (The reason it is
	called QUIT is because you can call QUIT from your own FORTH code to "quit" your program and
	go back to interpreting).

	Register Usage Reference (for review)

	$S4	return stack
	$S5	forth stack
	$S6	Next IP, jump dest
	$S7	IP (instruction pointer)

*/

	.text

warm_init:
	// warm_init just restores stack pointers
	// do we need this??
	b	1f

	// memory allocated for forth and return stacks
	.equ	STACKS_SIZE, 160

	//*********************************************************************
.global forth_init
forth_init:
	// $a0 is the address of our memory chunk
	// $a1 is the length
	// $a2 is address of string constant

	// reserve space on stack
	addu		$sp, $sp, -52		# $sp = $sp - 52
	# save S regs -- we may not use all of these
	# alternative to storing these -- just never return
	sw		$s0, 48($sp)		#
	sw		$s1, 44($sp)		#
	sw		$s2, 40($sp)		#
	sw		$s3, 36($sp)		#
	sw		$s4, 32($sp)		#
	sw		$s5, 28($sp)		#
	sw		$s6, 24($sp)		#
	sw		$s7, 20($sp)		#
	# save params to stack
	.equiv  return_addr,16
	.equiv  example, 12
	.equiv  start_addr,8
	.equiv  end_addr,4
	.equiv  msg_ptr, 0
	sw		$ra, return_addr($sp)
	sw              $a0, start_addr($sp)
	add             $a1, $a0
	sw              $a1, end_addr($sp)
	sw              $a2, msg_ptr($sp)

	// set variable r0 to top of return stack
	move		$s4, $a0		# return stack top (grows up)
	la		$t0, var_r0		#
	la		$t1, start_addr($sp)		#
	sw		$t1, 0($t0)		#


	add		$s5, $a0, STACKS_SIZE-4	# forth stack top (grows down)

	// set var_here to next available address
	la		$t0, var_here    	// init HERE to bottom of heap
	add		$t1, $a0, STACKS_SIZE	// $t1 = $a0 + STACKS_SIZE
	sw		$t1, 0($t0)		// store bottom of heap to HERE

	la	$s7, cold_start		// Initialise interpreter


	la	$t0, var_s0		// to init $S0

	la	$t0, var_idleword    	// init IDLE word
	la	$t1, IDLE		// with IDLE proc
	sw	$t1, 0($t0)

	la	$t0, var_base		// init BASE
	li	$t1, 10
	sw	$t1, 0($t0)

	la	$t0, var_state		// init STATE
	sw	$0, 0($t0)		// store STATE = 0

	// mark that init was done
	la	$t0, init_magic		// mark it with magic
	li	$t1, 0xBEEF
	sw	$t1, 0($t0)

	li      $a0, 1
	jal     green
	nop

	// here we need to await input -- how do we get input??
	// temporary: parse and run program passed in call to forth_init
	// NEXT
	move            $a0, $a3
	jal		FbWriteLine
	nop

	// if I return here, and call FbSwapBuffers from C after forth_init,
	// I get the line written above. But this does diddly:?????
//	jal             FbSwapBuffers
//	nop


//	la              $t0, name_QUIT
//	j               $t0

.global forth_return
forth_return:
	lw              $ra, return_addr($sp) # restore caller return address

	lw		$s7, 20($sp)		#
	lw		$s6, 24($sp)		#
	lw		$s5, 28($sp)		#
	lw		$s4, 32($sp)		#
	lw		$s3, 36($sp)		#
	lw		$s2, 40($sp)		#
	lw		$s1, 44($sp)		#
	lw		$s0, 48($sp)		#

	addu		$sp, $sp, 52# $sp = $sp + 52

	move $v0, $0
	j $ra

iskey:
        la       $t0, example($sp)
	lb       $v0, 0($t0)
	//non-zero value is true
	RETURN				// result is in v0

nget_key:
        la       $t0, example($sp)
	lb       $v0, 0($t0)
	add      $t0, 1
	sw       $t0, example($sp)
        RETURN				// result is in v0

	la	$t0, LBUFPTR
	sw	$0, 0($t0)		// line buffer point

	//
	// setup save info for first c resume
	//
	la	$s8,  init_return	// this is the initial return address for resume

	PUSH	$a0
	PUSH	$a1

	PUSH	$v0
	PUSH	$v1

	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3


	PUSH	$s4
	// $s5 stack pointer save in ram (below)
	PUSH	$s6
	PUSH	$s7
	PUSH	$s8

	// initial_SP == yield stack pointer, for call/return from C app.
	// since $s5 is the stack address and is used in POP/PUSH macros
	// we store it in a variable for c/forth task switching
	la	$t0,  initial_SP
	sw	$s5,  0($t0)		// store stack pointer in yield SP var

	b	ReResume		// continue resume

	// this is where the initial resume will end up
init_return:
	NEXT			// Run interpreter!, fall through to next word
cold_start:			// High-level code without a codeword.
	.int	VERSION
/*	.int	BIDLE	// turns off LEDs display color bars
*/
	.int    QUIT

/*
	BUILT-IN WORDS ----------------------------------------------------------------------

	Remember our dictionary entries (headers)?  Let's bring those together with the codeword
	and data words to see how : DOUBLE DUP + ; really looks in memory.

	  pointer to previous word
	   ^
	   |
	+--|------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        | +          | EXIT       |
	+---------+---+---+---+---+---+---+---+---+------------+--|---------+------------+------------+
	   ^       len                         pad  codeword      |
	   |							  V
	  LINK in next word				points to codeword of DUP

	Initially we can't just write ": DOUBLE DUP + ;" (ie. that literal string) here because we
	don't yet have anything to read the string, break it up at spaces, parse each word, etc. etc.
	So instead we will have to define built-in words using the GNU assembler data constructors
	(like .int, .byte, .string, .ascii and so on -- look them up in the gas info page if you are
	unsure of them).

	The long way would be:

	.int <link to previous word>
	.byte 6			// len
	.ascii "DOUBLE"		// string
	.byte 0			// padding
DOUBLE: .int DOCOL		// codeword
	.int DUP		// pointer to codeword of DUP
	.int PLUS		// pointer to codeword of +
	.int EXIT		// pointer to codeword of EXIT

	That's going to get quite tedious rather quickly, so here I define an assembler macro
	so that I can just write:

	defword "DOUBLE",6,,DOUBLE
	.int DUP,PLUS,EXIT

	and I'll get exactly the same effect.

	Don't worry too much about the exact implementation details of this macro - it's complicated!
*/

/* Flags - these are discussed later. */
	.equ	F_IMMED, 0x80
	.equ	F_HIDDEN, 0x20
	.equ	F_LENMASK, 0x1f	// length mask

	.macro defword name, namelen, flags=0, label, prevlabel
	.text
	.global name_\label
name_\label :
	.int name_\prevlabel		// link
	.byte \flags+\namelen	// flags + length byte
	.ascii "\name"		// the name
	.global \label
\label :
	.int DOCOL		// codeword - the interpreter
	// list of word pointers follow
	.endm

/*
	Similarly I want a way to write words written in assembly language.  There will quite a few
	of these to start with because, well, everything has to start in assembly before there's
	enough "infrastructure" to be able to start writing FORTH words, but also I want to define
	some common FORTH words in assembly language for speed, even though I could write them in FORTH.

	This is what DUP looks like in memory:

	  pointer to previous word
	   ^
	   |
	+--|------+---+---+---+---+------------+
	| LINK    | 3 | D | U | P | code_DUP ---------------------> points to the assembly
	+---------+---+---+---+---+------------+		    code used to write DUP,
	   ^	   len		    codeword			    which ends with NEXT.
	   |
	  LINK in next word

	Again, for brevity in writing the header I'm going to write an assembler macro called defcode.
	As with defword above, don't worry about the complicated details of the macro.
*/

	.macro defcode name, namelen, flags=0, label, prevlabel
	.text
	.global name_\label
name_\label :
	.int name_\prevlabel		// link
	.byte \flags+\namelen	// flags + length byte
	.ascii "\name"		// the name
	.global \label
\label :
	.int code_\label	// codeword
	.global code_\label
code_\label :			// assembler code follows
	.endm

/*
	Now some easy FORTH primitives.  These are written in assembly for speed.  If you understand
	MIPS32 assembly language then it is worth reading these.  However if you don't understand
	assembly you can skip the details.
*/

	.equ name_ZED, 0	// end of dictionary list

	defcode "drop",4,,DROP,ZED  // ( n -- )
	POP	$t0
	NEXT

	defcode "swap",4,,SWAP,DROP  // ( n1 n2 -- n2 n1 )
	POP	$t0
	POP	$t1
	PUSH	$t0
	PUSH	$t1
	NEXT

	defcode "dup",3,,DUP,SWAP  // ( n -- n n )
	POP	$t0
	PUSH	$t0
	PUSH	$t0
	NEXT

	defcode "over",4,,OVER,DUP  // ( n1 n2 -- n1 n2 n1 )
	POP	$t0
	POP	$t1
	PUSH	$t1
	PUSH	$t0
	PUSH	$t1
	NEXT

	defcode "rot",3,,ROT,OVER  // ( n1 n2 n3 -- n2 n3 n1 )
	POP	$t0 // n1 n2
	POP	$t1 // n1
	POP	$t2
	PUSH	$t1 // n2
	PUSH	$t0 // n2 n3
	PUSH	$t2 // n2 n3 n1
	NEXT

	defcode "-rot",4,,NROT,ROT  // ( n1 n2 n3 -- n3 n1 n2 )
	POP	$t0 // n1 n2
	POP	$t1 // n1
	POP	$t2 //
	PUSH	$t0 // n3
	PUSH	$t2 // n3 n1
	PUSH	$t1 // n3 n1 n2
	NEXT

	// drop top two elements of stack
	defcode "2drop",5,,TWODROP,NROT // ( n1 n2 -- )
	POP	$t0
	POP	$t0
	NEXT

	// duplicate top two elements of stack
	defcode "2dup",4,,TWODUP,TWODROP // ( n1 n2 -- n1 n2 n1 n2 )
	POP	$t0
	POP	$t1
	PUSH	$t1
	PUSH	$t0
	PUSH	$t1
	PUSH	$t0
	NEXT

	// swap top two pairs of elements of stack
	defcode "2swap",5,,TWOSWAP,TWODUP // ( n1 n2 n3 n4 -- n3 n4 n1 n2 )
	POP	$t0
	POP	$t1
	POP	$t2
	POP	$t3
	PUSH	$t1
	PUSH	$t0
	PUSH	$t3
	PUSH	$t2
	NEXT

	// duplicate top of stack if non-zero
	defcode "?dup",4,,QDUP,TWOSWAP	// ( 0 -- 0 || n -- n n )
	POP	$t0
	PUSH	$t0
	beqz	$t0, 1f
	PUSH	$t0
1:	NEXT

	defcode "4+",2,,INCR4, QDUP
	POP	$t0
	addiu	$t0, $t0, 4
	PUSH	$t0
	NEXT

	defcode "4-",2,,DECR4, INCR4
	POP	$t0
	addiu	$t0, $t0, -4
	PUSH	$t0
	NEXT

	defcode "1+",2,,INCR, DECR4
	POP	$t0
	addiu	$t0, $t0, 1
	PUSH	$t0
	NEXT

	defcode "1-",2,,DECR, INCR
	POP	$t0
	addiu	$t0, $t0, -1
	PUSH	$t0
	NEXT

	defcode "+",1,,ADD, DECR
	POP	$t0
	POP	$t1
	add	$t2, $t1, $t0
	PUSH	$t2
	NEXT

	defcode "-",1,,SUB, ADD
	POP	$t0
	POP	$t1
	sub	$t2, $t1, $t0
	PUSH	$t2
	NEXT

	defcode "*",1,,MUL, SUB
	POP	$t0
	POP	$t1
	mul	$t2, $t1, $t0
	PUSH	$t2
	NEXT

/*
	In this FORTH, only /MOD is primitive.  Later we will define the / and MOD words in
	terms of the primitive /MOD.  The design of the MIPS32 assembly instruction divu which
	leaves both quotient and remainder makes this the obvious choice.
*/

	defcode "/mod",4,,DIVMOD, MUL
	POP	$t0
	POP	$t1
	divu	$t1, $t0
	mfhi	$t0	// remainder
	mflo	$t1	// quo
	PUSH	$t0	// store remainder
	PUSH	$t1	// store quo
	NEXT

/*
	Lots of comparison operations like =, <, >, etc..

	ANS FORTH says that the comparison words should return all (binary) 1's for
	TRUE and all 0's for FALSE.  However this is a bit of a strange convention
	so this FORTH breaks it and returns the more normal (for C programmers ...)
	1 meaning TRUE and 0 meaning FALSE.

	Note the use of $T2 for the return value.
*/

	defcode "=",1,,EQU,DIVMOD	// top two words are equal?
	POP	$t0
	POP	$t1
	li	$t2, 1
	beq	$t1, $t0, 1f
	move	$t2, $0
1:	PUSH	$t2		// tmp
	NEXT

	defcode "<>",2,,NEQU,EQU	// top two words are not equal?
	POP	$t0
	POP	$t1
	li	$t2, 1
	bne	$t1, $t0, 1f
	move	$t2, $0
1:	PUSH	$t2		// tmp
	NEXT

	defcode "<",1,,LT,NEQU
	POP	$t0
	POP	$t1
	slt	$t2, $t1, $t0	    // set less than
	PUSH	$t2		// tmp
	NEXT

	defcode ">",1,,GT,LT
	POP	$t0
	POP	$t1
	slt	$t2, $t0, $t1       // set less than
	PUSH	$t2		// tmp
	NEXT

	defcode "<=",2,,LE,GT
	POP	$t0
	POP	$t1
	li	$t2, 1
	beq	$t1, $t0, 1f
	move	$t2, $0
	slt	$t2, $t1, $t0       // set less than
1:	PUSH	$t2		// tmp
	NEXT

	defcode ">=",2,,GE,LE
	POP	$t0
	POP	$t1
	li	$t2, 1
	beq	$t1, $t0, 1f
	move	$t2, $0
	slt	$t2, $t0, $t1
1:	PUSH	$t2		// tmp
	NEXT

	defcode "0=",2,,ZEQU,GE	// top of stack equals 0?
	POP	$t0
	li	 $t1, 1              // prepare tmp
	movn	$t1, $0, $t0       // tmp = (t2=0)?0:1
	PUSH	$t1
	NEXT

	defcode "0<>",3,,ZNEQU,ZEQU	// top of stack not 0?
	POP	$t0
	li	 $t1, 1              // prepare tmp
	movz	$t1, $0, $t0
	PUSH	$t1
	NEXT

	defcode "0<",2,,ZLT,ZNEQU	// comparisons with 0
	POP	$t0
	slt	$t1, $t0, $0       // set less than
	PUSH	$t1
	NEXT

	defcode "0>",2,,ZGT,ZLT
	POP	$t0
	slt	$t1, $0, $t0       // set less than
	PUSH	$t1
	NEXT

#	defcode "0<=",3,,ZLE
#	pop %eax
#	test %eax,%eax
#	setle %al
#	movzbl %al,%eax
#	pushl %eax
#	NEXT

#	defcode "0>=",3,,ZGE
#	pop %eax
#	test %eax,%eax
#	setge %al
#	movzbl %al,%eax
#	pushl %eax
#	NEXT

	defcode "and",3,,AND,ZGT	// bitwise AND
	POP	$t0
	POP	$t1
	and	$t2, $t1, $t0       // and
	PUSH	$t2
	NEXT

	defcode "or",2,,OR,AND	// bitwise OR
	POP	$t0
	POP	$t1
	or	$t2, $t1, $t0       // or
	PUSH	$t2
	NEXT

	defcode "xor",3,,XOR,OR	// bitwise XOR
	POP	$t0
	POP	$t1
	xor	$t2, $t1, $t0       // xor
	PUSH	$t2
	NEXT

	defcode "invert",6,,INVERT,XOR // this is the FORTH bitwise "NOT" function (cf. NEGATE and NOT)
	POP	$t0
	not	$t1, $t0
	PUSH	$t1
	NEXT

/*
	RETURNING FROM FORTH WORDS ----------------------------------------------------------------------

	Time to talk about what happens when we EXIT a function.  In this diagram QUADRUPLE has called
	DOUBLE, and DOUBLE is about to exit (look at where $S7 is pointing):

		QUADRUPLE
		+------------------+
		| codeword         |
		+------------------+		   DOUBLE
		| addr of DOUBLE  ---------------> +------------------+
		+------------------+               | codeword         |
		| addr of DOUBLE   |		   +------------------+
		+------------------+	   	   | addr of DUP      |
		| addr of EXIT	   |		   +------------------+
		+------------------+	   	   | addr of +        |
						   +------------------+
					   $S7 ->  | addr of EXIT     |
						   +------------------+

	What happens when the + function does NEXT?  Well, the following code is executed.
*/

	defcode "exit",4,,EXIT,INVERT
	POPRSP $s7		// pop return stack into $S7
	NEXT

/*
	EXIT gets the old $S7 which we saved from before on the return stack, and puts it in $S7.
	So after this (but just before NEXT) we get:

		QUADRUPLE
		+------------------+
		| codeword         |
		+------------------+		   DOUBLE
		| addr of DOUBLE  ---------------> +------------------+
		+------------------+               | codeword         |
	$S7 ->	| addr of DOUBLE   |		   +------------------+
		+------------------+	   	   | addr of DUP      |
		| addr of EXIT	   |		   +------------------+
		+------------------+	   	   | addr of +        |
						   +------------------+
						   | addr of EXIT     |
						   +------------------+

	And NEXT just completes the job by, well, in this case just by calling DOUBLE again :-)

	LITERALS ----------------------------------------------------------------------

	The final point I "glossed over" before was how to deal with functions that do anything
	apart from calling other functions.  For example, suppose that DOUBLE was defined like this:

	: DOUBLE 2 * ;

	It does the same thing, but how do we compile it since it contains the literal 2?  One way
	would be to have a function called "2" (which you'd have to write in assembler), but you'd need
	a function for every single literal that you wanted to use.

	FORTH solves this by compiling the function using a special word called LIT:

	+---------------------------+-------+-------+-------+-------+-------+
	| (usual header of DOUBLE)  | DOCOL | LIT   | 2     | *     | EXIT  |
	+---------------------------+-------+-------+-------+-------+-------+

	LIT is executed in the normal way, but what it does next is definitely not normal.  It
	looks at $S7 (which now points to the number 2), grabs it, pushes it on the stack, then
	manipulates $S7 in order to skip the number as if it had never been there.

	Rather than me drawing more ASCII-art diagrams, see if you can find out how LIT works:
*/

	defcode "lit",3,,LIT,EXIT
	lw	$t0, 0($s7)
	addiu	$s7, $s7, 4        // skip literal
	PUSH	$t0
	NEXT

/*
	MEMORY ----------------------------------------------------------------------

	As important point about FORTH is that it gives you direct access to the lowest levels
	of the machine.  Manipulating memory directly is done frequently in FORTH, and these are
	the primitive words for doing it.
*/

	defcode "!",1,,STORE,LIT
	POP	$t0			// addr
	POP	$t1			// val
	sw	$t1, 0($t0)          // store it
	NEXT

	defcode "@",1,,FETCH,STORE
	POP	$t0			// addr
	lw	$t1, 0($t0)
	PUSH	$t1		// put on stack
	NEXT

/*
	PAD is a standard Forth word that returns the address of a "scratch" area, a space in memory
	where bytes can be read/written for temporary storage. The ANSI standard specifies a minimum
	size of 84 bytes for the PAD area. (addition by ALF)
*/
	.global pad_area
pad_area:
	.space 84  // minimum reqd. by ANSI std.

	defcode "PAD",3,,PAD,FETCH
	la      $t0, pad_area
	PUSH    $t0
	NEXT

//        1 HERE +!       ( increment HERE pointer by 1 byte )
	defcode "+!",2,,ADDSTORE,PAD // ( n addr -- ) *addr = *addr + n
	POP	$t0			// addr
	POP	$t1			// inc
	lw	$t2, 0($t0)		// t2 = *addr
	add	$t3, $t2, $t1	// add
	sw	$t3, 0($t0)		// store back to addr
	NEXT

	defcode "-!",2,,SUBSTORE, ADDSTORE // ( n addr -- ) *addr = *addr - n
	POP	$t0			// addr
	POP	$t1			// inc
	lw	$t2, 0($t0)		// t2 = *addr
	sub	$t3, $t2, $t1	// t3 = t2 - t1
	sw	$t3, 0($t0)		// store back to addr
	NEXT

/*
	! and @ (STORE and FETCH) store 32-bit words.  It's also useful to be able to read and write bytes
	so we also define standard words C@ and C!.

	Byte-oriented operations only work on architectures which permit them (MIPS32 does).
 */

	defcode "c!",2,,STOREBYTE,SUBSTORE
	POP	$t0			// addr
	POP	$t1			// val
	sb	$t1, 0($t0)
	NEXT

	defcode "c@",2,,FETCHBYTE,STOREBYTE
	POP	$t0			// addr
	lbu	$t1, 0($t0)
	PUSH	$t1		// put on stack
	NEXT

/* C@C! is a useful byte copy primitive. */
	defcode "c@c!",4,,CCOPY,FETCHBYTE
	POP	$t0			// src
	POP	$t1			// dest
	lbu	$t2, 0($t0)
	sb	$t2, 0($t1)
	addiu	$t0, $t0, 1
	addiu	$t1, $t1, 1
	PUSH	$t1		// dest
	PUSH	$t0		// dest
	NEXT

/* and CMOVE is a block copy operation. */
	defcode "cmove",5,,CMOVE, CCOPY
	POP	$t0			// length
	POP	$t1			// dest
	POP	$t2			// src
_CMOVE:
1:	beqz	$t0, 2f
	lbu	$t3, 0($t2)
	sb	$t3, 0($t1)
	addiu	$t0, $t0, -1
	addiu	$t1, $t1, 1
	addiu	$t2, $t2, 1
	b 1b
2:	NEXT

/*
	BUILT-IN VARIABLES ----------------------------------------------------------------------

	These are some built-in variables and related standard FORTH words.  Of these, the only one that we
	have discussed so far was LATEST, which points to the last (most recently defined) word in the
	FORTH dictionary.  LATEST is also a FORTH word which pushes the address of LATEST (the variable)
	on to the stack, so you can read or write it using @ and ! operators.  For example, to print
	the current value of LATEST (and this can apply to any FORTH variable) you would do:

	LATEST @ . CR

	To make defining variables shorter, I'm using a macro called defvar, similar to defword and
	defcode above.  (In fact the defvar macro uses defcode to do the dictionary header).
*/

	.macro defvar name, namelen, flags=0, label, initial=0, prevlabel
	defcode \name,\namelen,\flags,\label,\prevlabel
	la	$t0, var_\name
	PUSH	$t0
	NEXT
	.data
#	.align 4
var_\name :
	.int \initial
	.endm

/*
	The built-in variables are:

	STATE		Is the interpreter executing code (0) or compiling a word (non-zero)?
	LATEST		Points to the latest (most recently defined) word in the dictionary.
	HERE		Points to the next free byte of memory.  When compiling, compiled words go here.
	S0		Stores the address of the top of the parameter stack.
	BASE		The current base for printing and reading numbers.
	ERRNO		The numeric identifier for the most recent error.
	ERRBUF		Storage area for a string message from the most recent error.
	ERRORS		A table of predefined error numbers and messages.
	IDLEWORD	??
*/
	defvar "errNo",5,,ERRNO,0,CMOVE
	defvar "errBuf",6,,ERRBUF,errBuffer,ERRNO
	defvar "errors",6,,ERRORS,errTable,ERRBUF
	defvar "state",5,,STATE,0,ERRORS
	defvar "here",4,,HERE,0,STATE
	defvar "latest",6,,LATEST,name_HANG,HERE // HANG needs to be the last in built-in dictionary item
	defvar "s0",2,,SZ,,LATEST
	defvar "idleword",8,,IDLEWORD,,SZ
	//defvar "echo",4,,ECHO,1,IDLEWORD
	//defvar "base",4,,BASE,10,ECHO
	defvar "base",4,,BASE,10,IDLEWORD
	// defconst "r0",2,,RZ,return_stack_top, BASE
	defvar "r0",2,,RZ,0,BASE

/*
	BUILT-IN CONSTANTS ----------------------------------------------------------------------

	It's also useful to expose a few constants to FORTH.  When the word is executed it pushes a
	constant value on the stack.

	The built-in constants are:

	R0		The address of the top of the return stack.
	DOCOL		Pointer to DOCOL.
	FIMMED		The IMMEDIATE flag's actual value.
	FHIDDEN		The HIDDEN flag's actual value.
	FLENMASK	The length mask in the flags/len byte.

*/

	.macro defconst name, namelen, flags=0, label, value, prevlabel
	defcode \name,\namelen,\flags,\label,\prevlabel
	la	$t0, \value
	PUSH	$t0
	NEXT
	.endm

	defconst "docol",5,,__DOCOL,DOCOL,RZ
	defconst "Fimmed",6,,__F_IMMED,F_IMMED,__DOCOL
	defconst "Fhidden",7,,__F_HIDDEN,F_HIDDEN,__F_IMMED
	defconst "Flenmask",8,,__F_LENMASK,F_LENMASK,__F_HIDDEN

/*
	RETURN STACK ----------------------------------------------------------------------

	These words allow you to access the return stack.  Recall that the register $S4 always
	points to the top of the return stack.
*/

	defcode ">r",2,,TOR,__F_LENMASK
	POP	$t0
	PUSHRSP $t0		// push it on to the return stack
	NEXT

	defcode "r>",2,,FROMR,TOR
	POPRSP	$t0		// pop return stack in to $t0
	PUSH	$t0
	NEXT

	defcode "rsp@",4,,RSPFETCH,FROMR
	PUSH	$s4	// push rsp point onto data stack
	NEXT

	defcode "rsp!",4,,RSPSTORE,RSPFETCH
	POP	$s4		// pop data stack into rsp point
	NEXT

	defcode "rdrop",5,,RDROP,RSPSTORE
	POPRSP $t0		// pop return stack in to $t0
	NEXT

/*
	PARAMETER (DATA) STACK ----------------------------------------------------------------------

	These functions allow you to manipulate the parameter stack.  Recall that it is accessed
	through $S5.
*/

/*	PUSH	$s5  	**NOTE**  can't use the macro because the inc order affects what is being
	pushed
*/

	defcode "dsp@",4,,DSPFETCH,RDROP
	move	$t0, $s5
	addiu	$s5, $s5, -4
	sw	$t0, 0($s5)
	NEXT

	defcode "dsp!",4,,DSPSTORE,DSPFETCH
	POP	$t0	// can't POP directly into $s5
	move	$s5, $t0
	NEXT

/*
	INTERFACE WITH C CODE------------------------------------------------------------------

	These routines deal with the transfer of control from C code (control loop) to the forth
	interpreter, and from the forth interpreter back to the C loop.

	The 'resume' routine is called by the C code to turn over control to the forth
	interpreter. It saves the machine state, then checks whether 'forth_init' has run. If it has
	not, it branches to the 'forth_init' routine.

	In either case, the code goes on to restore the forth interpreter's machine state.

	Forth code can, in turn, execute the word 'YIELD' to return control to the C loop. This word
	saves the forth interpreter machine state, restores the saved machine state, and returns to
	the point of the 'resume' call.
*/

	// Called by c program
	// needs to save c registers
	// needs to restore forth registers
	// and NEXT
	.set noreorder
	.global resume
resume:
	// save c state
	addiu	  $sp,$sp,-40
	sw	$ra,36($sp)      #, return address
	sw	$s8,32($sp)
	sw	$s7,28($sp)
	sw	$s6,24($sp)
	sw	$s5,20($sp)
	sw	$s4,16($sp)
	sw	$s3,12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	la	$t0, init_magic		// check magic to see if forth_init has happened
	lw	$t1, 0($t0)
	li	$t2, 0xBEEF			// magic
	bne	$t1, $t2, forth_init
	nop

ReResume:	// if forth_init happened, it will return here
	// restore forth state

	// $s5 is used by POP	macro, so have to restore it manually first
	la		$t0,  initial_SP
	lw		$s5,  0($t0)		// stack pointer

	// $s5 is setup, so we can use POP	now
	POP	$s8
	POP	$s7
	POP	$s6
	POP	$s4

	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0

	POP	$v1
	POP	$v0

	POP	$a1
	POP	$a0

	RETURN

	// called by forth program
	// need to save forth registers
	// need to restore c registers
	// and return
	.set noreorder
	.text
	.global yield
yield:
	// save these to forth stack
	PUSH	$a0
	PUSH	$a1

	PUSH	$v0
	PUSH	$v1

	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	PUSH	$s6
	PUSH	$s7
	PUSH	$s8

	// save stack pointer last
	la	$t0,  initial_SP
	sw	$s5,  0($t0)		// stack point


	lw	$ra,36($sp)      #, return address
	lw	$s8,32($sp)      #,
	lw	$s7,28($sp)      #,
	lw	$s6,24($sp)      #,
	lw	$s5,20($sp)      #,
	lw	$s4,16($sp)      #,
	lw	$s3,12($sp)      #,
	lw	$s2, 8($sp)      #,
	lw	$s1, 4($sp)      #,
	lw	$s0, 0($sp)      #,
	j	$ra
	addiu	$sp,$sp,40      #,,

	.set reorder

	/*

	INPUT AND OUTPUT ----------------------------------------------------------------------

	These are our first really meaty/complicated FORTH primitives.  I have chosen to write them in
	assembler, but surprisingly in "real" FORTH implementations these are often written in terms
	of more fundamental FORTH primitives.  I chose to avoid that because I think that just obscures
	the implementation.  After all, you may not understand assembler but you can just think of it
	as an opaque block of code that does what it says.

	Let's discuss input first.

	The FORTH word KEY reads the next byte from input (and pushes it on the parameter
	stack). Input in our implementation is from the USB port emulating a (much) simpler serial
	port.  So if KEY is called and receives the space key, then the number 32 (ASCII code of
	space) is pushed on the stack.

	In FORTH there is no distinction between reading code and reading input.  We might be reading
	and compiling code, we might be reading words to execute, we might be asking for the user
	to type their name -- ultimately it all comes in through KEY.

	*/

	defcode "key",3,,KEY,DSPSTORE
 	CALL	nget_key
	PUSH	$v0
	NEXT

	defcode "?key",4,,QKEY,KEY
	CALL	iskey
	PUSH	$v0
	NEXT

	defcode "emit",4,,EMIT,QKEY
	POP	$a0
	CALL	nput_char
	NEXT

/*
	Back to input, WORD is a FORTH word which reads the next full word of input.

	What it does in detail is that it first skips any blanks (spaces, tabs, newlines and so on).
	Then it calls KEY to read characters into an internal buffer until it hits a blank.  Then it
	calculates the length of the word it read and returns the address and the length as
	two words on the stack (with the length at the top of stack).

	Notice that WORD has a single internal buffer which it overwrites each time (rather like
	a static C string).  Also notice that WORD's internal buffer is just 64 (?) bytes long and
	there is NO checking for overflow.  63 bytes happens to be the maximum length of a
	FORTH word that we support, and that is what WORD is used for: to read FORTH words when
	we are compiling and executing code.  The returned strings are not NUL-terminated.

	Start address+length is the normal way to represent strings in FORTH (not ending in an
	ASCII NUL character as in C), and so FORTH strings can contain any character including NULs
	and can be any length.

	WORD is not suitable for just reading strings (eg. user input) because of all the above
	peculiarities and limitations.

	Note that when executing, you'll see:
	WORD FOO
	which puts "FOO" and length 3 on the stack, but when compiling:
	: BAR WORD FOO ;
	is an error (or at least it doesn't do what you might expect).  Later we'll talk about compiling
	and immediate mode, and you'll understand why.
*/

	defcode "word",4,,WORD,EMIT
	CALL	_WORD
	PUSH	$v0	// word addr
	PUSH	$v1	// len
	NEXT


w_nl:	move	$a0, $t0
	CALL	nput_char
	li	$a0, '\n'
	CALL	nput_char

_WORD:

	/* Search for first non-blank character.  Also skip \ comments. */
1:	CALL	nget_key		// get next key, returned in $v0
	move	$a0, $v0
	CALL	nput_char	// echo it

	li	$t0, 92		// hex for '\'
	beq	$t0, $v0, 5f

	li	$t0, '\r'
	beq	$t0, $v0, w_nl

	li	$t0, '\n'
	beq	$t0, $v0, 1b

	li	$t0, 9	// tab
	beq	$t0, $v0, 1b

	li	$t0, ' '
	beq	$t0, $v0, 1b



	// li $v0, ' '

	/* Search for the end of the word, storing chars as we go. */
	la	$t7, word_buffer // pointer to return buffer
	move	$t6, $t7
2:
	sb	$v0, 0($t7)		// add character to return buffer
	addiu	$t7, $t7, 1	// inc

	CALL	nget_key		// get next key, returned in $v0
	move	$a0, $v0
	CALL	nput_char	// echo it

	li	$t0, ' '
	beq	$t0, $v0, 4f

	li	$t0, '\r'
	beq	$t0, $v0, 3f

	li	$t0, '\n'
	beq	$t0, $v0, 4f

	li	$t0, 9	// tab
	beq	$t0, $v0, 4f

	b  2b

3:
	li	$a0, '\n'	//
	CALL	nput_char	// echo it

4:

	sb	$0, 0($t7)		// null terminate
	/* Return the word (well, the static buffer) and length. */
	move	$v0, $t6		// restore word buffer addr
	sub	$v1, $t7, $v0       // len  v0 =word buff, v1= len
	RETURN

	/* Code to skip \ comments to end of the current line. */
5:
	CALL	nget_key		// get next key, returned in $v0
	li	$t0, '\n'		// CR
	beq	$t0, $v0, 1b
	li	$t0, '\r'		// ret
	beq	$t0, $v0, 1b
	b 5b


	.bss
	.align 4
	// pointer into LBUF
LBUFPTR:
	.space 4
XXXXPTR:
	.space 4
LBUF:
	.space 80
LBUFE:

	.text
	defcode "getline",7,,GETLINE,WORD
	CALL	_GETLINE
	POP	$t0	// drop GETLINE parm - use cursor/dont
	PUSH	$v0	// word addr
	PUSH	$v1	// len
	NEXT

	//  s0 = detect in cursor char sequence
	//  s1 = cursor buffer point
	//  s2 = LBUF
	//  s3 = LBUF end
	//  t4 = cursor index reg for backspace/delete
_GETLINE:
	move	$s0, $0		// current char in escape seq
	la	$s1, LBUF	// cursor position
	move	$s2, $s1	// keep a copy
	la	$s3, LBUFE-4	// end of buffer

	li	$t0, 32		// space
zap:	sb	$t0, 0($s1)	// store here
	addiu	$s1, $s1, 1	// inc
	bne	$s1, $s3, zap	// end of line?

	move	$s1, $s2	// cursor back to begining

1:	CALL	nget_key		// get next key, returned in $v0

	li	$t0, '\r'	// <return> ?
	bne	$t0, $v0, 2f	 // not
	b	_LDONE

2:	li	$t0, '\n'	// <cr> done ?
	bne	$t0, $v0, 3f	// not
	b	_LDONE

3:	lw	$t0, 0($s5)	// process cursor?
	beqz	$t0, 7f		// no skip

	li	$t0, 27		// escape
	bne	$t0, $v0, 4f	// not
	move	$s0, $v0	// save special register
	b	1b		// done

4:	li	$t0, '['	// [
	bne	$t0, $v0, 5f	// not
	beqz	$s0, _LBUF	// not in escape, buffer
	move	$s0, $v0	// save in special register
	b	1b		// done

5:	li	$t0, 'C'	// right key?
	bne	$t0, $v0, 6f	// not
	li	$t2, '['	// part of escape
	bne	$s0, $t2,_LBUF	// no, buffer
	lb	$a0, 0($s1)	// get char under cursor
	CALL	nput_char	// put it
	addiu	$s1, $s1, 1	// inc cursor pointer
	li	$s0, 0		// zero escape flag
	b	1b		// done

6:	li	$t0, 'D'	// left key?
	bne	$t0, $v0, 7f	// not
	li	$t2, '['	// part of escape
	bne	$s0, $t2,_LBUF	// no, buffer
	li	$a0, 8		// send backspace move
	CALL	nput_char
	addiu	$s1, $s1, -1	// dec cursor pointer
	li	$s0, 0		// zero escape flag
	b	1b		// done

7:	li	$t0, 8		// backspace key?
	bne	$t0, $v0, 8f	// not

bksp:	beq	$s1, $s2, 1b	// cursor at begin, done?
	li	$a0, 8		// send backspace
	CALL	nput_char	// put_char will nuke $t0
	move	$t4, $s1	// copy cursor
snip:	beq	$t4, $s3, repo	// to eol yet
	lbu	$t0, 0($t4)	// grab next byte
	sb	$t0, -1($t4)	// store here
	move	$a0, $t0
	CALL	nput_char	// put_char will nuke $t0
	addiu	$t4, $t4, 1	// inc cursor
	b	snip

	// reposition cursor
repo:	addiu	$s1, $s1, -1	// backup cursor 1
	move	$t4, $s1	// copy cursor
	addiu	$t4, $t4, 1	// deleted char
rev:	beq	$t4, $s3, 1b	// to eol yet
	li	$a0, 8
	CALL	nput_char	// put_char will nuke $t0
	addiu	$t4, $t4, 1	// inc cursor
	b	rev

8:	li	$t0, 127	// backspace key?
	bne	$t0, $v0, 9f	// not
	b	bksp		// do bksp

9:

_LBUF:	sb	$v0, 0($s1)	// store char at cursor buffer point
	move	$a0, $v0	// output
	CALL	nput_char	// put_char will nuke $t0
	addiu	$s1, $s1, 1	// inc cursor
	b	1b		// back


_LDONE:
	move	$v0, $s2	// return line buffer
	move	$v1, $s1
	sub	$v1, $v1, $v0
	RETURN



//
//
//  Assembler IO routines
//
//
//  these variables are shared with C main and use the global pointer so are in common section
//  common == RAM
//
	.align 4
	.comm key_buffer, 4
	.comm emit_buffer, 4
	.comm forth_mode, 4

	// back to bss
	.bss
	.align 4

	.global word_buffer
word_buffer:
	.space 64

	.global	initial_SP
initial_SP:
	.space 4

	// init_magic gets set to 0xBEEF to signify initialization has run
	.global	init_magic
init_magic:
	.space 4


//
//    get_key
//

	.text
1:	CALL	yield		// need to return to c caller to have them refill buffer
get_key:
	lb	$v0, %gp_rel(key_buffer)($gp)

	li	$t1, -1
	beq	$v0, $t1, 1b	// $v0 is return value

	move	$t0, $gp
	addiu	$t0, %gp_rel(key_buffer)

	sb	$t1, 0($t0)		// buffer is empty now
	RETURN				// result is in v0


1:	CALL	yield // need tp return to c caller to have them empty buffer
put_char:

	lb	$t2, %gp_rel(emit_buffer)($gp)

	li	$t1, -1
	bne	$t1, $t2, 1b

	move	$t0, $gp
	addiu	$t0, %gp_rel(emit_buffer)

	sb	$a0, 0($t0)
	RETURN


put_string:
	PUSH	$v0
	move	$v0, $a0
1:	lbu	$a0, 0($v0)
	beqz	$a0, 2f

	CALL	put_char
	addiu	$v0, $v0, 1
	b 1b

2:	POP	$v0
	RETURN


//
//    iskey: is key avail?
//
	.global ForthUSB

//iskey:
//	la	$t0, ForthUSB	// call C function
//	jalr	$ra, $t0
//	lb	$v0, %gp_rel(key_buffer)($gp)
//	RETURN				// result is in v0
//
//nget_key:
//1:	la	$t0, ForthUSB	// call C function
//	jalr	$ra, $t0
//	lb	$v0, %gp_rel(key_buffer)($gp)
//
//	li	$t1, -1
//	beq	$v0, $t1, 1b	// $v0 is return value
//
//	move	$t0, $gp
//	addiu	$t0, %gp_rel(key_buffer)
//
//	sb	$t1, 0($t0)		// store -1 in key_buffer
//	RETURN				// result is in v0


1:	PUSH	$a0
	la	$t0, ForthUSB	// call c function
	jalr	$ra, $t0
	POP	$a0
nput_char:
	// la	$t2, var_echo		// see if
	// lw	$t1, 0($t2)		// emiting
	// beqz	$t1, 2f			// = 0 ?

	lb	$t2, %gp_rel(emit_buffer)($gp)
	li	$t1, -1
	bne	$t1, $t2, 1b

	move	$t0, $gp
	addiu	$t0, %gp_rel(emit_buffer)

	sb	$a0, 0($t0)
2:
	RETURN


nput_string:
	PUSH	$s0
	move	$s0, $a0
1:	lbu	$a0, 0($s0)
	beqz	$a0, 2f

	CALL	nput_char
	addiu	$s0, $s0, 1
	b 1b

2:	POP	$s0
	RETURN

/*
	As well as reading in words we'll need to read in numbers and for that we are using a function
	called NUMBER.  This parses a numeric string such as one returned by WORD and pushes the
	number on the parameter stack.

	The function uses the variable BASE as the base (radix) for conversion, so for example if
	BASE is 2 then we expect a binary number.  Normally BASE is 10.

	If the word starts with a '-' character then the returned value is negative.

	If the string can't be parsed as a number (or contains characters outside the current BASE)
	then we need to return an error indication.  So NUMBER actually returns two items on the stack.
	At the top of stack we return the number of unconverted characters (ie. if 0 then all characters
	were converted, so there is no error).  Second from top of stack is the parsed number or a
	partial value if there was an error.
*/
	defcode "number",6,,NUMBER,GETLINE
	POP	$a0   // address
	POP	$a1   // length
	CALL	_NUMBER
	NEXT

//	$a0 = len, $a1 = string addr
//	t0 = temp len, t1 = temp string addr,
//       t2=BASE addr, t3=BASE, t4='-', t5=current char, t6 char conversion, t7=sign
_NUMBER:
	move	$t0, $a0	// address
	move	$t1, $a1	// length
	beqz	$t1, 5f			// if 0 len exit

	la	$t2, var_base		// get base addr
	lw	$t3, 0($t2)			// t3=base

	move	$t6, $0            // setup for current char conversion

	li	$t7, '-'
	lbu	$t5, 0($t0)		// first byte
	bne	$t7, $t5, 1f	// pos

	move	$t7, $0		// t7=!sign bit
	addiu	$t0, $t0, 1	// t1++

	addiu	$t1, $t1, -1	// dec length
	bnez $t1, 1f		// just a '-'? error

	move	$v1, $t1		// bad char
	move	$v0, $0
	RETURN

	// Loop reading digits.
1:	mul	$t6, $t6, $t3 	// t6 intermediate char, t3 = BASE
	lbu	$t5, 0($t0)
	addiu	$t0, $t0, 1	// t1++
	li	$t4, '0'
2:	sub	$t5, $t5, $t4
	bltz $t5, 4f		// < '0' done

	// positive number. Convert 0-9, A-Z to a number 0-35.
	slt	$t4, $t5, 10		// <= '9'?
	bnez $t4, 3f

	addiu	$t5, -17		// < 'A'? (17 is 'A'-'0')
	bltz $t5, 4f

	addiu	$t5, $t5, 10	// A-F += 10
3:	// t5 < base?
	slt	$t4, $t5, $t3	// t3=BASE
	beqz	$t4, 4f		// nope

	add	$t6, $t6, $t5
	addiu	$t1, $t1, -1	// dec length
	bnez $t1, 1b

4:	// Negate the result if first character was '-'  saved in t7
	bnez $t7, 5f

	negu $t6

5:	move	$v0, $t6
	move	$v1, $t1		// remaing string length <> 0 indictates error
	RETURN


/*
	DICTIONARY LOOK UPS ----------------------------------------------------------------------

	We're building up to our prelude on how FORTH code is compiled, but first we need yet more infrastructure.

	The FORTH word FIND takes a string (a word as parsed by WORD -- see above) and looks it up in the
	dictionary.  What it actually returns is the address of the dictionary header, if it finds it,
	or 0 if it didn't.

	So if DOUBLE is defined in the dictionary, then WORD DOUBLE FIND returns the following pointer:

    pointer to this
	|
	|
	V
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        | +          | EXIT       |
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+

	See also >CFA and >DFA.

	FIND doesn't find dictionary entries which are flagged as HIDDEN.  See below for why.
*/

	defcode "find",4,,FIND,NUMBER
	POP	$a1		// len
	POP	$a0		// word address
	CALL	_FIND
	PUSH	$v0	// dictonary entry, or zero
	NEXT

_FIND:	// Now we start searching backwards through the dictionary for this word.
	la	$t0, var_latest	// latest word
1:	lw	$t1, 0($t0)	// load next dict addr
	beqz	$t1, 4f		// end of list?

	// Compare the length expected and the length of the word.
	lbu	$t2, 4($t1)		// t2 = *(latest)->len
	andi	$t2, $t2, (F_HIDDEN|F_LENMASK)
	bne	$t2, $a1, 3f       // not equal

	// Compare the strings in detail.
	move	$t4, $t1
	move	$t5, $a0
2:	lbu	$t6, 5($t4)		// 5=word->(link+len)
	lbu	$t7, 0($t5)
	bne	$t6, $t7, 3f

	addiu	$t4, $t4, 1
	addiu	$t5, $t5, 1
	addiu	$t2, $t2, -1
	bnez	$t2, 2b

	// The strings are the same - return the header pointer in $v0
	// PUSH	$t1
	move	$v0, $t1
	RETURN

	// Strings are different, so...
3:	move	$t0, $t1   // Move back through the link field to the previous word
	b 1b			// .. and loop.

4:	// Not found.
	//PUSH	$0		// Return zero to indicate not found.
	move	$v0, $0
	RETURN

/*
	FIND returns the dictionary pointer, but when compiling we need the codeword pointer (recall
	that FORTH definitions are compiled into lists of codeword pointers).  The standard FORTH
	word >CFA turns a dictionary pointer into a codeword pointer.

	The example below shows the result of:

		WORD DOUBLE FIND >CFA

	FIND returns a pointer to this
	|				>CFA converts it to a pointer to this
	|					   |
	V					   V
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        | +          | EXIT       |
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
						   codeword

	Notes:

	Because names vary in length, this isn't just a simple increment.

	In this FORTH you cannot easily turn a codeword pointer back into a dictionary entry pointer, but
	that is not true in most FORTH implementations where they store a back pointer in the definition
	(with an obvious memory/complexity cost).  The reason they do this is that it is useful to be
	able to go backwards (codeword -> dictionary entry) in order to decompile FORTH definitions
	quickly.

	What does CFA stand for?  My best guess is "Code Field Address".
*/

	defcode ">cfa",4,,TCFA,FIND
	POP	$a0
	CALL	_TCFA
	PUSH	$v0
	NEXT

_TCFA:
	// move	$v0, $a0		// v0 = working ptr
	// lw	$v0, 4($a0)		// get flags/len

	addiu	$a0, $a0, 4	// v0 = working ptr
	lbu	$v0, 0($a0)		// get flags/len
	andi	$v0, F_LENMASK
	addiu	$v0, $v0, 1	// +1
	addiu	$v0, $v0, 3	// align 4 byte
	li	$t0, 3
	not	$t0
	and	$v0, $v0, $t0	// align strip low bit
	add	$v0, $a0, $v0	// plus lfa address
	RETURN

/*
	Related to >CFA is >DFA which takes a dictionary entry address as returned by FIND and
	returns a pointer to the first data field.

	FIND returns a pointer to this
	|				>CFA converts it to a pointer to this
	|					   |
	|					   |	>DFA converts it to a pointer to this
	|					   |		 |
	V					   V		 V
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        | +          | EXIT       |
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
						   codeword

	(Note to those following the source of FIG-FORTH / ciforth: My >DFA definition is
	different from theirs, because they have an extra indirection).

	You can see that >DFA is easily defined in FORTH just by adding 4 to the result of >CFA.
*/

	defword ">dfa",4,,TDFA,TCFA
	.int TCFA		// >CFA		(get code field address)
	.int INCR4		// 4+		(add 4 to it to get to next word)
	.int EXIT		// EXIT		(return from FORTH word)

	defcode "warm",4,,WARM,TDFA
	la	$t0, warm_init		// warm re-inits the forth machine, except dictonary pointer
	jr	$t0

	defword "version",7,,VERSION,WARM
	.int	LITSTRING
	.int	16
	.ascii	"rv5tch 20160319 "
	.int	TELL
	.int EXIT		// EXIT		(return from FORTH word)

/*
	COMPILING ----------------------------------------------------------------------

	Now we'll talk about how FORTH compiles words.  Recall that a word definition looks like this:

		: DOUBLE DUP + ;

	and we have to turn this into:

	  pointer to previous word
	   ^
	   |
	+--|------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        | +          | EXIT       |
	+---------+---+---+---+---+---+---+---+---+------------+--|---------+------------+------------+
	   ^       len                         pad  codeword      |
	   |							  V
	  LATEST points here				points to codeword of DUP

	There are several problems to solve.  Where to put the new word?  How do we read words?  How
	do we define the words : (COLON) and ; (SEMICOLON)?

	FORTH solves this rather elegantly and as you might expect in a very low-level way which
	allows you to change how the compiler works on your own code.

	FORTH has an INTERPRET function (a true interpreter this time, not DOCOL) which runs in a
	loop, reading words (using WORD), looking them up (using FIND), turning them into codeword
	pointers (using >CFA) and deciding what to do with them.

	What it does depends on the mode of the interpreter (in variable STATE).

	When STATE is zero, the interpreter just runs each word as it looks them up.  This is known as
	immediate mode.

	The interesting stuff happens when STATE is non-zero -- compiling mode.  In this mode the
	interpreter appends the codeword pointer to user memory (the HERE variable points to the next
	free byte of user memory -- see DATA SEGMENT section below).

	So you may be able to see how we could define : (COLON).  The general plan is:

	(1) Use WORD to read the name of the function being defined.

	(2) Construct the dictionary entry -- just the header part -- in user memory:

    pointer to previous word (from LATEST)			+-- Afterwards, HERE points here, where
	   ^							|   the interpreter will start appending
	   |							V   codewords.
	+--|------+---+---+---+---+---+---+---+---+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      |
	+---------+---+---+---+---+---+---+---+---+------------+
	           len                         pad  codeword

	(3) Set LATEST to point to the newly defined word, ...

	(4) .. and most importantly leave HERE pointing just after the new codeword.  This is where
	    the interpreter will append codewords.

	(5) Set STATE to 1.  This goes into compile mode so the interpreter starts appending codewords to
	    our partially-formed header.

	After : has run, our input is here:

	: DOUBLE DUP + ;
	         ^
		 |
		Next byte returned by KEY will be the 'D' character of DUP

	so the interpreter (now it's in compile mode, so I guess it's really the compiler) reads "DUP",
	looks it up in the dictionary, gets its codeword pointer, and appends it:

									     +-- HERE updated to point here.
									     |
									     V
	+---------+---+---+---+---+---+---+---+---+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        |
	+---------+---+---+---+---+---+---+---+---+------------+------------+
	           len                         pad  codeword

	Next we read +, get the codeword pointer, and append it:

											  +-- HERE updated to point here.
											  |
											  V
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        | +          |
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+
	           len                         pad  codeword

	The issue is what happens next.  Obviously what we _don't_ want to happen is that we
	read ";" and compile it and go on compiling everything afterwards.

	At this point, FORTH uses a trick.  Remember the length byte in the dictionary definition
	isn't just a plain length byte, but can also contain flags.  One flag is called the
	IMMEDIATE flag (F_IMMED in this code).  If a word in the dictionary is flagged as
	IMMEDIATE then the interpreter runs it immediately _even if it's in compile mode_.

	This is how the word ; (SEMICOLON) works -- as a word flagged in the dictionary as IMMEDIATE.

	And all it does is append the codeword for EXIT on to the current definition and switch
	back to immediate mode (set STATE back to 0).  Shortly we'll see the actual definition
	of ; and we'll see that it's really a very simple definition, declared IMMEDIATE.

	After the interpreter reads ; and executes it 'immediately', we get this:

	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      | DUP        | +          | EXIT       |
	+---------+---+---+---+---+---+---+---+---+------------+------------+------------+------------+
	           len                         pad  codeword					       ^
												       |
												      HERE
	STATE is set to 0.

	And that's it, job done, our new definition is compiled, and we're back in immediate mode
	just reading and executing words, perhaps including a call to test our new word DOUBLE.

	The only last wrinkle in this is that while our word was being compiled, it was in a
	half-finished state.  We certainly wouldn't want DOUBLE to be called somehow during
	this time.  There are several ways to stop this from happening, but in FORTH what we
	do is flag the word with the HIDDEN flag (F_HIDDEN in this code) just while it is
	being compiled.  This prevents FIND from finding it, and thus in theory stops any
	chance of it being called.

	The above explains how compiling, : (COLON) and ; (SEMICOLON) works and in a moment I'm
	going to define them.  The : (COLON) function can be made a little bit more general by writing
	it in two parts.  The first part, called CREATE, makes just the header:

						   +-- Afterwards, HERE points here.
						   |
						   V
	+---------+---+---+---+---+---+---+---+---+
	| LINK    | 6 | D | O | U | B | L | E | 0 |
	+---------+---+---+---+---+---+---+---+---+
	           len                         pad

	and the second part, the actual definition of : (COLON), calls CREATE and appends the
	DOCOL codeword, so leaving:

								+-- Afterwards, HERE points here.
								|
								V
	+---------+---+---+---+---+---+---+---+---+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 | DOCOL      |
	+---------+---+---+---+---+---+---+---+---+------------+
	           len                         pad  codeword

	CREATE is a standard FORTH word and the advantage of this split is that we can reuse it to
	create other types of words (not just ones which contain code, but words which contain variables,
	constants and other data).
*/

	defcode "create",6,,CREATE,VERSION

	la	$t2, var_here
	lw	$t2, 0($t2)	// t2 = *var_HERE

	la	$t3, var_latest

	lw	$t4, 0($t3)		// t4 = *LATEST
	sw	$t4, 0($t2)		// *HERE = t4 (store in new word link ptr)
	addiu	$t2, $t2, 4		// HERE+=4


	// Get the name length and address.
	POP	$t1		// length
	POP	$t0		// src addr

	sb	$t1, 0($t2)		// *HERE = length
	addiu	$t2, $t2, 1	// HERE++

	beqz	$t1, 2f		// len==zero?

	// copy len
	// copy name
1:	lbu	$t5, 0($t0)		// t5 = *src
	sb	$t5, 0($t2)		// *HERE = t5
	addiu	$t0, $t0, 1	// src++
	addiu	$t2, $t2, 1	// HERE++
	addiu	$t1, $t1, -1	// cnt--
	bnez	$t1, 1b		// done?

2:
	addiu	$t2,$t2, 3	// Align to next 4 byte boundary.
	li	$t3, 3		// 0xFFFFC
	not	$t3
	and	$t2, $t2, $t3	// Align to next 4 byte boundary.

	move	$t0, $t2		// $t0 = new val for HERE

	la	$t2, var_here
	la	$t3, var_latest

	lw	$t1, 0($t2)		// t1 = *HERE
	sw	$t1, 0($t3)		// LATEST = *HERE (word just created)

	sw	$t0, 0($t2)		// HERE = new HERE
	NEXT

/*
	Because I want to define : (COLON) in FORTH, not assembler, we need a few more FORTH words
	to use.

	The first is , (COMMA) which is a standard FORTH word which appends a 32 bit integer to the user
	memory pointed to by HERE, and adds 4 to HERE.  So the action of , (COMMA) is:

							previous value of HERE
								 |
								 V
	+---------+---+---+---+---+---+---+---+---+-- - - - - --+------------+
	| LINK    | 6 | D | O | U | B | L | E | 0 |             |  <data>    |
	+---------+---+---+---+---+---+---+---+---+-- - - - - --+------------+
	           len                         pad		              ^
									      |
									new value of HERE

	and <data> is whatever 32 bit integer was at the top of the stack.

	, (COMMA) is quite a fundamental operation when compiling.  It is used to append codewords
	to the current word that is being compiled.
*/

	defcode ",",1,,COMMA,CREATE
	POP	$a0
CALL	_COMMA			// a0 == data
	NEXT

_COMMA:
	la	$t0, var_here
	lw	$t1, 0($t0)
	sw	$a0, 0($t1)
	addiu	$t1, $t1, 4
	sw	$t1, 0($t0)
	RETURN

/*
	Our definitions of : (COLON) and ; (SEMICOLON) will need to switch to and from compile mode.

	Immediate mode vs. compile mode is stored in the global variable STATE, and by updating this
	variable we can switch between the two modes.

	For various reasons which may become apparent later, FORTH defines two standard words called
	[ and ] (LBRAC and RBRAC) which switch between modes:

	Word	Assembler	Action		Effect
	[	LBRAC		STATE := 0	Switch to immediate mode.
	]	RBRAC		STATE := 1	Switch to compile mode.

	[ (LBRAC) is an IMMEDIATE word.  The reason is as follows: If we are in compile mode and the
	interpreter saw [ then it would compile it rather than running it.  We would never be able to
	switch back to immediate mode!  So we flag the word as IMMEDIATE so that even in compile mode
	the word runs immediately, switching us back to immediate mode.
*/

	defcode "[",1,F_IMMED,LBRAC,COMMA
	la	$t0, var_state // Are we compiling or executing?
	sw	$0, 0($t0)
	NEXT

	defcode "]",1,,RBRAC,LBRAC
	la	$t0, var_state // Are we compiling or executing?
	li	$t1, 1
	sw	$t1, 0($t0)
	NEXT

/*
	Now we can define : (COLON) using CREATE.  It just calls CREATE, appends DOCOL (the codeword), sets
	the word HIDDEN and goes into compile mode.
*/

	defword ":",1,,COLON,RBRAC
	.int WORD		// Get the name of the new word
	.int CREATE		// CREATE the dictionary entry / header
	.int LIT, DOCOL, COMMA	// Append DOCOL  (the codeword).
	.int LATEST, FETCH, HIDDEN // Make the word hidden (see below for definition).
	.int RBRAC		// Go into compile mode.
	.int EXIT		// Return from the function.

/*
	; (SEMICOLON) is also elegantly simple.  Notice the F_IMMED flag.
*/

//	gas blows chunks on embeded ";"
//	so expand macro manually

//	defword ";",1,F_IMMED,SEMICOLON,COLON
//	.text
//	.int LIT, EXIT, COMMA	// Append EXIT (so the word will return).
//	.int LATEST, FETCH, HIDDEN // Toggle hidden flag -- unhide the word (see below for definition).
//	.int LBRAC		// Go back to IMMEDIATE mode.
//	.int EXIT		// Return from the function.

	.text
	.global name_SEMICOLON
name_SEMICOLON :
	.int name_COLON		// previous link
	.byte F_IMMED+1		// flags + length byte
	.byte 59		//  the name 59 = ;
	.global SEMICOLON
SEMICOLON :
	.int DOCOL		// codeword - the interpreter
	.int LIT, EXIT, COMMA	// Append EXIT (so the word will return).
	.int LATEST, FETCH, HIDDEN // Toggle hidden flag -- unhide the word (see below for definition).
	.int LBRAC		// Go back to IMMEDIATE mode.
	.int EXIT		// Return from the function.

/*
	EXTENDING THE COMPILER ----------------------------------------------------------------------

	Words flagged with IMMEDIATE (F_IMMED) aren't just for the FORTH compiler to use.  You can define
	your own IMMEDIATE words too, and this is a crucial aspect when extending basic FORTH, because
	it allows you in effect to extend the compiler itself.  Does gcc let you do that?

	Standard FORTH words like IF, WHILE, ." and so on are all written as extensions to the basic
	compiler, and are all IMMEDIATE words.

	The IMMEDIATE word toggles the F_IMMED (IMMEDIATE flag) on the most recently defined word,
	or on the current word if you call it in the middle of a definition.

	Typical usage is:

	: MYIMMEDWORD IMMEDIATE
		...definition...
	;

	but some FORTH programmers write this instead:

	: MYIMMEDWORD
		...definition...
	; IMMEDIATE

	The two usages are equivalent, to a first approximation.
*/

	defcode "immediate",9,F_IMMED,IMMEDIATE,SEMICOLON
	la	$t0, var_latest
	lw	$t0, 0($t0)
	addiu	$t0, $t0, 4
	lbu	$t1, 0($t0)
	xori	$t1, $t1, F_IMMED	// Toggle the IMMED bit.
	sb	$t1, 0($t0)
	NEXT

/*
	'addr HIDDEN' toggles the hidden flag (F_HIDDEN) of the word defined at addr.  To hide the
	most recently defined word (used above in : and ; definitions) you would do:

		LATEST @ HIDDEN

	'HIDE word' toggles the flag on a named 'word'.

	Setting this flag stops the word from being found by FIND, and so can be used to make 'private'
	words.  For example, to break up a large word into smaller parts you might do:

		: SUB1 ... subword ... ;
		: SUB2 ... subword ... ;
		: SUB3 ... subword ... ;
		: MAIN ... defined in terms of SUB1, SUB2, SUB3 ... ;
		HIDE SUB1
		HIDE SUB2
		HIDE SUB3

	After this, only MAIN is 'exported' or seen by the rest of the program.
*/

	defcode "hidden",6,,HIDDEN,IMMEDIATE
	POP	$t0
	addiu	$t0, $t0, 4
	lbu	$t1, 0($t0)
	xori	$t1, $t1, F_HIDDEN
	sb	$t1, 0($t0)
	NEXT

	defword "hide",4,,HIDE,HIDDEN
	.int WORD		// Get the word (after HIDE).
	.int FIND		// Look up in the dictionary.
	.int HIDDEN		// Set F_HIDDEN flag.
	.int EXIT		// Return.

/*
	' (TICK) is a standard FORTH word which returns the codeword pointer of the next word.

	The common usage is:

	' FOO ,

	which appends the codeword of FOO to the current word we are defining (this only works in compiled code).

	You tend to use ' in IMMEDIATE words.  For example an alternate (and rather useless) way to define
	a literal 2 might be:

	: LIT2 IMMEDIATE
		' LIT ,		\ Appends LIT to the currently-being-defined word
		2 ,		\ Appends the number 2 to the currently-being-defined word
	;

	So you could do:

	: DOUBLE LIT2 * ;

	(If you don't understand how LIT2 works, then you should review the material about compiling words
	and immediate mode).

	This definition of ' uses a cheat which I copied from buzzard92.  As a result it only works in
	compiled code.  It is possible to write a version of ' based on WORD, FIND, >CFA which works in
	immediate mode too.
*/
	defcode "'",1,,TICK,HIDE
	lw	$t0, 0($s7)		// get next word
	addiu	$s7, $s7, 4	// skip literal
	PUSH	$t0
	NEXT

/*
	BRANCHING ----------------------------------------------------------------------

	It turns out that all you need in order to define looping constructs, IF-statements, etc.
	are two primitives.

	BRANCH is an unconditional branch. 0BRANCH is a conditional branch (it only branches if the
	top of stack is zero).

	The diagram below shows how BRANCH works in some imaginary compiled word.  When BRANCH executes,
	%esi starts by pointing to the offset field (compare to LIT above):

	+---------------------+-------+---- - - ---+------------+------------+---- - - - ----+------------+
	| (Dictionary header) | DOCOL |            | BRANCH     | offset     | (skipped)     | word       |
	+---------------------+-------+---- - - ---+------------+-----|------+---- - - - ----+------------+
								   ^  |			      ^
								   |  |			      |
								   |  +-----------------------+
								  $S7 added to offset

	The offset is added to $S7 to make the new $S7, and the result is that when NEXT runs, execution
	continues at the branch target.  Negative offsets work as expected.

	0BRANCH is the same except the branch happens conditionally.

	Now standard FORTH words such as IF, THEN, ELSE, WHILE, REPEAT, etc. can be implemented entirely
	in FORTH.  They are IMMEDIATE words which append various combinations of BRANCH or 0BRANCH
	into the word currently being compiled.

	As an example, code written like this:

		condition-code IF true-part THEN rest-code

	compiles to:

		condition-code 0BRANCH OFFSET true-part rest-code
					  |		^
					  |		|
					  +-------------+
*/

	defcode "branch",6,,BRANCH,TICK
	lw	$t0, 0($s7)
	add	$s7, $s7, $t0
	NEXT

	defcode "0branch",7,,ZBRANCH,BRANCH
	POP	$t0
	beqz	$t0, code_BRANCH
	addiu	$s7, $s7, 4	// skip over offset
	NEXT

/*
	LITERAL STRINGS ----------------------------------------------------------------------

	LITSTRING is a primitive used to implement the ." and S" operators (which are written in
	FORTH).  See the definition of those operators later.

	TELL just prints a string to the serial port.
*/

	// compile as:
	// LITSTRING <string length> <string rounded/padded up 4 bytes>

	defcode "litstring",9,,LITSTRING,ZBRANCH
	lw	$t0, 0($s7)		// len
	addiu	$s7, $s7, 4	// skip len

	//lw	$t1, 0($s7)		// addr
	move	$t1, $s7		// addr
	// have to align(4) length
	addiu	$t2, $t0, 3	// t2 = len+3
	li	$t4, 3
	not	$t4
	and	$t2, $t2, $t4	// t2 &= ~(3)  mask low 2 bits
	add	$s7, $s7, $t2	// now add to IP to skip string

	PUSH	$t1		// push addr first
	PUSH	$t0		// then len

	NEXT

	defcode "tell",4,,TELL,LITSTRING
	POP	$t4		// len
	POP	$t5		// addr
1:	lbu	$a0, 0($t5)
	beqz	$t4, 2f
	CALL	nput_char
	addiu	$t5, $t5, 1
	addiu	$t4, $t4, -1
	b 1b
2:	NEXT

/*
	QUIT AND INTERPRET ----------------------------------------------------------------------

	QUIT is the first FORTH function called, almost immediately after the FORTH system "boots".
	As explained before, QUIT doesn't "quit" anything.  It does some initialisation (in particular
	it clears the return stack) and it calls INTERPRET in a loop to interpret commands.  The
	reason it is called QUIT is because you can call it from your own FORTH words in order to
	"quit" your program and start again at the user prompt.

	INTERPRET is the FORTH interpreter ("toploop", "toplevel" or "REPL" might be a more accurate
	description -- see: http://en.wikipedia.org/wiki/REPL).
*/

	// QUIT must not return (ie. must not call EXIT).
	defword "quit",4,,QUIT,TELL
	.int	RZ
	.int	RSPSTORE	// R0 RSP!, clear the return stack

	.int	INTERPRET	// interpret the next word
	.int	IDLEWORD	// idle var with word to run "Ok"
	.int	FETCH		//
	.int	EXECUTE
	.int	BRANCH
	.int	-20		// and loop (indefinitely)

/*
	This interpreter is pretty simple, but remember that in FORTH you can always override
	it later with a more powerful one!
 */
	defcode "interpret",9,,INTERPRET,QUIT
	CALL	_WORD
	PUSH	$v0
	PUSH	$v1

	li	$s2, 0	// init not literal

	move	$a0, $v0  // word
	move	$a1, $v1  // len
	// Is it in the dictionary?
	CALL	_FIND	// 1=found
	beqz	$v0, 1f	// not found

	POP	$a1	// really need to get rid of these
	POP	$a0

	//
	// convert v0/NFA to v0/CFA
	//
	// load immediate flag
	lbu	$t2, 4($v0)		// t2 = *(find)->len
	// get cfa uses sames a0/a1 as above
	move	$a0, $v0  // word
	move	$a1, $v1  // len
	CALL	_TCFA		// v0 has result
	andi	$t2, $t2, F_IMMED
	bnez	$t2, 4f		// if immed, jump to execute

	b 2f			// skip over number conversion

	// not in dict, do number
1:	POP	$a1			// address
	POP	$a0			// len
	CALL	_NUMBER
	bnez	$v1, 6f		// number conversion error
	PUSH	$v0		// save num

	la	$v0, LIT

	li	  $s2, 1		// literal flag

2:	// v0 has CFA of found word or LIT
	la	$t0, var_state // Are we compiling or executing?
	lw	$t1, 0($t0)
	beqz	$t1, 4f		// Jump if executing.

	// Compiling - just append the word to the current dictionary definition.
	move	$a0, $v0
	CALL	_COMMA

	beqz	$s2, 3f		// not a LIT

	POP	$a0			// the number
	CALL	_COMMA

3:	NEXT

4:	// Executing - run it!
	bnez	$s2, 5f	// Literal?

	// Not a literal, execute it now.  This never returns, but the codeword will
	// eventually call NEXT which will reenter the loop in QUIT.

	move	$s6, $v0
	lw	$t0, 0($s6)
	jr	$t0

	// number is on the stack
5:
	NEXT

6:	// Parse error (not a known word or a number in the current BASE).
	// Print an error message

	// a0 has the address, a1 has the len
	// zero terminate string
//	move	$t2, $a0	// src
//	la	$t1, errBuffer	// dst
//	move	$t0, $a1	// len

	la	$t0, var_errBuf	// var addr
	lw	$t1, 0($t0)	// var val
7:	beqz	$a1, 8f
	lbu	$t3, 0($a0)
	sb	$t3, 0($t1)
	addiu	$a1, $a1, -1
	addiu	$a0, $a0, 1
	addiu	$t1, $t1, 1
	b 7b

8:	la	$t0, var_errNo	// var addr
	li	$t1, 1		// error 1
	sw	$t1, 0($t0)
	NEXT

	//move	$t0, $a0	// addr
	//add	$t0, $a1	// len
	//sb	$0, 0($t0)	// zero
	//CALL	nput_string

	//la	$a0, errmsg1
	//CALL	nput_string

	//NEXT

	.align	4
	.section .rodata

/*      errors strings    */
errOk:  	.ascii "Ok"
errSyntax:	.ascii "<-wtf?"
errUnderflow:	.ascii "Underflow"

/*		string len, string ptr */
errTable:	.int	2, errOk
		.int	6, errSyntax
		.int	9, errUnderflow
		.int	0, 0

	.section .text

/*
	ODDS AND ENDS ----------------------------------------------------------------------

	CHAR puts the ASCII code of the first character of the following word on the stack.  For
	example CHAR A puts 65 on the stack.

	EXECUTE is used to run execution tokens.  See the discussion of execution tokens in the
	FORTH code for more details.

*/

	defcode "char",4,,CHAR,INTERPRET
	CALL	_WORD		// on return, v0=addr, v1=len
	lbu	$t0, 0($v0)
	PUSH	$t0
	NEXT

	defcode "execute",7,,EXECUTE,CHAR
	POP	$s6
	lw	$t0, 0($s6)
	jr	$t0
	NEXT			// never returns here


/*
	START OF FORTH CODE ----------------------------------------------------------------------

	We've now reached the stage where the FORTH system is running and self-hosting.  All further
	words can be written as FORTH itself, including words like IF, THEN, .", etc which in most
	languages would be considered rather fundamental.

	In Jonesforth these words are defined in a separate file. That is rather ... problematic
	... in many embedded tool chains, so they've been moved back into a single file.
*/

	defword "/",1,,DIVIDE,EXECUTE
	.int	DIVMOD
	.int	SWAP
	.int	DROP
	.int	EXIT

	defword "mod",3,,MODULO,DIVIDE
	.int	DIVMOD
	.int	DROP
	.int	EXIT

	defword "'\\n'",4,,NEWLINE,MODULO
	.int	LIT
	.int	10
	.int	EXIT

	defword "bl",2,,BLANK,NEWLINE
	.int	LIT
	.int	32
	.int	EXIT

	defword "cr",2,,CR,BLANK
	.int	NEWLINE
	.int	EMIT
	.int	LIT
	.int	13
	.int	EMIT
	.int	EXIT

	defword "space",5,,SPACE,CR
	.int	BLANK
	.int	EMIT
	.int	EXIT

	defword "negate",6,,NEGATE,SPACE
	.int	LIT
	.int	0
	.int	SWAP
	.int	SUB
	.int	EXIT

	defword "true",4,,TRUE,NEGATE
	.int	LIT
	.int	1
	.int	EXIT

	defword "false",5,,FALSE,TRUE
	.int	LIT
	.int	0
	.int	EXIT

	defword "not",3,,NOT,FALSE
	.int	ZEQU
	.int	EXIT

	defword "literal",7,F_IMMED,LITERAL,NOT
	.int	TICK
	.int	LIT
	.int	COMMA
	.int	COMMA
	.int	EXIT

	defword "':'",3,,COLONCHAR,LITERAL
	.int	LIT
	.int	0x3A
	.int	EXIT

// macro does not work because of special meaning of ;
//	defword "';'",3,,SEMICHAR,COLONCHAR
//	.int	LIT
//	.int	0x3B
//	.int	EXIT

	.global	name_SEMICHAR
name_SEMICHAR :
	.int	name_COLONCHAR	// previous link
	.byte	3			// flags + length byte
	.byte	39,59,39		//  the name 39 = ' 59 = ;
	.global	SEMICHAR
SEMICHAR :
	.int	DOCOL		// codeword - the interpreter
	.int	LIT
	.int	0x3B
	.int	EXIT		// Return from the function.

	defword "'('",3,,LPARCHAR,SEMICHAR
	.int	LIT
	.int	0x28
	.int	EXIT

	defword "')'",3,,RPARCHAR,LPARCHAR
	.int	LIT
	.int	0x29
	.int	EXIT

	defword "'\"'",3,,QUOTECHAR,RPARCHAR
	.int	LIT
	.int	0x22
	.int	EXIT

	defword "'A'",3,,ACHAR,QUOTECHAR
	.int	LIT
	.int	0x41
	.int	EXIT

	defword "'0'",3,,ZEROCHAR,ACHAR
	.int	LIT
	.int	0x30
	.int	EXIT

	defword "'-'",3,,DASHCHAR,ZEROCHAR
	.int	LIT
	.int	0x2D
	.int	EXIT

	defword "'.'",3,,DOTCHAR,DASHCHAR
	.int	LIT
	.int	0x2E
	.int	EXIT

	defword "[compile]",9,F_IMMED,COMPILE,DOTCHAR
	.int	WORD
	.int	FIND
	.int	TCFA
	.int	COMMA
	.int	EXIT

	defword "recurse",7,F_IMMED,RECURSE,COMPILE
	.int	LATEST
	.int	FETCH
	.int	TCFA
	.int	COMMA
	.int	EXIT

	defword "if",2,F_IMMED,IF,RECURSE
	.int	TICK
	.int	ZBRANCH
	.int	COMMA
	.int	HERE
	.int	FETCH
	.int	LIT
	.int	0
	.int	COMMA
	.int	EXIT

	defword "then",4,F_IMMED,THEN,IF
	.int	DUP
	.int	HERE
	.int	FETCH
	.int	SWAP
	.int	SUB
	.int	SWAP
	.int	STORE
	.int	EXIT

	defword "else",4,F_IMMED,ELSE,THEN
	.int	TICK
	.int	BRANCH
	.int	COMMA
	.int	HERE
	.int	FETCH
	.int	LIT
	.int	0
	.int	COMMA
	.int	SWAP
	.int	DUP
	.int	HERE
	.int	FETCH
	.int	SWAP
	.int	SUB
	.int	SWAP
	.int	STORE
	.int	EXIT

	defword "begin",5,F_IMMED,BEGIN,ELSE
	.int	HERE
	.int	FETCH
	.int	EXIT

	defword "until",5,F_IMMED,UNTIL,BEGIN
	.int	TICK
	.int	ZBRANCH
	.int	COMMA
	.int	HERE
	.int	FETCH
	.int	SUB
	.int	COMMA
	.int	EXIT

	defword "again",5,F_IMMED,AGAIN,UNTIL
	.int	TICK
	.int	BRANCH
	.int	COMMA
	.int	HERE
	.int	FETCH
	.int	SUB
	.int	COMMA
	.int	EXIT

	defword "while",5,F_IMMED,WHILE,AGAIN
	.int	TICK
	.int	ZBRANCH
	.int	COMMA
	.int	HERE
	.int	FETCH
	.int	LIT
	.int	0
	.int	COMMA
	.int	EXIT

	defword "repeat",6,F_IMMED,REPEAT,WHILE
	.int	TICK
	.int	BRANCH
	.int	COMMA
	.int	SWAP
	.int	HERE
	.int	FETCH
	.int	SUB
	.int	COMMA
	.int	DUP
	.int	HERE
	.int	FETCH
	.int	SWAP
	.int	SUB
	.int	SWAP
	.int	STORE
	.int	EXIT

	defword "unless",6,F_IMMED,UNLESS,REPEAT
	.int	TICK
	.int	NOT
	.int	COMMA
	.int	IF
	.int	EXIT

	defword "(",1,F_IMMED,COMMENT,UNLESS
	.int	LIT
	.int	1
	.int	KEY
	.int	DUP
	.int	LPARCHAR
	.int	EQU
	.int	ZBRANCH
	.int	20
	.int	DROP
	.int	INCR
	.int	BRANCH
	.int	24
	.int	RPARCHAR
	.int	EQU
	.int	ZBRANCH
	.int	8
	.int	DECR
	.int	DUP
	.int	ZEQU
	.int	ZBRANCH
	.int	-72
	.int	DROP
	.int	EXIT

	defword "free",4,,FREE,COMMENT
	.int	RZ
	.int	HERE
	.int	FETCH
	.int	SUB
	.int	LIT
	.int	4
	.int	DIVIDE
	.int	EXIT

	defword "nip",3,,NIP,FREE
	.int	SWAP
	.int	DROP
	.int	EXIT

	defword "tuck",4,,TUCK,NIP
	.int	SWAP
	.int	OVER
	.int	EXIT

	defword "pick",4,,PICK,TUCK
	.int	INCR
	.int	LIT
	.int	4
	.int	MUL
	.int	DSPFETCH
	.int	ADD
	.int	FETCH
	.int	EXIT

	defword "spaces",6,,SPACES,PICK
	.int	DUP
	.int	ZGT
	.int	ZBRANCH
	.int	20
	.int	SPACE
	.int	DECR
	.int	BRANCH
	.int	-28
	.int	DROP
	.int	EXIT

	defword "decimal",7,,DECIMAL,SPACES
	.int	LIT
	.int	10
	.int	BASE
	.int	STORE
	.int	EXIT

	defword "hex",3,,HEX,DECIMAL
	.int	LIT
	.int	16
	.int	BASE
	.int	STORE
	.int	EXIT

	defword "_u.",3,,_UDOT,HEX
	.int	BASE
	.int	FETCH
	.int	DIVMOD
	.int	QDUP
	.int	ZBRANCH
	.int	8
	.int	_UDOT
	.int	DUP
	.int	LIT
	.int	10
	.int	LT
	.int	ZBRANCH
	.int	16
	.int	ZEROCHAR
	.int	BRANCH
	.int	20
	.int	LIT
	.int	10
	.int	SUB
	.int	ACHAR
	.int	ADD
	.int	EMIT
	.int	EXIT

	defword ".s",2,,DOTS,_UDOT
	.int	DSPFETCH
	.int	DUP
	.int	SZ
	.int	FETCH
	.int	LT
	.int	ZBRANCH
	.int	32
	.int	DUP
	.int	FETCH
	.int	_UDOT
	.int	SPACE
	.int	INCR4
	.int	BRANCH
	.int	-48
	.int	DROP
	.int	EXIT

	defword "uwidth",6,,UWIDTH,DOTS
	.int	BASE
	.int	FETCH
	.int	DIVIDE
	.int	QDUP
	.int	ZBRANCH
	.int	20
	.int	UWIDTH
	.int	INCR
	.int	BRANCH
	.int	12
	.int	LIT
	.int	1
	.int	EXIT

	defword "u.r",3,,UDOTR,UWIDTH
	.int	SWAP
	.int	DUP
	.int	UWIDTH
	.int	ROT
	.int	SWAP
	.int	SUB
	.int	SPACES
	.int	_UDOT
	.int	EXIT

	defword ".r",2,,DOTR,UDOTR
	.int	SWAP
	.int	DUP
	.int	ZLT
	.int	ZBRANCH
	.int	36
	.int	NEGATE
	.int	LIT
	.int	1
	.int	SWAP
	.int	ROT
	.int	DECR
	.int	BRANCH
	.int	20
	.int	LIT
	.int	0
	.int	SWAP
	.int	ROT
	.int	SWAP
	.int	DUP
	.int	UWIDTH
	.int	ROT
	.int	SWAP
	.int	SUB
	.int	SPACES
	.int	SWAP
	.int	ZBRANCH
	.int	12
	.int	DASHCHAR
	.int	EMIT
	.int	_UDOT
	.int	EXIT

	defword ".",1,,DOT,DOTR
	.int	LIT
	.int	0
	.int	DOTR
	.int	SPACE
	.int	EXIT

	defword "u.",2,,UDOT,DOT
	.int	_UDOT
	.int	SPACE
	.int	EXIT

	defword "?",1,,QUESTION,UDOT
	.int	FETCH
	.int	DOT
	.int	EXIT

	defword "within",6,,WITHIN,QUESTION
	.int	NROT
	.int	OVER
	.int	LE
	.int	ZBRANCH
	.int	40
	.int	GT
	.int	ZBRANCH
	.int	16
	.int	TRUE
	.int	BRANCH
	.int	8
	.int	FALSE
	.int	BRANCH
	.int	12
	.int	TWODROP
	.int	FALSE
	.int	EXIT

	defword "depth",5,,DEPTH,WITHIN
	.int	SZ
	.int	FETCH
	.int	DSPFETCH
	.int	SUB
	.int	DECR4
	.int	EXIT

	defword "aligned",7,,ALIGNED,DEPTH
	.int	LIT
	.int	3
	.int	ADD
	.int	LIT
	.int	3
	.int	INVERT
	.int	AND
	.int	EXIT

	defword "align",5,,ALIGN,ALIGNED
	.int	HERE
	.int	FETCH
	.int	ALIGNED
	.int	HERE
	.int	STORE
	.int	EXIT

	defword "c,",2,,CCOMMA,ALIGN
	.int	HERE
	.int	FETCH
	.int	STOREBYTE
	.int	LIT
	.int	1
	.int	HERE
	.int	ADDSTORE
	.int	EXIT

	defword "s\"",2,F_IMMED,SQUOTE,CCOMMA
	.int	STATE
	.int	FETCH
	.int	ZBRANCH
	.int	120
	.int	TICK
	.int	LITSTRING
	.int	COMMA
	.int	HERE
	.int	FETCH
	.int	LIT
	.int	0
	.int	COMMA
	.int	KEY
	.int	DUP
	.int	QUOTECHAR
	.int	NEQU
	.int	ZBRANCH
	.int	16
	.int	CCOMMA
	.int	BRANCH
	.int	-32
	.int	DROP
	.int	DUP
	.int	HERE
	.int	FETCH
	.int	SWAP
	.int	SUB
	.int	DECR4
	.int	SWAP
	.int	STORE
	.int	ALIGN
	.int	BRANCH
	.int	84
	.int	HERE
	.int	FETCH
	.int	KEY
	.int	DUP
	.int	QUOTECHAR
	.int	NEQU
	.int	ZBRANCH
	.int	24
	.int	OVER
	.int	STOREBYTE
	.int	INCR
	.int	BRANCH
	.int	-40
	.int	DROP
	.int	HERE
	.int	FETCH
	.int	SUB
	.int	HERE
	.int	FETCH
	.int	SWAP
	.int	EXIT

	defword ".\"",2,F_IMMED,DOTQUOTE,SQUOTE
	.int	STATE
	.int	FETCH
	.int	ZBRANCH
	.int	28
	.int	SQUOTE
	.int	TICK
	.int	TELL
	.int	COMMA
	.int	BRANCH
	.int	48
	.int	KEY
	.int	DUP
	.int	QUOTECHAR
	.int	EQU
	.int	ZBRANCH
	.int	12
	.int	DROP
	.int	EXIT
	.int	EMIT
	.int	BRANCH
	.int	-40
	.int	EXIT

	defword "constant",8,,CONSTANT,DOTQUOTE
	.int	WORD
	.int	CREATE
	.int	__DOCOL
	.int	COMMA
	.int	TICK
	.int	LIT
	.int	COMMA
	.int	COMMA
	.int	TICK
	.int	EXIT
	.int	COMMA
	.int	EXIT

	defword "allot",5,,ALLOT,CONSTANT
	.int	HERE
	.int	FETCH
	.int	SWAP
	.int	HERE
	.int	ADDSTORE
	.int	EXIT

	defword "cells",5,,CELLS,ALLOT
	.int	LIT
	.int	4
	.int	MUL
	.int	EXIT

	defword "variable",8,,VARIABLE,CELLS
	.int	LIT
	.int	1
	.int	CELLS
	.int	ALLOT
	.int	WORD
	.int	CREATE
	.int	__DOCOL
	.int	COMMA
	.int	TICK
	.int	LIT
	.int	COMMA
	.int	COMMA
	.int	TICK
	.int	EXIT
	.int	COMMA
	.int	EXIT

	defword "value",5,,VALUE,VARIABLE
	.int	WORD
	.int	CREATE
	.int	__DOCOL
	.int	COMMA
	.int	TICK
	.int	LIT
	.int	COMMA
	.int	COMMA
	.int	TICK
	.int	EXIT
	.int	COMMA
	.int	EXIT

	defword "to",2,F_IMMED,TO,VALUE
	.int	WORD
	.int	FIND
	.int	TDFA
	.int	INCR4
	.int	STATE
	.int	FETCH
	.int	ZBRANCH
	.int	40
	.int	TICK
	.int	LIT
	.int	COMMA
	.int	COMMA
	.int	TICK
	.int	STORE
	.int	COMMA
	.int	BRANCH
	.int	8
	.int	STORE
	.int	EXIT

	defword "+to",3,F_IMMED,ADDTO,TO
	.int	WORD
	.int	FIND
	.int	TDFA
	.int	INCR4
	.int	STATE
	.int	FETCH
	.int	ZBRANCH
	.int	40
	.int	TICK
	.int	LIT
	.int	COMMA
	.int	COMMA
	.int	TICK
	.int	ADDSTORE
	.int	COMMA
	.int	BRANCH
	.int	8
	.int	ADDSTORE
	.int	EXIT

	defword "id.",3,,IDDOT,ADDTO
	.int	INCR4
	.int	DUP
	.int	FETCHBYTE
	.int	__F_LENMASK
	.int	AND
	.int	DUP
	.int	ZGT
	.int	ZBRANCH
	.int	40
	.int	SWAP
	.int	INCR
	.int	DUP
	.int	FETCHBYTE
	.int	EMIT
	.int	SWAP
	.int	DECR
	.int	BRANCH
	.int	-48
	.int	TWODROP
	.int	EXIT

	defword "?hidden",7,,QHIDDEN,IDDOT
	.int	INCR4
	.int	FETCHBYTE
	.int	__F_HIDDEN
	.int	AND
	.int	EXIT

	defword "?immediate",10,,QIMMEDIATE,QHIDDEN
	.int	INCR4
	.int	FETCHBYTE
	.int	__F_IMMED
	.int	AND
	.int	EXIT

	defword "words",5,,WORDS,QIMMEDIATE
	.int	LATEST
	.int	FETCH
	.int	QDUP
	.int	ZBRANCH
	.int	48
	.int	DUP
	.int	QHIDDEN
	.int	NOT
	.int	ZBRANCH
	.int	16
	.int	DUP
	.int	IDDOT
	.int	SPACE
	.int	FETCH
	.int	BRANCH
	.int	-52
	.int	CR
	.int	EXIT

	defword "forget",6,,FORGET,WORDS
	.int	WORD
	.int	FIND
	.int	QDUP
	.int	ZBRANCH
	.int	28
	.int	DUP
	.int	FETCH
	.int	LATEST
	.int	STORE
	.int	HERE
	.int	STORE
	.int	EXIT

	defword "dump",4,,DUMP,FORGET
	.int	BASE
	.int	FETCH
	.int	NROT
	.int	HEX
	.int	QDUP
	.int	ZBRANCH
	.int	296
	.int	OVER
	.int	LIT
	.int	8
	.int	UDOTR
	.int	SPACE
	.int	TWODUP
	.int	DECR
	.int	LIT
	.int	15
	.int	AND
	.int	INCR
	.int	QDUP
	.int	ZBRANCH
	.int	52
	.int	SWAP
	.int	DUP
	.int	FETCHBYTE
	.int	LIT
	.int	2
	.int	DOTR
	.int	SPACE
	.int	INCR
	.int	SWAP
	.int	DECR
	.int	BRANCH
	.int	-56
	.int	DROP
	.int	TWODUP
	.int	DECR
	.int	LIT
	.int	15
	.int	AND
	.int	INCR
	.int	QDUP
	.int	ZBRANCH
	.int	92
	.int	SWAP
	.int	DUP
	.int	FETCHBYTE
	.int	DUP
	.int	LIT
	.int	32
	.int	LIT
	.int	128
	.int	WITHIN
	.int	ZBRANCH
	.int	16
	.int	EMIT
	.int	BRANCH
	.int	16
	.int	DROP
	.int	DOTCHAR
	.int	EMIT
	.int	INCR
	.int	SWAP
	.int	DECR
	.int	BRANCH
	.int	-96
	.int	DROP
	.int	CR
	.int	DUP
	.int	DECR
	.int	LIT
	.int	15
	.int	AND
	.int	INCR
	.int	TUCK
	.int	SUB
	.int	TOR
	.int	ADD
	.int	FROMR
	.int	BRANCH
	.int	-300
	.int	DROP
	.int	BASE
	.int	STORE
	.int	EXIT

	defword "case",4,F_IMMED,CASE,DUMP
	.int	LIT
	.int	0
	.int	EXIT

	defword "of",2,F_IMMED,OF,CASE
	.int	TICK
	.int	OVER
	.int	COMMA
	.int	TICK
	.int	EQU
	.int	COMMA
	.int	IF
	.int	TICK
	.int	DROP
	.int	COMMA
	.int	EXIT

	defword "endof",5,F_IMMED,ENDOF,OF
	.int	ELSE
	.int	EXIT

	defword "endcase",7,F_IMMED,ENDCASE,ENDOF
	.int	TICK
	.int	DROP
	.int	COMMA
	.int	QDUP
	.int	ZBRANCH
	.int	16
	.int	THEN
	.int	BRANCH
	.int	-20
	.int	EXIT

	defword "cfa>",4,,TOCFA,ENDCASE
	.int	LATEST
	.int	FETCH
	.int	QDUP
	.int	ZBRANCH
	.int	44
	.int	TWODUP
	.int	SWAP
	.int	LT
	.int	ZBRANCH
	.int	12
	.int	NIP
	.int	EXIT
	.int	FETCH
	.int	BRANCH
	.int	-48
	.int	DROP
	.int	LIT
	.int	0
	.int	EXIT

	defword ":noname",7,,NONAME,TOCFA
	.int	LIT
	.int	0
	.int	LIT
	.int	0
	.int	CREATE
	.int	HERE
	.int	FETCH
	.int	LIT
	.int	DOCOL
	.int	COMMA
	.int	RBRAC
	.int	EXIT

# : ['] IMMEDIATE ' LIT , ;
# compile TICK

	defword "[']",3,F_IMMED,CTICK,NONAME
	.int	TICK
	.int	LIT
	.int	COMMA
	.int	EXIT

	defword "idle",4,,IDLE,CTICK
	.int	STATE
	.int	FETCH
	.int	ZEQU
	.int	ZBRANCH
	.int	88
	.int	DSPFETCH
	.int	SZ
	.int	FETCH
	.int	LE
	.int	ZBRANCH
	.int	28
	.int	LITSTRING
	.int	3
	.ascii	"Ok "
	.int	TELL
	.int	BRANCH
	.int	40
	.int	LITSTRING
	.int	10
	.ascii	"Underflow "
	.int	TELL
	.int	SZ
	.int	FETCH
	.int	DSPSTORE
	.int	EXIT


/* : nidle state @ 0= 0branch 60 dsp@ s0 @ > 0branch 32 2 errNo ! s0 @ dsp! error ; */

//	defcode "yield",5,,YIELDC,IDLE
//	move	$t0, $gp
//	addiu	$t0, %gp_rel(forth_mode)
//
//	li	$t1, 0		// 0
//	sb	$t1, 0($t0)	// store 0 in forth_mode
//	CALL	yield
//	NEXT

	/****** BADGE-SPECIFIC WORDS **************************************************************/

	/****************** Core Routines *********************************************************/

//	.global ReadCoreTimer
//	defcode "readCoreTimer",13,,FreadCoreTimer,YIELDC
//	la	$t0, ReadCoreTimer
//	jalr	$ra, $t0
//	PUSH	$v0		// return value
//	NEXT

	/****************** Display Routines *******************************************************/
	/** these forth words wrap routines from the FrameBuffer library (see fb.c) **/

	/*
	 * redled, greenled, blueled set respective LED color value: 0-255. Value will be adjusted
	 * by current brightness level.
	 */

//	.global timer_red
//	defcode "redled",6,,Fredled,IDLE /* ( u -- ) */
//	POP	$a0
//	la	$t0, timer_red // Load the address of red into t0
//	jalr	$ra, $t0 // ra holds return address, jump to t0
//	NEXT
//
//	.global timer_green
//	defcode "greenled",8,,Fgreenled,Fredled /* ( u -- ) */
//	POP	$a0
//	la	$t0, timer_green
//	jalr	$ra, $t0
//	NEXT
//
//	.global timer_blue
//	defcode "blueled",7,,Fblueled,Fgreenled /* ( u -- ) */
//	POP	$a0
//	la	$t0, timer_blue
//	jalr	$ra, $t0
//	NEXT

	.global FbClear
	defcode "fbclear",7,,Ffbclear,IDLE /* ( -- ) */
	la	$t0, FbClear
	jalr	$ra, $t0
	NEXT

	.global LCDReset
	defcode "lcdreset",8,,Flcdreset,Ffbclear /* ( -- ) */
	la	$t0, LCDReset
	jalr	$ra, $t0
	NEXT

	.global FbBackgroundColor
	defcode "fbbgc",5,,Ffbbgc,Flcdreset
	POP	$a0
	la	$t0, FbBackgroundColor
	jalr	$ra, $t0
	NEXT

	.global FbColor
	defcode "fbcolor",7,,Ffbcolor,Ffbbgc
	POP	$a0
	la	$t0, FbColor
	jalr	$ra, $t0
	NEXT

	.global FbLine
	defcode "fbline",6,,Ffbline,Ffbcolor
	POP	$a3
	POP	$a2
	POP	$a1
	POP	$a0
	la	$t0, FbLine
	jalr	$ra, $t0
	NEXT

	.global FbMove
	defcode "fbmove",6,,Ffbmove,Ffbline
	POP	$a1
	POP	$a0
	la	$t0, FbMove
	jalr	$ra, $t0
	NEXT

	.global FbSwapBuffers
	defcode "fbsb",4,,Ffbsb,Ffbmove
	la	$t0, FbSwapBuffers
	jalr	$ra, $t0
	NEXT

	.global FbCharacter
	defcode "fbchar",6,,Ffbchar,Ffbsb
	POP	$a0
	la	$t0, FbCharacter
	jalr	$ra, $t0
	NEXT

	.global FbFilledRectangle
	defcode "fbfrect",7,,Ffbfrect,Ffbchar
	POP	$a1
	POP	$a0
	la	$t0, FbFilledRectangle
	jalr	$ra, $t0
	NEXT

	.global FbPoint
	defcode "fbpoint",7,,Ffbpoint,Ffbfrect
	POP	$a1
	POP	$a0
	la	$t0, FbPoint
	jalr	$ra, $t0
	NEXT

	.global FbHorizontalLine
	defcode "fbhline",7,,Ffbhline,Ffbpoint
	POP	$a3
	POP	$a2
	POP	$a1
	POP	$a0
	la	$t0, FbHorizontalLine
	jalr	$ra, $t0
	NEXT

	.global FbVerticalLine
	defcode "fbvline",7,,Ffbvline,Ffbhline
	POP	$a3
	POP	$a2
	POP	$a1
	POP	$a0
	la	$t0, FbVerticalLine
	jalr	$ra, $t0
	NEXT

	.global FbRectangle
	defcode "fbrect",6,,Ffbrect,Ffbvline
	POP	$a1
	POP	$a0
	la	$t0, FbRectangle
	jalr	$ra, $t0
	NEXT

	.global setNote
	defcode "setnote",7,,Fsetnote,Ffbrect
	POP	$a1
	POP	$a0
	la	$t0, setNote
	jalr	$ra, $t0
	NEXT

//	.global print_forth_flag1
//	defcode "getctfflag",10,,Fprint_forth_flag1,Fsetnote
//	la	$t0, print_forth_flag1
//	jalr	$ra, $t0
//	NEXT
//
//	.global send_forth_flag
//	defcode "sendctfflag",11,,Fsend_forth_flag,Fprint_forth_flag1
//	POP	$a0
//	la	$t0, send_forth_flag
//	jalr	$ra, $t0
//	NEXT

	//void DelayMs( unsigned short int ms )
//	.global delay_ms
//	defcode "delay_ms",8,,Fdelay_ms,Fsend_forth_flag
//	POP	$a0
//	la $t0, DelayMs
//	jalr $ra, $t0
//	NEXT

	/*

	In this FORTH, HANG must be the last word in the built-in (assembler) dictionary because we
	initialise the LATEST variable to point to it.  This means that if you want to extend the
	assembler part, you must put new words before HANG, or else change how LATEST is
	initialised.

	*/
	/* SEE will crash on this word since it finds the begin/end */
	/* and this word is between flash and ram words */
	defword "_",1,F_HIDDEN,HANG,Fsetnote
	.int	EXIT

/*
	We allocate static buffers for the return static and input buffer (used when
	reading in files and text that the user types in).
*/

	.bss
#	.align	4096
	.align	4


/*	.bss */

/* in case of stack underflow */
	.space	16	/* 4 cells */

errBuffer:
	.space	80	/* 80 cells */

/* If we are running under the EMU */
/* we start the c process, so have to */
/* set this up */
	.if	0
	.section .stack
	.equ	C_STACK_SIZE, 512
	.space	C_STACK_SIZE
c_stack_top:
	.endif

/* END OF jonesforth.S */


/* emacs configuration:
	ongoing problem: getting emacs to leave whitespace alone.
 Local Variables:
 fill-column: 100
 tab-width: 8
 indent-tabs-mode: t
 End:
*/
