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
			create msg.make_from_string ("%N  Welcome! Try test(30)")
			create msg2.make_empty
			state := 0
			substate := 0
			-- DEBUG
			create my_benign.make
			create my_benign_clone.make
			create my_benign_clone_2.make
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
	-- DEBUG
	my_benign : BENIGN
	my_benign_clone : BENIGN
	my_benign_clone_2 : BENIGN

feature -- model operations
	reset
			-- Reset model state.
		do
			make
		end

	test (p_threshold: INTEGER_32)
		do
			new_game ("test", p_threshold)
			update_game (create {STRING}.make_empty)
		end

	play
		do
			new_game ("play", 30)
			update_game (create {STRING}.make_empty)
			-- DEBUG
			my_benign_clone := my_benign.get_new_clone
			my_benign_clone_2 := my_benign.get_new_clone
			print (  "%N  CLONES DIFFERENT OBJECTS?:"
			       + (my_benign /= my_benign_clone and my_benign /= my_benign_clone_2).out)
			print (  "%N  CLONES EQUIVALENT OBJECTS?:"
			       + (my_benign.is_equal (my_benign_clone) and my_benign.is_equal (my_benign_clone_2)).out + "%N")
		end

	report_status (status_msg: STRING)
		do
			substate := substate + 1
			status.make_from_string ("ok")
			msg.make_from_string (status_msg)
			game_out.make_empty
		end

	abort
		do
			substate := substate + 1
			status.make_from_string ("ok")
			game.end_game
			game_out.make_empty
			mode_out.make_empty
			msg.make_from_string ("%N  Mission aborted. Try test(30)")
		end

	new_game (mode: STRING; threshold: INTEGER)
		do
			status.make_from_string ("ok")
			msg.make_empty
			msg2.make_empty
			game.new_game (mode, threshold)
			mode_out.make_from_string ("mode:" + game.get_mode + ", ")
		end

	move (l_explorer: EXPLORER;  dir: INTEGER): BOOLEAN
		do
			Result := game.move_entity (l_explorer,  dir)
			if Result then
				l_explorer.add_fuel (-1)
				turn
				update_game (create {STRING}.make_empty)

				if l_explorer.is_dead then
					lose_game (l_explorer.death_message)
				end
			end
		end

	pass
		do
			turn
			update_game (create {STRING}.make_empty)
		end

	land (l_explorer : EXPLORER; land_msg : STRING)
		do
	    	l_explorer.land
	    	turn
	    	update_game (land_msg)
		end

	liftoff (l_explorer : EXPLORER; lift_msg : STRING)
		do
			l_explorer.liftoff
			turn
			update_game (lift_msg)
		end

	wormhole (l_explorer : EXPLORER)
		do
			game.warp_entity (l_explorer)
			turn
			update_game (create {STRING}.make_empty)
		end

	update_game (game_msg: STRING)
		do
			state := state + 1
			substate := 0
			status.make_from_string ("ok")
			msg.make_from_string (game_msg)
			game_out.make_from_string (game.out)
			game.moved_this_turn.make_empty
			game.failed_to_move.make_empty
			game.died_this_turn.make_empty
		end

	win_game
		do
			game.end_game
			game_out.make_empty
		end

	lose_game (lose_msg: STRING)
		do
			msg.make_from_string ("%N  " + lose_msg + "%N  The game has ended. You can start a new game.")

			if game.mode ~ "test" then
				msg2.make_from_string (msg)
			end

			game.end_game
		end

	turn
		do
			game.advance_turn
		end

	report_error (error_msg: STRING)
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
