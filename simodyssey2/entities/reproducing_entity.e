note
	description: "Summary description for {REPRODUCING_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REPRODUCING_ENTITY
	-- handles reproduction

inherit
	ENTITY

feature -- Attributes

	actions_left_until_reproduction: INTEGER

	reproduction_interval: INTEGER
		do
			Result := 1
		end

	reproduced_this_turn: BOOLEAN
	newest_clone: detachable ENTITY

feature -- Commands

	set_clone (s: SECTOR; next_movable_id: INTEGER)
		do
			sector := s
			ID := next_movable_id
			actions_left_until_reproduction := reproduction_interval
			reproduced_this_turn := False
			newest_clone := void

			check attached {SENTIENT_ENTITY} Current as se then
				se.add_fuel (se.max_fuel)
				se.reset_fuel_calculated
				se.reset_used_wormhole
				se.reset_failed_to_move
			end

			check attached {CPU_ENTITY} Current as cpu then
				cpu.reset_destroyed_this_turn
			end

			if attached {MALEVOLENT} Current as mal then
				mal.reset_attacked_this_turn
			end
		end

	reset_reproduced_this_turn
		do
			reproduced_this_turn := False
		end

feature -- Queries

	get_new_clone: detachable like Current
		do
			if not sector.is_full and actions_left_until_reproduction = 0 then
				Result := Current.twin
				newest_clone := Result
				actions_left_until_reproduction := reproduction_interval
				reproduced_this_turn := True
			else
				if actions_left_until_reproduction /= 0 then
					actions_left_until_reproduction :=
					actions_left_until_reproduction - 1
				end
			end
		end

end
