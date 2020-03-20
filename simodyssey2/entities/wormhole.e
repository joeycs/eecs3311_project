note
	description: "Summary description for {WORMHOLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WORMHOLE

inherit
	STATIONARY_ENTITY
		redefine
			ID,
			out
		end

create
	make

feature -- attributes

	ID: INTEGER

feature {NONE} -- Initialization

	make (s : SECTOR; next_stationary_id : INTEGER)
			-- Initialization for `Current'.
		do
			sector := s
			ID := next_stationary_id
			create char.make ('W')
		end

feature -- queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->")
		end

end
