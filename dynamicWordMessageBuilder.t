#charset "us-ascii"
//
// dynamicWordMessageBuilder.t
//
//	Create a "name" message parameter substitution.
//
#include <adv3.h>
#include <en_us.h>

modify MessageBuilder
	execBeforeMe = [ dynamicWordPreinit ]
;

dynamicWordPreinit: PreinitObject
	// Add an entry to the message param list with minimal
	// safety checks.
	addMessageBuilderParam(arr) {
		// Sanity check the argument.
		if((arr == nil) || !arr.ofKind(List))
			return(nil);

		// Make sure we haven't already been added.
		if(langMessageBuilder.paramList_.indexOf(arr) != nil)
			return(nil);

		// Actually add ourselves.
		langMessageBuilder.paramList_
			= langMessageBuilder.paramList_.append(arr);

		return(true);
	}
	execute() {
		addMessageBuilderParam([ 'name/he', &name, nil, nil, nil ]);
		addMessageBuilderParam([ 'name/she', &name, nil, nil, nil ]);
		addMessageBuilderParam([ 'name/him', &name, nil, nil, nil ]);
		addMessageBuilderParam([ 'name/her', &name, nil, nil, nil ]);
	}
;
