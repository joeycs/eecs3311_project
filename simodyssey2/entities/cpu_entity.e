note
	description: "Summary description for {CPU_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CPU_ENTITY
	-- handles behaviour

inherit
	ENTITY

feature -- Attributes

	turns_left: INTEGER

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		deferred
		end

	decrement_turns_left
		do
			turns_left := turns_left - 1
		end

end
