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

	reproduce_next_turn: BOOLEAN

feature -- Commands

feature -- Queries

	get_new_clone: detachable REPRODUCING_ENTITY
		do
			if (not sector.is_full and actions_left_until_reproduction = 0)
			    or reproduce_next_turn then
				Result := Current.deep_twin
				actions_left_until_reproduction := reproduction_interval
				reproduce_next_turn := False
			else
				if actions_left_until_reproduction /= 0 then
					actions_left_until_reproduction :=
					actions_left_until_reproduction - 1
				elseif sector.is_full then
					reproduce_next_turn := True
				end
			end
		end

end
