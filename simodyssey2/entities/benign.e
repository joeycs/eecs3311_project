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
			out,
			set_death_message
		end

	CPU_ENTITY
		undefine
			set_sector,
			out
		end

	REPRODUCING_ENTITY
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
			create char.make ('B')
			sector := s
			ID := next_movable_id
			dead := false
			fuel := max_fuel
			actions_left_until_reproduction := reproduction_interval
			create destroys_this_turn.make
		end

feature -- Commands

	set_behaviour (first_behave: BOOLEAN; rng_usage: LINKED_LIST [STRING])
		do
			if not first_behave then
				across sector.sorted_contents is l_entity loop
					if attached {MALEVOLENT} l_entity as l_malev then
						l_malev.set_dead
						l_malev.set_death_message (  " got destroyed by benign (id: " + ID.out
										              + ") at Sector:" + sector.row.out + ":" + sector.column.out)
						destroys_this_turn.extend (l_malev)
						destroyed_this_turn := True
					end
				end
			end

			turns_left := gen.rchoose (0, 2)
			rng_usage.extend ("(B->" + turns_left.out + ":[0,2]),")
		end

	set_death_message (msg: STRING)
		do
			Precursor ("Benign" + msg)
		end

feature -- Queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "fuel:" + fuel.out + "/" + max_fuel.out + ", "
			               + "actions_left_until_reproduction:" + actions_left_until_reproduction.out + "/" + reproduction_interval.out
			               + ", " + "turns_left:")
			if is_dead then
				Result.append ("N/A")
			else
				Result.append (turns_left.out)
			end
		end
end
