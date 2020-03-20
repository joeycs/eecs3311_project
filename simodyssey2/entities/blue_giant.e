note
	description: "Summary description for {BLUE_GIANT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLUE_GIANT

inherit
	STAR
		redefine
			ID,
			luminosity,
			out
		end

create
	make

feature -- attributes

	ID: INTEGER

	luminosity: INTEGER
		once
			Result := 5
		end

feature {NONE} -- Initialization

	make (s: SECTOR; next_stationary_id : INTEGER)
			-- Initialization for `Current'.
		do
			sector := s
			ID := next_stationary_id
			create char.make ('*')
		end

feature -- queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "Luminosity:" + luminosity.out)
		end


end
