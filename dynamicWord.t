#charset "us-ascii"
//
// dynamicWord.t
//
//	This module provides a simple way to do string substitutions based
//	on whether or not something has been revealed.
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

enum dTitle;

dynamicWords: PreinitObject
	_table = nil

	execute() {
		_table = new LookupTable();
		forEachInstance(DynamicWord, function(o) {
			_table[o.id] = o;
		});
	}

	getWord(id, flags?) {
		local o;

		o = _table[id];
		if(o == nil)
			return(nil);

		switch(flags) {
			case dTitle:
				return(o.getWordAsTitle());
			default:
				return(o.getWord());
		}
	}
;

class DynamicWord: object
	id = nil
	word = nil
	initWord = nil
	wordAsTitle = nil
	initWordAsTitle = nil

	construct(n, w0?, w1?, l0?, l1?) {
		id = n;
		initWord = (w0 ? w0 : nil);
		word = (w1 ? w1 : nil);
		initWordAsTitle = (l0 ? l0 : nil);
		wordAsTitle = (l1 ? l1 : nil);
	}
	getWord() { return(gRevealed(id) ? word : initWord); }
	getWordAsTitle() {
		return(gRevealed(id) ? wordAsTitle : initWordAsTitle);
	}
;
