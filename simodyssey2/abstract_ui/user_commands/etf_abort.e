note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ABORT
inherit
	ETF_ABORT_INTERFACE
create
	make
feature -- command
	abort
    	do
			if not model.game.in_game then
				model.report_error ("%N  Negative on that request:no mission in progress.")
			else
				model.abort
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
