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
	destroys_this_turn: LINKED_LIST [ENTITY]
	destroyed_this_turn: BOOLEAN

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		deferred
		end

	decrement_turns_left
		do
			turns_left := turns_left - 1
		end

	reset_destroyed_this_turn
		do
			destroyed_this_turn := False
			create destroys_this_turn.make
		end

end
