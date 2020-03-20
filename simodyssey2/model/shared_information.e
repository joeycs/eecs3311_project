note
	description: "[
		Common variables such as threshold for planet
		and constants such as number of stationary items for generation of the board.
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_INFORMATION

create {SHARED_INFORMATION_ACCESS}
	make

feature{NONE}
	make
		do
			create entities.make
			entities.compare_objects
		end

feature

	number_rows: INTEGER = 5
        	-- The number of rows in the grid

	number_columns: INTEGER = 5
        	-- The number of columns in the  grid

	number_of_stationary_items: INTEGER = 10
			-- The number of stationary_items in the grid

	number_of_movable_items: INTEGER

	entities: LINKED_LIST [ENTITY]

    planet_threshold: INTEGER
		-- used to determine the chance of a planet being put in a location
		attribute
			Result := 50
		end

	max_capacity: INTEGER = 4
		 -- max number of objects that can be stored in a location

feature
	set_planet_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			planet_threshold:=threshold
		end

	increment_number_of_movable_items
		do
			number_of_movable_items:=number_of_movable_items + 1
		end

	reset
		do
			entities.wipe_out
			number_of_movable_items := 0
		end

feature -- queries
	sorted_entities: ARRAY [ENTITY]
		local
			a_comparator: ENTITY_COMPARATOR [ENTITY]
			a_sorter: DS_ARRAY_QUICK_SORTER [ENTITY]
		do
			create a_comparator
			create a_sorter.make (a_comparator)
			create Result.make_empty
			across
				entities is e
			loop
				Result.force (e, Result.count + 1)
			end
			a_sorter.sort (Result)
		end
end
