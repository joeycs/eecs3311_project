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

	make (g: G)
			-- Initialization for `Current'.
		do
			item := g
		end

feature -- Queries

	get_new_clone:  G
		do
			separate item as separate_item do
				check attached separate_item as cloneable then
					Result := cloneable.deep_twin
				end
			end
		end

end
