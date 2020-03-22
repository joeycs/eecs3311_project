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

    asteroid_threshold: INTEGER
		-- used to determine the chance of an asteroid being put in a location
		attribute
			Result := 10
		end

	janitaur_threshold: INTEGER
		-- used to determine the chance of a janitaur being put in a location
		attribute
			Result := 20
		end

	malevolent_threshold: INTEGER
		-- used to determine the chance of a malevolent being put in a location
		attribute
			Result := 30
		end

	benign_threshold: INTEGER
		-- used to determine the chance of a benign being put in a location
		attribute
			Result := 40
		end

    planet_threshold: INTEGER
		-- used to determine the chance of a planet being put in a location
		attribute
			Result := 50
		end

	max_capacity: INTEGER = 4
		 -- max number of objects that can be stored in a location

feature -- commands
	test(a_threshold: INTEGER; j_threshold: INTEGER; m_threshold: INTEGER; b_threshold: INTEGER; p_threshold: INTEGER)
		--sets threshold values
		require
			valid_threshold:
				0 < a_threshold and a_threshold <= j_threshold and j_threshold <= m_threshold
				and m_threshold <= b_threshold and b_threshold <= p_threshold and p_threshold <= 101
		do
				set_asteroid_threshold (a_threshold)
				set_benign_threshold (b_threshold)
				set_janitaur_threshold (j_threshold)
				set_malevolent_threshold (m_threshold)
				set_planet_threshold (p_threshold)
		end

	set_malevolent_threshold(threshhold:INTEGER)
		do
			malevolent_threshold:=threshhold
		end

	set_janitaur_threshold(threshhold:INTEGER)
		do
			janitaur_threshold:=threshhold
		end

	set_asteroid_threshold(threshhold:INTEGER)
		do
			asteroid_threshold:=threshhold
		end
	set_planet_threshold(threshhold:INTEGER)
		do
			planet_threshold:=threshhold
		end

	set_benign_threshold(threshhold:INTEGER)
		do
			benign_threshold:=threshhold
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
