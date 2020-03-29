note
	description: "Represents a sector in the galaxy."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SECTOR

inherit
	ANY
		redefine
			out
		end

create
	make, make_dummy

feature -- attributes
	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

	gen: RANDOM_GENERATOR_ACCESS

	contents: ARRAYED_LIST [ENTITY] --holds 4 quadrants

	row: INTEGER

	column: INTEGER

	chars_out: STRING

feature -- constructor
	make(row_input: INTEGER; column_input: INTEGER; a_explorer:ENTITY)
		--initialization
		require
			valid_row: (row_input >= 1) and (row_input <= shared_info.number_rows)
			valid_column: (column_input >= 1) and (column_input <= shared_info.number_columns)
		do
			create chars_out.make_filled ('-', 4)

			row := row_input
			column := column_input

			create contents.make (shared_info.max_capacity) -- Each sector should have 4 quadrants
			contents.compare_objects

			if (row = 3) and (column = 3) then
				put (create {BLACKHOLE}.make (Current)) -- If this is the sector in the middle of the board, place a black hole
			else
				if (row = 1) and (column = 1) then
					put (a_explorer) -- If this is the top left corner sector, place the explorer there
				end
				populate -- Run the populate command to complete setup
			end -- if
		end

feature -- commands
	make_dummy
		--initialization without creating entities in quadrants
		do
			create chars_out.make_empty
			create contents.make (shared_info.max_capacity)
			contents.compare_objects
		end

	populate
			-- this feature creates 1 to max_capacity-1 components to be intially stored in the
			-- sector. The component may be a planet or nothing at all.
		local
			threshold: INTEGER
			number_items: INTEGER
			loop_counter: INTEGER
			component: CPU_ENTITY
		do
			number_items := gen.rchoose (1, shared_info.max_capacity-1)  -- MUST decrease max_capacity by 1 to leave space for Explorer (so a max of 3)
			shared_info.rng_usage.extend ("(S->" + number_items.out + ":[1,3]),")
			from
				loop_counter := 1
			until
				loop_counter > number_items
			loop
				threshold := gen.rchoose (1, 100) -- each iteration, generate a new value to compare against the threshold values provided by `test` or `play`
				shared_info.rng_usage.extend ("(S->" + threshold.out + ":[1,100]),")

				if threshold < shared_info.asteroid_threshold then
					component := create {ASTEROID}.make (Current, shared_info.number_of_movable_items + 1)
				else
					if threshold < shared_info.janitaur_threshold then
						component := create {JANITAUR}.make (Current, shared_info.number_of_movable_items + 1)
					else
						if (threshold < shared_info.malevolent_threshold) then
							component := create {MALEVOLENT}.make (Current, shared_info.number_of_movable_items + 1)
						else
							if (threshold < shared_info.benign_threshold) then
								component := create {BENIGN}.make (Current, shared_info.number_of_movable_items + 1)
							else
								if threshold < shared_info.planet_threshold then
									component := create {PLANET}.make (Current, shared_info.number_of_movable_items + 1)
								end
							end
						end
					end
				end

				if attached component as entity then
					component.set_behaviour (True, shared_info.rng_usage)
					shared_info.increment_number_of_movable_items
					put (entity) -- add new entity to the contents list

					--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
					-- turn:=gen.rchoose (0, 2) -- Hint: Use this number for assigning turn values to the planet created
					-- The turn value of the planet created (except explorer) suggests the number of turns left before it can move.
					--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

					component := void -- reset component object
				end

				loop_counter := loop_counter + 1
			end
		end

feature {GALAXY} --command

	put (new_component: ENTITY)
			-- put `new_component' in contents array
		local
			loop_counter: INTEGER
			found: BOOLEAN
		do
			from
				loop_counter := 1
			until
				loop_counter > contents.count or found
			loop
				if contents [loop_counter] = new_component then
					found := TRUE
				end --if
				loop_counter := loop_counter + 1
			end -- loop

			if not found and not is_full then
				next_available_quad (new_component)
				contents.extend (new_component)
				shared_info.entities.extend (new_component)
			end
		ensure
			component_put: not is_full implies contents.has (new_component)
		end

	next_available_quad (l_entity: ENTITY)
		local
			found: BOOLEAN
			stay: BOOLEAN
		do
			if attached {MOVABLE_ENTITY} l_entity as m_e then
				if m_e.failed_to_move then
					stay := true
					chars_out [m_e.pos] := l_entity.char.item
				end
			end

			if not stay then
				across 1 |..| chars_out.count is i loop
					if (chars_out [i] ~ '-') and (not found) then
						l_entity.set_pos (i)
						chars_out [i] := l_entity.char.item
						found := true
					end
				end
			end
		end

feature -- Queries

	print_sector: STRING
			-- Printable version of location's coordinates with different formatting
		do
			Result := ""
			Result.append (row.out)
			Result.append (":")
			Result.append (column.out)
		end

	is_full: BOOLEAN
			-- Is the location currently full?
		local
			loop_counter: INTEGER
			occupant: ENTITY
			empty_space_found: BOOLEAN
		do
			if contents.count < shared_info.max_capacity then
				empty_space_found := TRUE
			end
			from
				loop_counter := 1
			until
				loop_counter > contents.count or empty_space_found
			loop
				occupant := contents [loop_counter]
				if not attached occupant  then
					empty_space_found := TRUE
				end
				loop_counter := loop_counter + 1
			end

			if contents.count = shared_info.max_capacity and then not empty_space_found then
				Result := TRUE
			else
				Result := FALSE
			end
		end

	has_stationary: BOOLEAN
			-- returns whether the location contains any stationary item
		local
			loop_counter: INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > contents.count or Result
			loop
				if attached contents [loop_counter] as temp_item  then
					Result := temp_item.char.is_stationary
				end -- if
				loop_counter := loop_counter + 1
			end
		end

	sorted_contents: ARRAY [ENTITY]
		local
			a_comparator: ENTITY_COMPARATOR [ENTITY]
			a_sorter: DS_ARRAY_QUICK_SORTER [ENTITY]
		do
			create a_comparator
			create a_sorter.make (a_comparator)
			create Result.make_empty
			across
				contents is e
			loop
				Result.force (e, Result.count + 1)
			end
			a_sorter.sort (Result)
		end

	out: STRING
		local
			quads: ARRAY [STRING]
		do
			create quads.make_filled ("-", 1, 4)
			create Result.make_empty
			Result.append ("  [" + row.out + "," + column.out + "]->")

			across 1 |..| contents.count is i loop
				across 1 |..| 4 is j loop
					if j = contents [i].pos then
						quads.force (("[" + contents [i].ID.out + "," + contents [i].char.out + "]"), j)
					end
				end
			end

			across 1 |..| quads.count is i loop
				Result.append (quads [i])
				if i < 4 then
					Result.append (",")
				end
			end
		end

end
