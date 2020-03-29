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
			--create failed_to_move.make_empty
			create died_this_turn.make_empty
		end

feature -- game attributes
	info : SHARED_INFORMATION_ACCESS
	game : INTEGER
	mode : STRING
	galaxy : GALAXY
	moved_this_turn : ARRAY [MOVABLE_ENTITY]
	died_this_turn : ARRAY [MOVABLE_ENTITY]
	--failed_to_move : ARRAY [MOVABLE_ENTITY]

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
			--create failed_to_move.make_empty
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
			l_wormhole: detachable WORMHOLE
			l_explorer: EXPLORER
			num: INTEGER
			moved: BOOLEAN
		do
			across info.shared_info.entities is entity loop
				if attached {SENTIENT_ENTITY} entity as sentient then
					sentient.reset_fuel_calculated
					sentient.reset_used_wormhole
				end

				if attached {EXPLORER} entity as explorer then
					l_explorer := explorer
					check_entity (l_explorer)
				end
			end

			check attached l_explorer then end

			if not l_explorer.found_life then
				across info.shared_info.sorted_entities is entity loop
					if attached {CPU_ENTITY} entity as cpu then
						l_star := void
						l_yellow_dwarf := void
						l_wormhole := void

						across cpu.sector.contents is e loop
							if attached {STAR} e as star then
								l_star := star
								if attached {YELLOW_DWARF} star as yd then
									l_yellow_dwarf := yd
								end
							end

							if attached {WORMHOLE} e as wh then
								l_wormhole := wh
							end
						end

						if cpu.turns_left = 0 then

								if attached {PLANET} cpu as planet and attached l_star then
									planet.set_attached
									if attached l_yellow_dwarf then
										num := galaxy.gen.rchoose (1, 2)
										info.shared_info.rng_usage.extend ("(T->" + num.out + ":[1,2]),")
										if num = 2 then
											planet.set_supports_life
										end
									end
								else
									check attached {MOVABLE_ENTITY} cpu as movable then
										moved := False

										if not movable.is_dead then
											if attached l_wormhole then
												if attached {MALEVOLENT} movable as warpable then
													warp_entity (warpable)
													moved := True
												elseif attached {BENIGN} movable as warpable then
													warp_entity (warpable)
													moved := True
												end
											end

											if not moved then
												num := galaxy.gen.rchoose (1, 8)
												info.shared_info.rng_usage.extend ("(T->" + num.out + ":[1,8]),")
												moved := move_entity (movable, num)
											end
										end

									    check_entity (movable)
										if not movable.is_dead then
											if attached {REPRODUCING_ENTITY} movable as reproducing then
												if attached reproducing.get_new_clone as new_clone then
													new_clone.set_clone (reproducing.sector, info.shared_info.number_of_movable_items + 1)
													galaxy.put_item (new_clone, reproducing.sector.row, reproducing.sector.column)

													check attached {CPU_ENTITY} new_clone as new_cpu then
														new_cpu.set_behaviour (True, info.shared_info.rng_usage)
													end

													info.shared_info.increment_number_of_movable_items
												end
											end
											cpu.set_behaviour (False, info.shared_info.rng_usage)
										end
									end
								end

								across cpu.sector.sorted_contents is item loop
									if attached {MOVABLE_ENTITY} item as movable then
										check_entity (movable)
									end
								end
						else
							cpu.decrement_turns_left
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

			if not attached new_sector then
				l_entity.set_failed_to_move
				--failed_to_move.force (l_entity, failed_to_move.count + 1)
			end

			moved_this_turn.force (l_entity, moved_this_turn.count + 1)
			galaxy.put_item (l_entity, l_entity.sector.row, l_entity.sector.column)
			Result := attached new_sector
		end

	warp_entity (l_entity: SENTIENT_ENTITY)
		local
			curr_sector: SECTOR
			new_sector: detachable SECTOR
			warped : BOOLEAN
			same_loc: BOOLEAN
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
				info.shared_info.rng_usage.extend ("(W->" + temp_row.out + ":[1,5]),")
				temp_col := galaxy.gen.rchoose (1, 5)
				info.shared_info.rng_usage.extend ("(W->" + temp_col.out + ":[1,5]),")

				if not galaxy.grid[temp_row, temp_col].is_full then
					galaxy.remove_item (l_entity, l_entity.sector.row, l_entity.sector.column)
					new_sector := move_helper (curr_sector, (temp_row - curr_sector.row), (temp_col - curr_sector.column))

					if attached new_sector then
						l_entity.set_sector (new_sector)
						l_entity.set_used_wormhole
					else
						same_loc := True
					end

					galaxy.put_item (l_entity, l_entity.sector.row, l_entity.sector.column)

					if    l_entity.sector.row = l_entity.prev_sector_row
				      and l_entity.sector.column = l_entity.prev_sector_col
				      and l_entity.pos = l_entity.prev_sector_pos then
						same_loc := True
					end

					if same_loc then
						l_entity.set_failed_to_move
						--failed_to_move.force (l_entity, failed_to_move.count + 1)
					end

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

			if attached {SENTIENT_ENTITY} l_entity as l_sentient then
				if not l_sentient.fuel_calculated and moved_this_turn.has (l_sentient) then
					if not (l_sentient.used_wormhole or l_sentient.failed_to_move) then
						l_sentient.add_fuel (-1)
					end

					if attached l_star then
						l_sentient.add_fuel (l_star.luminosity)
					end
				end

				if l_sentient.fuel = 0 then
					l_sentient.set_dead
					l_sentient.set_death_message (  " got lost in space - out of fuel at Sector:"
					                              + l_entity.sector.row.out + ":" + l_entity.sector.column.out)
				end
			end

			if not l_entity.dead and attached l_blackhole then
				l_entity.set_dead
				l_entity.set_death_message (  " got devoured by blackhole (id: " + l_blackhole.ID.out
					                        + ") at Sector:" + l_entity.sector.row.out + ":" + l_entity.sector.column.out)
			end

			if l_entity.is_dead and not died_this_turn.has (l_entity) then
				died_this_turn.force (l_entity, died_this_turn.count + 1)
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
			-- DEBUG
			i: INTEGER
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
					Result.append ("%N    [" + m_e.ID.out + "," + m_e.char.out + "]:[")

					if m_e.failed_to_move then
						Result.append (m_e.sector.row.out + "," + m_e.sector.column.out + "," + m_e.pos.out + "]")
					else
						Result.append (  m_e.prev_sector_row.out + "," + m_e.prev_sector_col.out + "," + m_e.prev_sector_pos.out + "]"
						               + "->["
						               + m_e.sector.row.out + "," + m_e.sector.column.out + "," + m_e.pos.out + "]")
					end
					m_e.reset_failed_to_move

					if attached {REPRODUCING_ENTITY} m_e as r_e then
						if r_e.reproduced_this_turn then
							check attached r_e.newest_clone as l_clone then
								Result.append (  "%N      reproduced [" + l_clone.ID.out + "," + l_clone.char.out + "] at ["
											   + l_clone.sector.row.out + "," + l_clone.sector.column.out + "," + l_clone.pos.out + "]")
							end
							r_e.reset_reproduced_this_turn
						end
					end

					if attached {CPU_ENTITY} m_e as cpu then
						if cpu.destroyed_this_turn then
							across cpu.destroys_this_turn is l_destroy loop
									Result.append (  "%N      destroyed [" + l_destroy.ID.out + "," + l_destroy.char.out + "] at ["
												   + l_destroy.sector.row.out + "," + l_destroy.sector.column.out + "," + l_destroy.pos.out + "]")
							end
							cpu.reset_destroyed_this_turn
						end
					end

					if attached {MALEVOLENT} m_e as mal then
						if mal.attacked_this_turn then
							check attached mal.newest_attack as l_attack then
								Result.append (  "%N      attacked [" + l_attack.ID.out + "," + l_attack.char.out + "] at ["
										  	   + l_attack.sector.row.out + "," + l_attack.sector.column.out + "," + l_attack.pos.out + "]")
							end
							mal.reset_attacked_this_turn
						end
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
			moved_this_turn.make_empty
			--failed_to_move.make_empty
			died_this_turn.make_empty
			-- DEBUG
--			i := 1
--			Result.append ("%N  RNG Usage:%N    ")
--			across info.shared_info.rng_usage is string loop
--				Result.append (string)
--				if i \\ 5 = 0 then
--					Result.append ("%N    ")
--				end
--				i := i + 1
--			end
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
						   or  (new_row = row and new_col = column) then
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
