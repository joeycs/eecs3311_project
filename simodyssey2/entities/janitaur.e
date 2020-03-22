note
	description: "Summary description for {JANITAUR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JANITAUR

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
		redefine
			reproduction_interval
		end

create
	make

feature -- Attributes

	ID: INTEGER
	load: INTEGER

	max_load: INTEGER
		once
			Result := 2
		end

	reproduction_interval: INTEGER
		once
			Result := 2
		end

feature {NONE} -- Initialization

	make (s: SECTOR; next_movable_id: INTEGER)
			-- Initialization for `Current'.
		do
			create death_message.make_empty
			create sector.make_dummy
			create char.make ('J')
			ID := next_movable_id
			load := 0
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
