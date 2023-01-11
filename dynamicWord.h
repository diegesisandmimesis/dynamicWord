//
// dynamicWord.h
//

#include "eventHandler.h"
#ifndef EVENT_HANDLER_VERSION
#error "This module requires the eventHandler module."
#error "https://github.com/diegesisandmimesis/eventHandler"
#endif // EVENT_HANDLER_VERSION

// Uncomment to enable debugging options.
//#define __DEBUG_DYNAMIC_WORD

// Template for the DynamicWord class.
DynamicWord template 'id' 'initWord'? 'word'?;
StateWord template 'id' 'word'? [stateTable]?;

// Convenience macro for defining a DynamicWord instance.
// Creates global functions to make referring to instance simpler:
// if the ID is "foo", fooWord() will return the basic form of the word
// and fooWordAsTitle() will return the word formatted as a title (to be
// used in for example a room name).
#define DefineDynamicWord(id, name, init, reveal...) \
	id##Word() { return(id##DynamicWord.getWord()); } \
	id##WordAsTitle() { return(id##DynamicWord.getWordAsTitle()); } \
	id##DynamicWord: DynamicWord name init reveal

#define DefineStateWord(id, name, word, stateTable...) \
	id##Word() { return(id##DynamicWord.getWord()); } \
	id##WordAsTitle() { return(id##DynamicWord.getWordAsTitle()); } \
	id##DynamicWord: StateWord name word stateTable

// Convenience macros for accessing the dynamic words by their keys.
#define dWord(key, args...) dynamicWords.getWord(key, args)
#define dWordAsTitle(key, args...) dynamicWords.getWord(key, title)
