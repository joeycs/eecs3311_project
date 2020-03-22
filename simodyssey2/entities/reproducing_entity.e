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

feature -- Queries

	get_new_clone: REPRODUCING_ENTITY
		do
			-- reproduce algorithm
			Result := Current.twin
			-- in game.advance_turn
			-- put Current.twin.make (sector, next_movable_id) in galaxy
		end

end
