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
			max_fuel,
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
		redefine
			reproduction_interval
		end

create
	make

feature -- Attributes

	load: INTEGER

	max_fuel: INTEGER
		once
			Result := 5
		end

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
			sector := s
			load := 0
			dead := false
			fuel := max_fuel
			actions_left_until_reproduction := reproduction_interval
			create destroys_this_turn.make
		end

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		local
			l_wormhole: detachable WORMHOLE
		do
			if not first_behave then
				across sector.sorted_contents is l_entity loop
					if attached {ASTEROID} l_entity as l_asteroid
					   and load < max_load then
						l_asteroid.set_dead
						l_asteroid.set_death_message (  " got imploded by janitaur (id: " + ID.out
										              + ") at Sector:" + sector.row.out + ":" + sector.column.out)
						load := load + 1
						destroys_this_turn.extend (l_asteroid)
						destroyed_this_turn := True
					end

					if attached {WORMHOLE} l_entity as wh then
						l_wormhole := wh
					end
				end

				if attached l_wormhole then
					load := 0
				end
			else
				load := 0
			end

			turns_left := gen.rchoose (0, 2)
		end

	set_death_message (msg: STRING)
		do
			Precursor ("Janitaur" + msg)
		end

feature -- Queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
				           + "fuel:" + fuel.out + "/" + max_fuel.out + ", "
				           + "load:" + load.out + "/" + max_load.out + ", "
				           + "actions_left_until_reproduction:" + actions_left_until_reproduction.out + "/" + reproduction_interval.out
				           + ", " + "turns_left:")
			if is_dead then
				Result.append ("N/A")
			else
				Result.append (turns_left.out)
			end
		end

end
