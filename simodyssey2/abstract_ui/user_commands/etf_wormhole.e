note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_WORMHOLE
inherit
	ETF_WORMHOLE_INTERFACE
create
	make
feature -- command
	wormhole
    	local
			l_entity : ENTITY
			l_explorer : EXPLORER
			l_wormhole : detachable WORMHOLE
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

		    			across l_explorer.sector.contents is entity2 loop
			    			if attached {WORMHOLE} entity2 as wh then
			    				l_wormhole := wh
			    			end
		    			end

		    		end
		    	end

				check attached l_explorer then
				    if l_explorer.landed then
				        model.report_error (  "%N  Negative on that request:you are currently landed at Sector:"
				            				+ l_explorer.sector.row.out + ":" + l_explorer.sector.column.out    )
				    elseif not attached l_wormhole then
				    	model.report_error (  "%N  Explorer couldn't find wormhole at Sector:"
				            				+ l_explorer.sector.row.out + ":" + l_explorer.sector.column.out    )
				    else
				    	model.wormhole (l_explorer)
				    end
				end
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
