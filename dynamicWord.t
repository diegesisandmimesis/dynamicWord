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

	construct(n, w0?, w1?, fn?) {
		id = n;
		initialWord = (w0 ? w0 : nil);
		revealedWord = (w1 ? w1 : nil);
	}

	getWord() { return(gRevealed(id) ? revealedWord : initialWord); }
;

DynamicWord template 'id' 'initialWord'? 'revealedWord'?;
