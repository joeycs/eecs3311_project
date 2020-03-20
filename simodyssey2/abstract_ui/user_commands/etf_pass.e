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
    	do
    		if not model.game.in_game then
				model.report_error ("%N  Negative on that request:no mission in progress.")
			else
				model.pass
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
