#charset "us-ascii"
//
// eventTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the dynamicWord library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f eventTest.t3m
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

// State word for a simple mystery story:
// The cave starts out as the "mysterious cave" when the player knows
// nothing about it.  The name is updated as the player discovers what
// for want of a better word we'll call "clues".
DefineStateWord(cave, 'cave', 'mysterious cave', [
		'Bob\'s secret hideout' -> &checkBob,	
		'the killer\'s hidden lair' -> &checkKiller,
		'the killer\'s (Bob\'s) secret lair'
			-> [ &checkBob, &checkKiller ]
	])
	// See if the player has learned that the cave is Bob's.
	checkBob() {
		if(gRevealed('bobFlag')) {
			// We set isProperName so we can get "a mysterious cave"
			// and "Bob's secret hideout" by using {a cave/him}.
			isProperName = true;
			return(true);
		}
		return(nil);
	}
	// See if the player has learned that the cave is the killer's.
	checkKiller() {
		if(gRevealed('killerFlag')) {
			isProperName = true;
			return(true);
		}
		return(nil);
	}
;

// We have to use caveWordAsTitle() in the roomName because (afaik) there
// isn't any way to convert a message param substitution into title case.
startRoom:      Room 'Entrance to {a caveTitle/him}'
        "This is the entrance to {a cave/him}.  There's large steel door
	on the north wall with a sign on it. "
;
// The sign that reveals that the cave is Bob's.
+Fixture 'sign' 'sign'
	"The sign says, <q>Bob's Secret Hideout</q>.
	<.reveal bobFlag> "
;
+me: Person;
// The piece of evidence that reveals that the cave is the killer's.
+knife: Thing 'bloody butcher knife' 'butcher knife'
	"A butcher knife.  The blood on the blade indicates it is
	the murder weapon.
	<.reveal killerFlag> "
;

gameMain: GameMainDef initialPlayerChar = me;
