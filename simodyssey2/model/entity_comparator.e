note
	description: ""
	author: "JSO and JW"
	date: "$Date$"
	revision: "$Revision$"

class
	ENTITY_COMPARATOR[G -> COMPARABLE]

inherit
	KL_COMPARATOR[ENTITY]

create
	default_create

feature
	attached_less_than (e1, e2: attached ENTITY): BOOLEAN
			-- effect e1 < e2
		do
			Result := e1 < e2
		end
end
