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
			out,
			set_death_message
		end

	CPU_ENTITY
		undefine
			set_sector,
			out
		end

create
	make

feature {NONE} -- Initialization

	make (s: SECTOR; next_movable_id: INTEGER)
			-- Initialization for `Current'.
		do
			create death_message.make_empty
			create char.make ('A')
			sector := s
			ID := next_movable_id
			dead := false
			create destroys_this_turn.make
		end

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		do
			if not first_behave then
				across sector.sorted_contents is l_entity loop
					if attached {SENTIENT_ENTITY} l_entity as l_sentient then
						l_sentient.set_dead
						l_sentient.set_death_message (  " got destroyed by asteroid (id: " + ID.out
										              + ") at Sector:" + sector.row.out + ":" + sector.column.out)
						destroys_this_turn.extend (l_sentient)
						destroyed_this_turn := True
					end
				end
			end

			turns_left := gen.rchoose (0, 2)
		end

	set_death_message (msg: STRING)
		do
			Precursor ("Asteroid" + msg)
		end

feature -- Queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "turns_left:")
			if is_dead then
				Result.append ("N/A")
			else
				Result.append (turns_left.out)
			end
		end

end
