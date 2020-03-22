note
	description: "Summary description for {BENIGN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BENIGN

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
			create char.make ('B')
			sector := s
			ID := next_movable_id
			dead := false
			actions_left_until_reproduction := reproduction_interval
		end

feature -- Queries

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		do
		end

	set_death_message (msg: STRING)
		do

		end
end
