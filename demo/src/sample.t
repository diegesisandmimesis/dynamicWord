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
// voidWordAsTitle().  The second arg ("voidFlag" in single quotes) is the
// key we test via gRevealed() to see if we use the initial or revealed
// words we know.  The remaining args are, in order, the initial word
// and the revealed word.  We could leave it at that, but we also include
// additional declarations for the "title" word substitutions.
DefineDynamicWord(void, 'voidFlag', 'unknown void', 'formless void')
	initWordAsTitle = 'Void of Some Kind'
	wordAsTitle = 'Formless Void'
;

// And here we use the dynamic word we defined above.  voidWordAsTitle()
// will return "Void of Some Kind" or "Formless Void" based on whether
// or not gRevealed('voidFlag') returns true or not.
startRoom:      Room '<<voidWordAsTitle()>>'
	// The description contains the "normal" word, which will be
	// "unknown void" or "formless void" based on the same gRevealed()
	// check described above.
        "This is a <<voidWord()>>.  There's a plaque on the wall. "
	north = otherRoom
	south = stateRoom
;
// Now we add a bit of scenery.  Looking reveals 'voidFlag'.
+Fixture 'plaque/sign' 'plaque'
	"The plaque identifies this room as the Formless Void.
	<.reveal voidFlag> "
;
+me: Person;

// Here we define a dynamic word with a custom check() method.  Here
// we write a check for two different gRevealed() IDs and return true
// only when both have been revealed.
// This definition also doesn't include explicit values for the
// word as a title, so the default logic (capitalize the first letter of
// every word) will be used on the basic word values ("different room"
// and "purple room") instead.
DefineDynamicWord(other, 'otherRoom', 'different room', 'purple room')
	check() { return(gRevealed('redFlag') && gRevealed('blueFlag')); }
;

otherRoom: Room '<<otherWordAsTitle()>>'
	// The only interesting thing we're doing here is using the
	// alternate syntax.  We can use dWord(id) for any ID we've
	// previously defined.  The ID has to match whatever we gave as
	// the second argument in a DefineDynamicWord() statement.
	// Note that in this case the ID doesn't correspond to the
	// gRevealed() check we use in the dynamic word...it's just an
	// arbitrary ID in this case.
	"This is a <<dWord('otherRoom')>>.  There are two signs here, one
	red and one blue. "
	south = startRoom
;
+Fixture 'red plaque/sign' 'red sign'
	"The sign says this room has some red in it.
	<.reveal redFlag> "
;
+Fixture 'blue plaque/sign' 'blue sign'
	"The sign says this room has some blue in it.
	<.reveal blueFlag> "
;

// Define a state-based word.  The first two arguments are the same as
// in DefineDynamicWord, explained above.  The third argument is the
// "default" word to use if no defined state matches.  The fourth argument
// is an inline LookupTable of words and the conditions in which to use
// them.
// In the example below, 'room with a foo' will be used if gRevealed('rFoo')
// is true, 'room with a bar' will be used if gRevealed('rBar') is true,
// 'room with a foo and bar' will be used if both are true, and
// 'mysterious room' will be used if none of the above are apply.
// Note that the LAST MATCHING condition's word will be used.
// Also note that the first condition uses a method on the StateWord instance.
// This is an unnecessary complication in this case (because the method just
// checks gRevealed()) but illustrates that you can write your own check
// methods that do whatever you want, they just have to return true if
// the state is active.
DefineStateWord(fsm, 'fsmID', 'mysterious room', [
		'room with a foo' -> &checkFoo,
		'room with a bar' -> 'rBar',
		'room with a foo and bar' -> [ 'rFoo', 'rBar' ]
	])
	checkFoo() { return(gRevealed('rFoo')); }
;

// A room to demonstrate the above.
stateRoom: Room '<<fsmWordAsTitle()>>'
	"This is a <<dWord('fsmID')>>.  There are two signs here, one
	foo and one bar. "
	north = startRoom
;
+Fixture 'foo plaque/sign' 'foo sign'
	"The sign says this room has some foo in it.
	<.reveal rFoo> "
;
+Fixture 'bar plaque/sign' 'bar sign'
	"The sign says this room has some bar in it.
	<.reveal rBar> "
;

gameMain: GameMainDef initialPlayerChar = me;
