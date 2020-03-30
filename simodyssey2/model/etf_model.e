note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create game.make
			create game_out.make_empty
			create mode_out.make_empty
			create status.make_from_string ("ok")
			create msg.make_from_string ("%N  Welcome! Try test(3,5,7,15,30)")
			create msg2.make_empty
			state := 0
			substate := 0
		end

feature -- model attributes
	game : GAME
	game_out : STRING
	mode_out : STRING
	status : STRING
	msg : STRING
	msg2 : STRING
	state : INTEGER
	substate : INTEGER
	info : SHARED_INFORMATION_ACCESS

feature -- model operations
	reset
			-- Reset model state.
		do
			make
		end

	test (a_threshold, j_threshold, m_threshold, b_threshold, p_threshold: INTEGER)
			-- Initiate game in test mode with given thresholds.
		do
			new_game ("test", a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
			update_game (create {STRING}.make_empty)
		end

	play	-- Initiate game in play mode with default thresholds.
		do
			new_game ("play", 3, 5, 7, 15, 30)
			update_game (create {STRING}.make_empty)
		end

	report_status (status_msg: STRING)
			-- Display the explorer's current status.
		do
			substate := substate + 1
			status.make_from_string ("ok")
			msg.make_from_string (status_msg)
			game_out.make_empty
		end

	abort
			-- Terminate the current game.
		do
			substate := substate + 1
			status.make_from_string ("ok")
			game.end_game
			game_out.make_empty
			mode_out.make_empty
			msg.make_from_string ("%N  Mission aborted. Try test(3,5,7,15,30)")
		end

	new_game (mode: STRING; a_threshold, j_threshold, m_threshold, b_threshold, p_threshold: INTEGER)
			-- Initiate game with given game mode and thresholds.
		do
			status.make_from_string ("ok")
			msg.make_empty
			msg2.make_empty
			game.new_game (mode, a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
			mode_out.make_from_string ("mode:" + game.get_mode + ", ")
		end

	move (l_explorer: EXPLORER;  dir: INTEGER): BOOLEAN
			-- Move the explorer in direction provided by the user.
		do
			Result := game.move_entity (l_explorer,  dir)
			if Result then
				turn
				update_game (create {STRING}.make_empty)

				if l_explorer.is_dead then
					lose_game (l_explorer.death_message)
				end
			end
		end

	pass (l_explorer: EXPLORER)
			-- Allow the game to advance one turn without explorer performing an action.
		do
			turn
			update_game (create {STRING}.make_empty)

			if l_explorer.is_dead then
				lose_game (l_explorer.death_message)
			end
		end

	land (l_explorer : EXPLORER; land_msg : STRING)
			-- Attempt to land the explorer on a planet.
		do
	    	l_explorer.land
	    	turn
	    	update_game (land_msg)
		end

	liftoff (l_explorer : EXPLORER; lift_msg : STRING)
			-- Attempt to lift the explorer off of its current planet.
		do
			l_explorer.liftoff
			turn
			update_game (lift_msg)
		end

	wormhole (l_explorer : EXPLORER)
			-- Attempt to warp the explorer to a random location in the galaxy.
		do
			game.warp_entity (l_explorer)
			turn
			update_game (create {STRING}.make_empty)
		end

	update_game (game_msg: STRING)
			-- Display the current state of the game and galaxy.
		do
			state := state + 1
			substate := 0
			status.make_from_string ("ok")
			msg.make_from_string (game_msg)
			game_out.make_from_string (game.out)
		end

	win_game
			-- Initiate game win state.
		do
			game.end_game
			game_out.make_empty
		end

	lose_game (lose_msg: STRING)
			-- Initiate game lose state.
		do
			msg.make_from_string ("%N  " + lose_msg + "%N  The game has ended. You can start a new game.")

			if game.mode ~ "test" then
				msg2.make_from_string (msg)
			end

			game.end_game
		end

	turn
			-- Advance the game one turn.
		do
			game.advance_turn
		end

	report_error (error_msg: STRING)
			-- Display current error information.
		do
			substate := substate + 1
			status.make_from_string ("error")
			msg.make_from_string (error_msg)

			if not game.in_game then
				mode_out.make_empty
			end

			msg2.make_empty
			game_out.make_empty
		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")
			Result.append ("state:" + state.out + "." + substate.out + ", " + mode_out + status)
			Result.append (msg)
			Result.append (game_out)
			Result.append (msg2)
		end
end
