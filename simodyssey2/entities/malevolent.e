note
	description: "Summary description for {MALEVOLENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MALEVOLENT

inherit
	SENTIENT_ENTITY
		redefine
			ID
		end

	CPU_ENTITY
		undefine
			ID,
			set_sector,
			out
		end

	REPRODUCING_ENTITY
		undefine
			ID,
			set_sector,
			out
		end

create
	make

feature -- Attributes

	ID: INTEGER

feature {NONE} -- Initialization

	make (s: SECTOR; next_movable_id: INTEGER)
			-- Initialization for `Current'.
		do
			create death_message.make_empty
			create sector.make_dummy
			create char.make ('M')
			ID := next_movable_ID
			dead := false
			actions_left_until_reproduction := reproduction_interval
		end

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		do
		end

	set_death_message (msg: STRING)
		do

		end

end
