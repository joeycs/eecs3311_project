note
	description: "Summary description for {MALEVOLENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MALEVOLENT

inherit
	SENTIENT_ENTITY

	CLONEABLE [MALEVOLENT]
		rename
			make as make_clone,
			item as m_clone
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
			create char.make ('M')
			m_clone := Current
			make_clone (Current)
		end

feature

	set_death_message (msg: STRING)
		do

		end

end
