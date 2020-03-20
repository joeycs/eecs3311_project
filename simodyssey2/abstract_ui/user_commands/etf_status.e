note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_STATUS
inherit
	ETF_STATUS_INTERFACE
create
	make
feature -- command
	status
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
				    if l_explorer.landed then
				        model.report_status (  "%N  Explorer status report:Stationary on planet surface at ["
				            				  + l_explorer.sector.row.out + "," + l_explorer.sector.column.out
				            				  + "," + l_explorer.pos.out + "]%N  "
				            				  + "Life units left:" + l_explorer.life.out + ", "
				            				  + "Fuel units left:" + l_explorer.fuel.out)
				    else
				        model.report_status (  "%N  Explorer status report:Travelling at cruise speed at ["
				            				  + l_explorer.sector.row.out + "," + l_explorer.sector.column.out
				            				  + "," + l_explorer.pos.out + "]%N  "
				            				  + "Life units left:" + l_explorer.life.out + ", "
				            				  + "Fuel units left:" + l_explorer.fuel.out)
				    end
				end
			end

			etf_cmd_container.on_change.notify ([Current])
    	end

end
