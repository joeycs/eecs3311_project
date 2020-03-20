note
	description: "Summary description for {JANITAUR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JANITAUR

inherit
	SENTIENT_ENTITY

	CLONEABLE [JANITAUR]
		rename
			make as make_clone,
			item as j_clone
		undefine
			is_equal
		end
create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			create death_message.make_empty
			create sector.make_dummy
			create char.make ('J')
			j_clone := Current
			make_clone (Current)
		end

feature

	set_death_message (msg: STRING)
		do

		end
end
