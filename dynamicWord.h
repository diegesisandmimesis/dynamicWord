//
// dynamicWord.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_DYNAMIC_WORD

DynamicWord template 'id' 'initWord'? 'word'?;

#define DefineDynamicWord(id, name, init, reveal...) \
	id##Word() { return(id##DynamicWord.getWord()); } \
	id##WordAsTitle() { return(id##DynamicWord.getWordAsTitle()); } \
	id##DynamicWord: DynamicWord name init reveal

#define dWord(key, args...) dynamicWords.getWord(key, args)
#define dWordAsTitle(key, args...) dynamicWords.getWord(key, title)
