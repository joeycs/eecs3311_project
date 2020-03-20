note
	description: "Summary description for {BLACKHOLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLACKHOLE

inherit
	STATIONARY_ENTITY
		redefine
			ID,
			out
		end

create
	make

feature -- attriutes
	ID: INTEGER
		once
			Result := -1
		end

feature {NONE} -- Initialization

	make (s: SECTOR)
			-- Initialization for `Current'.
		do
			create char.make ('O')
			sector := s
		end

feature -- queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->")

		end
end
