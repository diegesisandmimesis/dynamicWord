#charset "us-ascii"
//
// dynamicWord.t
//
//	This module provides a simple way to do string substitutions based
//	on whether or not something has been revealed.
//
//	Usage:
//
//		// Create a dynamic word.
//		// This will create a global function fooWord() that will
//		// test gRevealed('fooFlag') and return 'unknown foo' if
//		// it is not revealed, and 'known foo' if it is revealed.
//		DefineDynamicWord(foo, 'fooFlag', 'unknown foo', 'known foo');
//
//		// The first time this object is examined the description will
//		// be "It is a pebble that says unknown foo. ", and every
//		// subsequent time it is examined the description will be
//		// "It is a pebble that says known foo. ".
//		pebble: Thing 'small round pebble' 'pebble'
//			"It is a pebble that says <<fooWord()>>.
//			<.reveal fooFlag> "
//		;
//		// Similar to above, using alternate syntax.
//		stone: Thing 'stone' 'stone'
//			"It is a stone that says <<dWord('fooFlag')>>.
//			<.reveal fooFlag> "
//		;
//
//
//	
#include <adv3.h>
#include <en_us.h>

#include "dynamicWord.h"

// Module ID for the library
dynamicWordModuleID: ModuleID {
        name = 'Dynamic Word Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Enum containing all our dynamic word types.
enum dWord, dTitle;

// Preinit object that we use as a container for methods.
dynamicWords: PreinitObject
	// A lookup table indexed by key (the one used for gRevealed())
	// containing all our DynamicWord instances.
	_table = nil

	// Setup our lookup table of words
	execute() {
		_table = new LookupTable();
		forEachInstance(DynamicWord, function(o) {
			_table[o.id] = o;
		});
	}

	// Return the current word matching the given ID and, optionally,
	// of the type specified in the flags.
	getWord(id, flags?) {
		local o;

		o = _table[id];
		if(o == nil)
			return(nil);

		// We don't do anything fancy here, yet.
		switch(flags) {
			case dTitle:
				return(o.getWordAsTitle());
			default:
				return(o.getWord());
		}
	}
;

// Class to hold all the stuff for a single dynamic word.
class DynamicWord: object
	id = nil		// key to use for gRevealed()
	word = nil		// "revealed" basic form of the word
	wordAsTitle = nil	// "revealed" word formatted as a title
	initWord = nil		// "unrevealed" basic form of the word
	initWordAsTitle = nil	// "unrevealed" word formatted as a title

	// If skipSmallWords is true, titleCase() will ignore the words
	// defined in smallWords.  Only applies if no explicit
	// wordAsTitle or initWordAsTitle are defined.
	skipSmallWords = nil
	smallWords = static [ 'a', 'an', 'of', 'the', 'to' ]

	construct(n, w0, w1, l0?, l1?) {
		id = n;
		initWord = (w0 ? w0 : nil);
		word = (w1 ? w1 : nil);
		initWordAsTitle = (l0 ? l0 : nil);
		wordAsTitle = (l1 ? l1 : nil);
	}

	// Return the basic form of the word.  Every instance has to have
	// something defined for word and initWord.
	getWord() { return(gRevealed(id) ? word : initWord); }

	// Rewrite the passed string as a title:  capitalizes the first
	// letter of each word, optionally skipping a defined set of "small
	// words" (the, of, and so on) that occur in the middle of the string.
	// This is a *very* slight variation of sample code in the tads-gen
	// documentation (from which we get rexReplace()).
	titleCase(txt) {
		return(rexReplace('%<(<alphanum>+)%>', txt, function(s, idx) {
			// Skip capitalization if:  a)  the skipSmallWords
			// flag is set, b)  we're not at the very start of
			// the string, and c)  we're in the list of skippable
			// words.
			if((skipSmallWords == true) && (idx > 1) &&
				smallWords.indexOf(s.toLower()) != nil)
				return(s);

			// Capitalize the first letter.
			return(s.substr(1, 1).toTitleCase() + s.substr(2));
		}, ReplaceAll));
	}

	// Return the word formatted for use as a title, e.g. in a room name.
	getWordAsTitle() {
		// If we haven't explicitly defined the "title" form(s)
		// of the word, try capitalizing the basic forms.
		if(wordAsTitle == nil)
			wordAsTitle = titleCase(word);
		if(initWordAsTitle == nil)
			initWordAsTitle = titleCase(initWord);

		return(gRevealed(id) ? wordAsTitle : initWordAsTitle);
	}
;
