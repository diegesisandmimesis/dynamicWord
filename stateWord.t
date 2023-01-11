#charset "us-ascii"
//
// stateWord.t
//
#include <adv3.h>
#include <en_us.h>

#include "dynamicWord.h"

// StateWord is like DynamicWord, but uses a LookupTable to decide
// which word to use.
class StateWord: DynamicWord
	// In our case the ID is never directly used for a gRevealed()
	// check, it's just a unique identifier for this instance.
	id = nil

	// This needs to be a LookupTable in which the keys are strings
	// to use as the value for the word, and the values are the
	// conditions to check.  For example:
	//	stateTable = [
	//		'foo' -> 'fooFlag',
	//		'bar' -> 'barFlag',
	//		'foo and bar' -> [ 'fooFlag', 'barFlag' ]
	//	]
	// ...will use 'foo' if gRevealed('fooFlag') is true, 'bar'
	// if gRevealed('barFlag') is true, and 'foo and bar' if
	// both are true.
	// NOTE:  The conditions are evaluated in order, and the LAST
	//	MATCHING CONDITION is used.
	// If no condition(s) match, the value for the StateWord.word
	// is used instead.
	stateTable = nil

	// Return the state table.  A convenience method to make sure
	// we never get a non-LookupTable elsewhere.
	getStateTable() {
		if((stateTable == nil) || !stateTable.ofKind(LookupTable))
			stateTable = new LookupTable();
		return(stateTable);
	}

	// Check a specific condition fro the state table.
	check(v) {
		local i;

		// If our condition isn't a list, make it a list.
		if(dataType(v) != TypeList)
			v = [ v ];

		// Go through our list and test each condition in it.
		for(i = 1; i <= v.length(); i++) {
			if(!checkBit(v[i]))
				return(nil);
		}

		return(true);
	}
	// Check a single condition.
	checkBit(v) {
		switch(dataTypeXlat(v)) {
			// If the condition is boolean true, we always
			// succeed.
			case TypeTrue:
				return(true);
			// If the condition is a string, we use it as a key
			// for gRevealed().
			case TypeSString:
				return(gRevealed(v) == true);
			// If the condition is a property, we evaluate it
			// on ourselves and return true iff it returns true.
			case TypeProp:
				return(self.(v)() == true);
			// If the condition is a function, we call it and
			// return true iff it returns true.
			case TypeFuncPtr:
				return((v)() == true);
		}
		return(nil);
	}
	getWord() {
		local r;

		r = word;
		getStateTable().forEachAssoc(function(k, v) {
			if(check(v)) r = k;
		});

		if(r == nil)
			return(word);

		return(r);
	}
	getWordAsTitle() { return(titleCase(getWord())); }
;

/*
// Class to hold all the stuff for a single dynamic word.
class StateWord: DynamicWord
	id = nil
	wordList = nil
	keyList = nil

	getKeyList() {
		local v;

		if(keyList == nil)
			keyList = new Vector();
		if(dataType(keyList) != TypeList) {
			v = keyList;
			keyList = new Vector();
			keyList += v;
		}
		return(keyList);
	}
	getWordList() {
		local v;

		if(wordList == nil)
			wordList = new Vector();
		if(dataType(wordList) != TypeList) {
			v = wordList;
			wordList = new Vector();
			wordList += v;
		}
		return(wordList);
	}
	check() {
		local fail, idx;

		// Flag that gets set the first time we fail any check.
		fail = nil;

		// Index of the last check we passed before failing.
		idx = 1;
		getKeyList().forEach(function(o) {
			if(fail) return;

			switch(dataType(o)) {
				case TypeSString:
					if(!gRevealed(o)) fail = true;
					break;
				case TypeFuncPtr:
					if(!(o)()) fail = true;
					break;
			}

			if(fail != true) idx += 1;
		});

		return(idx);
	}
	getWord() {
		local idx, l;

		l = getWordList();
		idx = check();
		if(idx < 1) idx = 1;
		if(idx > l.length()) idx = l.length();

		return(l[idx]);
	}
	getWordAsTitle() { return(titleCase(getWord())); }
	_debug() {
		"StateWord <<id>> (<<toString(check())>>)\n ";
		"\tKeys:\n ";
		getKeyList().forEach(function(o) {
			"\t\t<<o>>\n ";
		});
		"\tWords:\n ";
		getWordList().forEach(function(o) {
			"\t\t<<o>>\n ";
		});
	}
;
*/
