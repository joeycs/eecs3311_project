note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LAND
inherit
	ETF_LAND_INTERFACE
create
	make
feature -- command
	land
		local
			l_entity : ENTITY
			l_explorer : EXPLORER
			l_yellow_dwarf : detachable YELLOW_DWARF
			l_planet : detachable PLANET
			l_unvisited_attached_planet : detachable PLANET
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
			    			if attached {YELLOW_DWARF} entity2 as yd then
			    				l_yellow_dwarf := yd
							elseif attached {PLANET} entity2 as p then
								l_planet := p
								if p.is_attached and (not p.visited) then
									l_unvisited_attached_planet := p
								end
			    			end
		    			end

		    		end
		    	end

				check attached l_explorer then
					if l_explorer.landed then
				        model.report_error (  "%N  Negative on that request:already landed on a planet at Sector:"
				            				  + l_explorer.sector.row.out + ":" + l_explorer.sector.column.out    )
					elseif not attached l_yellow_dwarf then
						model.report_error (  "%N  Negative on that request:no yellow dwarf at Sector:"
				            				  + l_explorer.sector.row.out + ":" + l_explorer.sector.column.out    )
					elseif not attached l_planet then
						model.report_error (  "%N  Negative on that request:no planets at Sector:"
				            				  + l_explorer.sector.row.out + ":" + l_explorer.sector.column.out    )
					elseif not attached l_unvisited_attached_planet then
						model.report_error (  "%N  Negative on that request:no unvisited attached planet at Sector:"
				            				  + l_explorer.sector.row.out + ":" + l_explorer.sector.column.out    )
					else
						if l_unvisited_attached_planet.supports_life then
							model.land (l_explorer, "%N  Tranquility base here - we've got a life!")
							model.win_game
						else
							model.land (l_explorer, ("%N  Explorer found no life as we know it at Sector:"
				            				          + l_explorer.sector.row.out + ":" + l_explorer.sector.column.out))
						end
					end
				end
			end

			etf_cmd_container.on_change.notify ([Current])
    	end

end
