note
	description: "Summary description for {BENIGN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BENIGN

inherit
	SENTIENT_ENTITY

	CLONEABLE [BENIGN]
		rename
			make as make_cloneable,
			item as cloneable
		undefine
			is_equal
		end
create
	make

feature {NONE} -- Attributes



feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			create death_message.make_empty
			create sector.make_dummy
			create char.make ('B')
			cloneable := Current
			make_cloneable (Current)
		end

feature -- Queries

feature -- Commands

	set_death_message (msg: STRING)
		do

		end
end
