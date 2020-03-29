note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE

inherit
	ETF_MOVE_INTERFACE

create
	make

feature

	move (dir: INTEGER_32)
		require else
				move_precond (dir)
		local
			l_entity: ENTITY
			l_explorer: EXPLORER
		do
			if not model.game.in_game then
				model.report_error ("%N  Negative on that request:no mission in progress.")
			else
				across
					model.game.info.shared_info.entities is entity
				loop
					if attached {EXPLORER} entity as explorer then
						l_entity := model.game.find_entity (explorer)
						check attached {EXPLORER} l_entity as l_entity2 then
							l_explorer := l_entity2
						end
					end
				end
				check attached l_explorer then
					if l_explorer.landed then
						model.report_error ("%N  Negative on that request:you are currently landed at Sector:" + l_explorer.sector.row.out + ":" + l_explorer.sector.column.out)
					elseif not model.move (l_explorer, dir) then
						model.report_error ("%N  Cannot transfer to new location as it is full.")
						l_explorer.reset_failed_to_move
						model.game.moved_this_turn.make_empty
					end
				end
			end
			etf_cmd_container.on_change.notify ([Current])
		end

end -- class ETF_MOVE
