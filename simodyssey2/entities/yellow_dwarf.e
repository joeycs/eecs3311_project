note
	description: "Summary description for {YELLOW_DWARF}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	YELLOW_DWARF

inherit
	STAR
		redefine
			ID,
			out
		end

create
	make

feature -- attributes

	ID : INTEGER

feature {NONE} -- Initialization

	make (s : SECTOR; next_stationary_id : INTEGER)
			-- Initialization for `Current'.
		do
			sector := s
			ID := next_stationary_id
			create char.make ('Y')
		end
feature -- queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "Luminosity:" + luminosity.out)
		end

end
