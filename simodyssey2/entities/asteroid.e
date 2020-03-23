note
	description: "Summary description for {ASTEROID}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ASTEROID

inherit
	MOVABLE_ENTITY
		redefine
			ID,
			out
		end

	CPU_ENTITY
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
			create char.make ('A')
			sector := s
			ID := next_movable_id
			dead := false
		end

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		do
			across sector.sorted_contents is l_entity loop
				if attached {SENTIENT_ENTITY} l_entity as l_sentient then
					l_sentient.set_dead
				end
			end
			turns_left := gen.rchoose (0, 2)
		end

	set_death_message (msg: STRING)
		do
			death_message.make_from_string ("Asteroid" + msg)
		end

feature -- Queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "turns_left:" + turns_left.out)
		end

end
