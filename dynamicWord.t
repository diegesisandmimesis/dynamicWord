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
// We're a Thing instead of an object just to take advantage of the
// built-in naming widgetry (aName, theName, and so on) that gets us.
class DynamicWord: Thing
	id = nil		// key to use for gRevealed()
	word = nil		// "revealed" basic form of the word
	wordAsTitle = nil	// "revealed" word formatted as a title
	initWord = nil		// "unrevealed" basic form of the word
	initWordAsTitle = nil	// "unrevealed" word formatted as a title

	lastWord = nil		// value as of the last check

	// We use a special class to handle message param substitution for
	// our word capitalized as a title.  The default will work if
	// all of the title versions of the word are "regular"--they're
	// derived straight from the object's name property.
	// For special cases (where aName, theName, and so on need to be
	// set individually) you'll have to create a special class to
	// handle it for the individual DynamicWord.
	dynamicWordTitleClass = DynamicWordTitle

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

	// Make the name of our fake(-ish) Thing the same as whatever our
	// current return value from getWord() is.
	name() { return(getWord()); }

	initializeThing() {
		inherited();
		setGlobalParamName(id);
		createTitleObj();
	}

	// Create the pseudo-Thing that will handle message param
	// substitution for our stuff in title case.
	createTitleObj() {
		local obj;

		// Create the instance.
		obj = dynamicWordTitleClass.createInstance();

		// Initialize it to refer to us.
		obj.initializeFromWord(self);
	}

	// Returns true if the defined ID has been revealed, nil otherwise.
	check() { return(gRevealed(id)); }

	// Returns boolean true if the passed value is the last value
	// the word evaluated to, nil otherwise.
	// Defaults to current value of getWord() if argument is nil.
	changed(v?) {
		if(v == nil)
			v = getWord();
		return(v != lastWord);
	}

	// Notify subscribers of word changes.
	notifyChanged() {}

	// Set the value of lastWord, notifying subscribers if the value
	// has changed.
	// Returns the new value.
	setLastWord(v) {
		if(changed(v)) {
			lastWord = v;
			notifyChanged();
		}
		return(v);
	}

	// Return the basic form of the word.  Every instance has to have
	// something defined for word and initWord.
	getWord() { return(setLastWord(check() ? word : initWord)); }

	// Rewrite the passed string as a title:  capitalizes the first
	// letter of each word, optionally skipping a defined set of "small
	// words" (the, of, and so on) that occur in the middle of the string.
	// This is a *very* slight variation of sample code in the tads-gen
	// documentation (from which we get rexReplace()).
	titleCase(txt) {
		if(!txt) return('');
		return(rexReplace('%<(<alphanum|squote>+)%>', txt,
			function(s, idx) {
				// Skip capitalization if:  a)  the
				// skipSmallWords flag is set, b)  we're not
				// at the very start of the string, and
				// c)  we're in the list of skippable
				// words.
				if((skipSmallWords == true) && (idx > 1) &&
					smallWords.indexOf(s.toLower()) != nil)
					return(s);

				// Capitalize the first letter.
				return(s.substr(1, 1).toTitleCase()
					+ s.substr(2));
			}, ReplaceAll)
		);
	}

	// Return the word formatted for use as a title, e.g. in a room name.
	getWordAsTitle() {
		// If we haven't explicitly defined the "title" form(s)
		// of the word, try capitalizing the basic forms.
		if(wordAsTitle == nil)
			wordAsTitle = titleCase(word);
		if(initWordAsTitle == nil)
			initWordAsTitle = titleCase(initWord);

		return(check() ? wordAsTitle : initWordAsTitle);
	}
;

// Kludge.
// This only words if all the name properties (aName, theName...) are derived
// normally from the name property itself.
// If any funky stuff is going on in the name-related properties, you're
// going to have to define dynamicWordTitleClass on the parent DynamicWord
// and the enumerate everything in its own one-off class.
// What we're doing:
//	In the parent DynamicWord, if its ID is, for example, 'cave',
//	then the message parameter substitution '{cave}' will automagically
//	be created.  It will always use the "normal" version of the current
//	word.  So "a dark cave" or whatever.
//	A DynamicWordTitle is created for each DynamicWord, and it will
//	define the message parameter substitution for the title case form
//	of the word.  So '{caveTitle}', which would return "A Dark Cave".
class DynamicWordTitle: Thing
	parentWord = nil
	name() { return(parentWord.getWordAsTitle()); }
	isProperName() { return(parentWord.isProperName); }
	initializeFromWord(obj) {
		if((obj == nil) || !obj.ofKind(DynamicWord))
			return(nil);
		parentWord = obj;
		setGlobalParamName(obj.id + 'title');
		return(true);
	}
;
