note
	description: "Summary description for {STAR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	STAR

inherit
	STATIONARY_ENTITY

feature -- attributes

	luminosity: INTEGER
		once
			Result := 2
		end

end
