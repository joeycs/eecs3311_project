note
	description: "Galaxy represents a game board in simodyssey."
	author: "Kevin B"
	date: "$Date$"
	revision: "$Revision$"

class
	GALAXY

inherit ANY
	redefine
		out
	end

create
	make, make_dummy

feature -- attributes

	grid: ARRAY2 [SECTOR]
			-- the board

	gen: RANDOM_GENERATOR_ACCESS


	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

feature --constructor

	make
		-- creates a dummy of galaxy grid
		local
			row : INTEGER
			column : INTEGER
			explorer : EXPLORER
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			from
				row := 1
			until
				row > shared_info.number_rows
			loop

				from
					column := 1
				until
					column > shared_info.number_columns
				loop
					create explorer.make (grid[row,column])
					grid[row,column] := create {SECTOR}.make(row,column,explorer)
					explorer.set_sector (grid[row,column])
					column:= column + 1
				end
				row := row + 1
			end
			set_stationary_items
	end

	make_dummy
		do
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
		end

feature --commands

	set_stationary_items
			-- distribute stationary items amongst the sectors in the grid.
			-- There can be only one stationary item in a sector
		local
			loop_counter: INTEGER
			next_stationary_id: INTEGER
			check_sector: SECTOR
			temp_row: INTEGER
			temp_column: INTEGER
		do
			from
				loop_counter := 1
				next_stationary_id := -2
			until
				loop_counter > shared_info.number_of_stationary_items
			loop
				temp_row :=  gen.rchoose (1, shared_info.number_rows)
				temp_column := gen.rchoose (1, shared_info.number_columns)
				check_sector := grid[temp_row,temp_column]

				if (not check_sector.has_stationary) and (not check_sector.is_full) then
					grid[temp_row,temp_column].put (create_stationary_item (check_sector, next_stationary_id))
					loop_counter := loop_counter + 1
					next_stationary_id := next_stationary_id - 1
				end -- if
			end -- loop
		end -- feature set_stationary_items

	create_stationary_item (sector : SECTOR; id : INTEGER) : ENTITY
			-- this feature randomly creates one of the possible types of stationary actors
		local
			num: INTEGER
		do
			num := gen.rchoose (1, 3)
			inspect num
			when 1 then
				Result := create {YELLOW_DWARF}.make (sector, id)
			when 2 then
				Result := create {BLUE_GIANT}.make (sector, id)
			when 3 then
				Result := create {WORMHOLE}.make (sector, id)
			else
				Result := create {YELLOW_DWARF}.make (sector, id) -- create more yellow dwarfs this will never happen, but create by default
			end -- inspect
		end

	put_item (e : ENTITY; row : INTEGER; col : INTEGER)
			-- place given entity in sector located at [row, col] in the grid
		do
			grid[row, col].put (e)
		end

	remove_item (e : ENTITY; row : INTEGER; col : INTEGER)
			-- remove given entity in sector located at [row, col] in the grid
		local
			sector : ARRAYED_LIST [ENTITY]
			entities : LINKED_LIST [ENTITY]
			removed : BOOLEAN
		do
				-- remove from sector
				from
					sector := grid[row, col].contents
					sector.start
				until
					removed or sector.after
				loop
					if sector.item = e then
						sector.item.sector.chars_out [sector.item.pos] := '-'
						sector.remove
						removed := True
					else
						sector.forth
					end
				end

				-- remove from entities list
				from
					entities := shared_info.entities
					entities.start
					removed := False
				until
					removed or entities.after
				loop
					if entities.item = e then
						entities.remove
						removed := True
					else
						entities.forth
					end
				end
		end

feature -- query
	has_free_sector: BOOLEAN
			-- determine if the grid contains at least one sector which has at least one free location
		local
			row: INTEGER
			column: INTEGER
		do
			from
				row := 1
			until
				row > shared_info.number_rows
			loop
				from
					column := 1
				until
					column > shared_info.number_columns
				loop
					Result := grid[row,column].contents.count < 4
					if Result then
						row := shared_info.number_rows
						column := shared_info.number_columns
					end
					column := column + 1
				end
				row := row + 1
			end
		end

	out: STRING
	--Returns grid in string form
	local
		string1: STRING
		string2: STRING
		row_counter: INTEGER
		column_counter: INTEGER
		contents_counter: INTEGER
		temp_sector: SECTOR
		temp_component: ENTITY
		printed_symbols_counter: INTEGER
	do
		create Result.make_empty
		create string1.make(7*shared_info.number_rows)
		create string2.make(7*shared_info.number_columns)
		string1.append("%N")

		from
			row_counter := 1
		until
			row_counter > shared_info.number_rows
		loop
			string1.append("    ")
			string2.append("    ")

			from
				column_counter := 1
			until
				column_counter > shared_info.number_columns
			loop
				temp_sector:= grid[row_counter, column_counter]
			    string1.append("(")
            	string1.append(temp_sector.print_sector)
                string1.append(")")
			    string1.append("  ")
				from
					contents_counter := 1
					printed_symbols_counter:=0
				until
					contents_counter > temp_sector.contents.count
				loop
					temp_component := temp_sector.contents[contents_counter]
					printed_symbols_counter:= printed_symbols_counter+1
					contents_counter := contents_counter + 1
				end

				from
				until (shared_info.max_capacity - printed_symbols_counter)=0
				loop
						printed_symbols_counter:=printed_symbols_counter+1

				end
				string2.append (temp_sector.chars_out)
				string2.append("   ")
				column_counter := column_counter + 1
			end
			string1.append("%N")
			if not (row_counter = shared_info.number_rows) then
				string2.append("%N")
			end
			Result.append (string1.twin)
			Result.append (string2.twin)

			row_counter := row_counter + 1
			string1.wipe_out
			string2.wipe_out
		end
	end


end
