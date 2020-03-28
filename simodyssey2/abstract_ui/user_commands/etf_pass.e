note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PASS
inherit
	ETF_PASS_INTERFACE
create
	make
feature -- command
	pass
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
				
				check attached {EXPLORER} l_explorer then
					model.pass (l_explorer)
				end
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
