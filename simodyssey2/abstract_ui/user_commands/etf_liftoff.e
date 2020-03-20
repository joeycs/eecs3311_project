note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIFTOFF
inherit
	ETF_LIFTOFF_INTERFACE
create
	make
feature -- command
	liftoff
		local
			l_entity : ENTITY
			l_explorer : EXPLORER
    	do
			if not model.game.in_game then
					model.report_error ("%N  Negative on that request:no mission in progress.")
			else
				across model.game.info.shared_info.entities is entity loop
		    		if attached {EXPLORER} entity as explorer then
		    			l_entity := model.game.find_entity (explorer)
		    			check attached {EXPLORER} l_entity as l_entity2 then
		    				l_explorer := l_entity2
		    			end
		    		end
		    	end

				check attached l_explorer then
				    if not l_explorer.landed then
				        model.report_error (  "%N  Negative on that request:you are not on a planet at Sector:"
				            				+ l_explorer.sector.row.out + ":" + l_explorer.sector.column.out    )
				    else
				    	model.liftoff (l_explorer, (  "%N  Explorer has lifted off from planet at Sector:"
				            				        + l_explorer.sector.row.out + ":" + l_explorer.sector.column.out))
				    end
				end
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
