note
	description: "Summary description for {GAME}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GAME

inherit
	ANY
		redefine
			out
		end

create
	make

feature {NONE} -- initialization
	make
		do
			game := 0
			create mode.make_empty
			create galaxy.make_dummy
			create moved_this_turn.make_empty
			create failed_to_move.make_empty
			create died_this_turn.make_empty
		end

feature -- game attributes
	info : SHARED_INFORMATION_ACCESS
	game : INTEGER
	mode : STRING
	galaxy : GALAXY
	moved_this_turn : ARRAY [MOVABLE_ENTITY]
	died_this_turn : ARRAY [MOVABLE_ENTITY]
	failed_to_move : ARRAY [MOVABLE_ENTITY]

feature -- commands
	new_game (m : STRING; a_threshold, j_threshold, m_threshold, b_threshold, p_threshold: INTEGER)
		require
			valid_mode:
				   m ~ "test"
				or m ~ "play"
		do
			info.shared_info.test (a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
			create galaxy.make
			create moved_this_turn.make_empty
			create failed_to_move.make_empty
			create died_this_turn.make_empty
			game := game + 1
			mode.make_from_string (m)
		ensure
			game_incremented:
				game = old game + 1
			mode_set:
				mode ~ m
		end

	end_game
		require
			in_game
		do
			mode.make_empty
			info.shared_info.reset
		ensure
			game_over:
				mode.is_empty
		end

	advance_turn
		local
			l_star: detachable STAR
			l_yellow_dwarf: detachable YELLOW_DWARF
			num: INTEGER
			ok: BOOLEAN
			explorer_won: BOOLEAN
		do
			across info.shared_info.sorted_entities is entity loop
				if attached {EXPLORER} entity as l_explorer then
					check_entity (l_explorer)
					if l_explorer.found_life then
						explorer_won := true
					end
				end
			end

			if not explorer_won then
				across info.shared_info.sorted_entities is entity loop
					if attached {PLANET} entity as planet then
						l_star := void
						l_yellow_dwarf := void

						across planet.sector.contents is e loop
							if attached {STAR} e as star then
								l_star := star
								if attached {YELLOW_DWARF} star as yd then
									l_yellow_dwarf := yd
								end
							end
						end

						if planet.turns_left = 0 then

								if attached l_star then
									planet.set_attached
									if attached l_yellow_dwarf then
										num := galaxy.gen.rchoose (1, 2)
										if num = 2 then
											planet.set_supports_life
										end
									end
								else
									num := galaxy.gen.rchoose (1, 8)
									ok := move_entity (planet, num)
								    check_entity (planet)
									if not planet.is_dead then
										planet.set_behaviour (False)
									end
								end

						else
							planet.decrement_turns_left
						end
					end
				end
			end
		end

	move_entity (l_entity: MOVABLE_ENTITY;  dir: INTEGER): BOOLEAN
		local
			curr_sector: SECTOR
			new_sector: detachable SECTOR
		do
			curr_sector := l_entity.sector
			galaxy.remove_item (l_entity, l_entity.sector.row, l_entity.sector.column)

			inspect
				dir
			when 1 then
				-- move N
				new_sector := move_helper (curr_sector, -1, 0)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			when 2 then
				-- move NE
				new_sector := move_helper (curr_sector, -1, 1)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			when 3 then
				-- move E
				new_sector := move_helper (curr_sector, 0, 1)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			when 4 then
				-- move SE
				new_sector := move_helper (curr_sector, 1, 1)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			when 5 then
				-- move S
				new_sector := move_helper (curr_sector, 1, 0)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			when 6 then
				-- move SW
				new_sector := move_helper (curr_sector, 1, -1)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			when 7 then
				-- move W
				new_sector := move_helper (curr_sector, 0, -1)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			else
				-- move NW
				new_sector := move_helper (curr_sector, -1, -1)
				if attached new_sector then
					l_entity.set_sector (new_sector)
				end
			end

			if attached new_sector then
				moved_this_turn.force (l_entity, moved_this_turn.count + 1)
			elseif attached {PLANET} l_entity as l_planet then
				moved_this_turn.force (l_planet, moved_this_turn.count + 1)
				l_planet.set_failed_to_move
				failed_to_move.force (l_planet, failed_to_move.count + 1)
			end

			galaxy.put_item (l_entity, l_entity.sector.row, l_entity.sector.column)
			Result := attached new_sector
		end

	warp_entity (l_entity: MOVABLE_ENTITY)
		local
			curr_sector: SECTOR
			new_sector: detachable SECTOR
			warped : BOOLEAN
			temp_row: INTEGER
			temp_col: INTEGER
		do
			from
				curr_sector := l_entity.sector
				warped := False
			until
				warped
			loop
				temp_row := galaxy.gen.rchoose (1, 5)
				temp_col := galaxy.gen.rchoose (1, 5)

				if not galaxy.grid[temp_row, temp_col].is_full then
					galaxy.remove_item (l_entity, l_entity.sector.row, l_entity.sector.column)
					new_sector := move_helper (curr_sector, (temp_row - curr_sector.row), (temp_col - curr_sector.column))

					if attached new_sector then
						l_entity.set_sector (new_sector)
					else
						moved_this_turn.force (l_entity, moved_this_turn.count + 1)
						l_entity.set_failed_to_move
						failed_to_move.force (l_entity, failed_to_move.count + 1)
					end

					galaxy.put_item (l_entity, l_entity.sector.row, l_entity.sector.column)
			        moved_this_turn.force (l_entity, moved_this_turn.count + 1)
					warped := True
				end
			end
		end

	check_entity (l_entity: MOVABLE_ENTITY)
		local
			l_star : detachable STAR
			l_blackhole : detachable BLACKHOLE
		do
			l_star := void
			l_blackhole := void

			across l_entity.sector.contents is e loop
				if attached {STAR} e as s then
					l_star := s
				elseif attached {BLACKHOLE} e as bh then
					l_blackhole := bh
				end
			end

			if attached {EXPLORER} l_entity as l_explorer then
				if attached l_star then
					l_explorer.add_fuel (l_star.luminosity)
				end

				if l_explorer.fuel = 0 then
					l_explorer.set_dead
					died_this_turn.force (l_explorer, died_this_turn.count)
					l_explorer.set_death_message (  " got lost in space - out of fuel at Sector:"
					                              + l_entity.sector.row.out + ":" + l_entity.sector.column.out)
				end
			elseif attached {PLANET} l_entity as l_planet then
				if attached l_star then
					l_planet.set_attached
				end
			end

			if attached l_blackhole then
				l_entity.set_dead
				died_this_turn.force (l_entity, died_this_turn.count)
				l_entity.set_death_message (  " got devoured by blackhole (id: " + l_blackhole.ID.out
					                        + ") at Sector:" + l_entity.sector.row.out + ":" + l_entity.sector.column.out)
			end

			if l_entity.is_dead then
				galaxy.remove_item (l_entity, l_entity.sector.row, l_entity.sector.column)
			end

		end

feature -- queries
	in_game : BOOLEAN
		do
			Result := not mode.is_empty
		end

	get_game : INTEGER
		do
			Result := game
		end

	get_mode : STRING
		do
			Result := mode
		end

	find_entity (e: ENTITY): detachable ENTITY
		local
			row: INTEGER
			column: INTEGER
		do
			from
				row := 1
			until
				row > info.shared_info.number_rows
			loop
				from
					column := 1
				until
					column > info.shared_info.number_columns
				loop
					across galaxy.grid[row,column].contents is entity loop
						if entity.is_equal (e) then
							Result := entity
						end
					end
					column := column + 1
				end
				row := row + 1
			end
		end

	check_move (l_entity: MOVABLE_ENTITY;  dir: INTEGER): BOOLEAN
		do
			Result := move_entity (l_entity, dir)
		end

	out : STRING
		local
			row: INTEGER
			column: INTEGER
			sectors: ARRAY2 [STRING]
		do
			create Result.make_empty
			create sectors.make_filled ("SECTOR", info.shared_info.number_rows, info.shared_info.number_columns)

			from
				row := 1
			until
				row > info.shared_info.number_rows
			loop
				from
					column := 1
				until
					column > info.shared_info.number_columns
				loop
					sectors.put (galaxy.grid[row, column].out, row, column)
					column := column + 1
				end
				row := row + 1
			end

			Result.append ("%N  Movement:")
			if moved_this_turn.is_empty then
				Result.append ("none")
			else
				across moved_this_turn is m_e loop
					if failed_to_move.has (m_e) then
						Result.append ("%N    [" + m_e.ID.out + "," + m_e.char.out + "]:[" + m_e.sector.row.out + "," + m_e.sector.column.out + "," + m_e.pos.out + "]")
					else
						Result.append ("%N    [" + m_e.ID.out + "," + m_e.char.out + "]:["
						               + m_e.prev_sector_row.out + "," + m_e.prev_sector_col.out + "," + m_e.prev_sector_pos.out + "]"
						               + "->["
						               + m_e.sector.row.out + "," + m_e.sector.column.out + "," + m_e.pos.out + "]")
					end
				end
			end

			if mode ~ "test" then
				Result.append ("%N  Sectors:")

				from
					row := 1
				until
					row > info.shared_info.number_rows
				loop
					from
						column := 1
					until
						column > info.shared_info.number_columns
					loop
						Result.append ("%N  " + sectors[row, column])
						column := column + 1
					end
					row := row + 1
				end

				Result.append ("%N  Descriptions:")
				across info.shared_info.sorted_entities is entity loop
					Result.append ("%N  " + entity.out)
				end

				Result.append ("%N  Deaths This Turn:")
				if died_this_turn.is_empty then
					Result.append ("none")
				else
					across died_this_turn is m_e loop
						Result.append ("%N  " + m_e.out + ",")
						Result.append ("%N      " + m_e.death_message)
					end
				end
			end

			Result.append (galaxy.out)
		end

feature {NONE} -- private helper features
	move_helper (curr_sector: SECTOR; drow: INTEGER; dcol: INTEGER): detachable SECTOR
		local
			row: INTEGER
			column: INTEGER
			new_row: INTEGER
			new_col: INTEGER
		do
			from
				row := 1
			until
				row > info.shared_info.number_rows
			loop
				from
					column := 1
				until
					column > info.shared_info.number_columns
				loop
					if galaxy.grid[row, column] = curr_sector then
						new_row := row + drow
						new_col := column + dcol

						if (new_row) < 1 then
							-- N Wraparound
							new_row := info.shared_info.number_rows
						end

						if (new_row) > info.shared_info.number_rows then
							-- S Wraparound
							new_row := 1
						end

						if (column + dcol) < 1 then
							-- W Wraparound
							new_col := info.shared_info.number_columns
						end

						if (column + dcol) > info.shared_info.number_columns then
							-- E Wraparound
							new_col := 1
						end

						if not galaxy.grid[new_row, new_col].is_full
						   or  (drow = 0 and dcol = 0)               then
							Result := galaxy.grid[new_row, new_col]
						end
					end
					column := column + 1
				end
				row := row + 1
			end
		end

--	invariant
--		valid_game:
--			game >= 0
end
