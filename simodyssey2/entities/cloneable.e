note
	description: "Summary description for {CLONEABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CLONEABLE [G]

create
	make

feature {NONE} -- Implementation

	item : G

feature {NONE} -- Initialization

	make (g: attached G)
			-- Initialization for `Current'.
		do
			item := g.deep_twin
		end

feature -- Queries

	get_clone: G
		do
			Result := item
		end

end
