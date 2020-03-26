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
	newest_destroy: detachable ENTITY
	destroyed_this_turn: BOOLEAN

feature -- Commands

	set_behaviour (first_behave: BOOLEAN; rng_usage: LINKED_LIST [STRING])
		deferred
		end

	decrement_turns_left
		do
			turns_left := turns_left - 1
		end

	reset_destroyed_this_turn
		do
			destroyed_this_turn := False
		end

end
