note
	description: "Summary description for {MOVABLE_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	MOVABLE_ENTITY

inherit
	ENTITY
		redefine
			set_sector
		end

feature -- attributes

	gen: RANDOM_GENERATOR_ACCESS
	prev_sector_row: INTEGER
	prev_sector_col: INTEGER
	prev_sector_pos: INTEGER
	failed_to_move: BOOLEAN
	dead: BOOLEAN
	death_message: STRING

feature -- commands

	set_sector (s: SECTOR)
		do
			prev_sector_row := sector.row
			prev_sector_col := sector.column
			prev_sector_pos := pos
			sector := s
		end

	set_failed_to_move
		do
			failed_to_move := true
		end

	reset_failed_to_move
		do
			failed_to_move := false
		end

	set_dead
		do
			dead := true
		end

	set_death_message (msg: STRING)
		deferred
		end

feature -- queries

	is_dead: BOOLEAN
		do
			Result := dead
		end

end
