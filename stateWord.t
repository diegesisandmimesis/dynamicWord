#charset "us-ascii"
//
// stateWord.t
//
//	Extension to DynamicWord that uses a LookupTable to pick the
//	output string.
//
//	Usage:
//
//	// Creating the StateWord
//	// This will create a function barWord() that will return
//	// 'bar plus one' if gRevealed('oneFlag') is true, 'bar plus two'
//	// if gRevealed('twoFlag') is true, 'bar plus three' if both are
//	// true, and 'unknown bar' if none of the conditions test true.
//	// Note that the first case uses a method which happens to check
//	// a gRevealed() value, but the method could do anything.
//	DefineStateWord('bar', 'barID', 'unknown bar', [
//		'bar plus one' -> &checkOne,
//		'bar plus two' -> 'twoFlag',
//		'bar plus three' -> [ &checkOne, 'twoFlag' ]
//	])
//	checkOne() { return(gRevealed('oneFlag')); }
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
	// Get our current word.
	// Note that we return the LAST MATCH.  We start out with the
	// default value, and then walk through each of our tests, replacing
	// the return value every time a test succeeds.
	getWord() {
		local r;

		// Start out with the default "unrevealed" value.
		r = word;

		// Now walk through the state table, checking each value
		// and replacing our return value if the test succeeds.
		getStateTable().forEachAssoc(function(k, v) {
			if(check(v)) r = k;
		});

		// If we've somehow or other lost our value (if one of the
		// keys was nil, which shouldn't happen but we check anyway),
		// reset the return value to the default string again.
		if(r == nil)
			return(word);

		// Return the return value.
		return(r);
	}

	// With StateWord, the "title" version of each word is just the basic
	// version with the first letter of each word capitalized.
	getWordAsTitle() { return(titleCase(getWord())); }
;
