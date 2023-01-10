//
// dynamicWord.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_DYNAMIC_WORD

DynamicWord template 'id' 'initialWord'? 'revealedWord'?;

#define DefineDynamicWord(id, name, init, reveal...) \
	id##Word() { return(id##DynamicWord.getWord()); } \
	id##LongWord() { return(id##DynamicWord.getLongWord()); } \
	id##DynamicWord: DynamicWord name init reveal
