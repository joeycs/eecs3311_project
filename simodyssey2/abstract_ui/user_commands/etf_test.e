note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_TEST
inherit
	ETF_TEST_INTERFACE
create
	make
feature -- command
	test(a_threshold, j_threshold, m_threshold, b_threshold, p_threshold: INTEGER_32)
		require else
			test_precond(a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
    	do
			if model.game.in_game then
				model.report_error ("%N  To start a new mission, please abort the current one first.")
			else
				model.test(p_threshold)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
