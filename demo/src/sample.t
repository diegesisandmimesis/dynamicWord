#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the dynamicWord library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "dynamicWord.h"

versionInfo:    GameID
        name = 'dynamicWord Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the dynamicWord library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the dynamicWord library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;

// Define a dynamic word.  The first are is the base we'll use for
// our substitution funtions:  "void" will get us voidWord() and
// voidLongWord().  The second arg ("void" in single quotes) is the
// key we test via gRevealed() to see if we use the initial or revealed
// words we know.  The remaining args are, in order, the initial word
// and the revealed word.  We could leave it at that, but we also include
// additional declarations for the "long" word substitutions.
DefineDynamicWord(void, 'void', 'void', 'formless void')
	initWordAsTitle = 'Void of Some Kind'
	wordAsTitle = 'Formless Void'
;

// And here we use the dynamic word we defined above.  voidWord()
// will return "Void of Some Kind" or "Formless Void" based on whether
// or not gRevealed('void') returns true or not.
startRoom:      Room '<<voidWordAsTitle()>>'
	// The description contains the "long" word, which will be
	// "void" or "formless void" based on the same gRevealed() check.
        "This is a <<voidWord()>>.  There's a plaque on the wall.
	This is a <<dWord('void')>> called <q><<dWord('void', dTitle)>></q>. 
	"
;
// Now we add a bit of scenery.  Looking reveals the 'void' key.
+Fixture 'plaque/sign' 'plaque'
	"The plaque identifies this room as the Featureless Void.
	<.reveal void> "
;
+me: Person;

gameMain: GameMainDef initialPlayerChar = me;
