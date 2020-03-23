note
	description: "Summary description for {MALEVOLENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MALEVOLENT

inherit
	SENTIENT_ENTITY
		redefine
			out
		end

	CPU_ENTITY
		undefine
			set_sector,
			out
		end

	REPRODUCING_ENTITY
		undefine
			set_sector,
			out
		end

create
	make

feature {NONE} -- Initialization

	make (s: SECTOR; next_movable_id: INTEGER)
			-- Initialization for `Current'.
		do
			create death_message.make_empty
			create sector.make_dummy
			create char.make ('M')
			ID := next_movable_ID
			sector := s
			dead := false
			fuel := max_fuel
			actions_left_until_reproduction := reproduction_interval
		end

feature -- Commands

	set_behaviour (first_behave: BOOLEAN)
		local
			l_explorer: detachable EXPLORER
			l_benign: detachable BENIGN
		do
			if not first_behave then
				across sector.contents is l_entity loop
					if attached {EXPLORER} l_entity as e then
						l_explorer := e
					end
					if attached {BENIGN} l_entity as b then
						l_benign := b
					end
				end

				if attached l_explorer and not attached l_benign then
					if not l_explorer.landed then
						l_explorer.decrement_life
					end
				end
			end

			turns_left := gen.rchoose (0, 2)
		end

	set_death_message (msg: STRING)
		do

		end

feature -- Queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
				           + "fuel:" + fuel.out + "/" + max_fuel.out + ", "
				           + "actions_left_until_reproduction:" + actions_left_until_reproduction.out + "/" + reproduction_interval.out
				           + ", " + "turns_left:" + turns_left.out)
		end
end
