note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PLAY
inherit
	ETF_PLAY_INTERFACE
create
	make
feature -- command
	play
    	do
			if model.game.in_game then
				model.report_error ("%N  To start a new mission, please abort the current one first.")
			else
				model.play
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
