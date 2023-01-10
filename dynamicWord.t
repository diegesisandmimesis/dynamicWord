#charset "us-ascii"
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

class DynamicWord: object
	id = nil
	initialWord = nil
	revealedWord = nil
	initialLongWord = nil
	revealedLongWord = nil

	construct(n, w0?, w1?, l0?, l1?) {
		id = n;
		initialWord = (w0 ? w0 : nil);
		revealedWord = (w1 ? w1 : nil);
		initialLongWord = (l0 ? l0 : nil);
		revealedLongWord = (l1 ? l1 : nil);
	}
	getWord() { return(gRevealed(id) ? revealedWord : initialWord); }
	getLongWord() {
		return(gRevealed(id) ? revealedLongWord : initialLongWord);
	}
;
