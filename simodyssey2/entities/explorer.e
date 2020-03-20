note
	description: "Summary description for {EXPLORER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EXPLORER

inherit
	SENTIENT_ENTITY
		redefine
			ID,
			set_dead,
			death_message,
			out
		end

create
	make

feature -- attributes

	fuel: INTEGER
	life: INTEGER
	landed: BOOLEAN
	death_message: STRING

	ID: INTEGER
		once
			Result := 0
		end

	max_fuel: INTEGER
		once
			Result := 3
		end

feature {NONE} -- Initialization

	make (s: SECTOR)
			-- Initialization for `Current'.
		do
			sector := s
			fuel := 3
			life := 3
			landed := False
			dead := False
			create char.make ('E')
			create death_message.make_empty
		end

feature -- commands
	land
		require
			not_landed:
				not landed
		do
			landed := True
		end

	liftoff
		require
			landed
		do
			landed := False
		end

	add_fuel (dfuel: INTEGER)
		do
			fuel := max_fuel.min (fuel + dfuel)
		end

	set_dead
		do
			dead := true
			life := 0
		end

	set_death_message (msg: STRING)
		do
			death_message.make_from_string ("Explorer" + msg)
		end

feature -- queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "fuel:" + fuel.out + "/" + max_fuel.out + ", "
			               + "life:" + life.out + "/" + max_fuel.out + ", "
			               + "landed?:" + landed.out.substring (1, 1))
		end

end
