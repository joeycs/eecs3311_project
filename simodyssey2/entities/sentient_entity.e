note
	description: "Summary description for {SENTIENT_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SENTIENT_ENTITY
	-- Handles fuel

inherit
	MOVABLE_ENTITY

feature -- Attributes

	fuel: INTEGER

	max_fuel: INTEGER
		do
			Result := 3
		end

	used_wormhole: BOOLEAN

feature -- Commands

	add_fuel (dfuel: INTEGER)
		do
			fuel := max_fuel.min (fuel + dfuel)
		end

	set_used_wormhole
		do
			used_wormhole := True
		end

	reset_used_wormhole
		do
			used_wormhole := False
		end

end
