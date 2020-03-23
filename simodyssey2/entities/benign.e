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
			ID,
			out
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
			fuel := max_fuel
			actions_left_until_reproduction := reproduction_interval
		end

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		do
			across sector.sorted_contents is l_entity loop
				if attached {MALEVOLENT} l_entity as l_malev then
					l_malev.set_dead
				end
			end
			turns_left := gen.rchoose (0, 2)
		end

	set_death_message (msg: STRING)
		do
			death_message.make_from_string ("Benign" + msg)
		end

feature -- Queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "fuel:" + fuel.out + "/" + max_fuel.out + ", "
			               + "actions_left_until_reproduction:" + actions_left_until_reproduction.out + "/" + reproduction_interval.out
			               + ", " + "turns_left:" + turns_left.out)
		end
end
