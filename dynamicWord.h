//
// dynamicWord.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_DYNAMIC_WORD


#define DefineDynamicWord(fn, cls, name, init, reveal...) \
	cls##DynamicWord: DynamicWord name init reveal; \
	fn##() { return(cls##DynamicWord.getWord()); }
