note
	description: "Summary description for {ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENTITY

inherit
	COMPARABLE
		redefine
			is_equal
		end

feature -- attributes

	char: ENTITY_ALPHABET
	sector: SECTOR
	pos: INTEGER
	ID: INTEGER
		do
			Result := -1
		end

feature -- commands

	set_sector (s: SECTOR)
		do
			sector := s
		end

	set_pos (p: INTEGER)
		do
			pos := p
		end

feature -- queries

	is_equal (other : like Current): BOOLEAN
		do
			Result := Current.ID = other.ID
		end

	is_less alias "<" (other : like Current): BOOLEAN
		do
			Result := Current.ID < other.ID
		end

-- invariant
--	 exists_in_sector:
--		 sector /= void

end
