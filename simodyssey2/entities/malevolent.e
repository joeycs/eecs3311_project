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
			out,
			set_death_message
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
			create destroys_this_turn.make
		end

feature -- Attributes

	newest_attack: detachable ENTITY
	attacked_this_turn: BOOLEAN

feature -- Commands

	set_behaviour (first_behave: BOOLEAN; rng_usage: LINKED_LIST [STRING])
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
						newest_attack := l_explorer
						attacked_this_turn := True
					end
					if l_explorer.dead then
						l_explorer.set_death_message (  " got lost in space - out of life support at Sector:"
										               + sector.row.out + ":" + sector.column.out)
					end
				end
			end

			turns_left := gen.rchoose (0, 2)
			rng_usage.extend ("(M->" + turns_left.out + ":[0,2]),")
		end

	set_death_message (msg: STRING)
		do
			Precursor ("Malevolent" + msg)
		end

	reset_attacked_this_turn
		do
			attacked_this_turn := False
		end

feature -- Queries

	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
				           + "fuel:" + fuel.out + "/" + max_fuel.out + ", "
				           + "actions_left_until_reproduction:" + actions_left_until_reproduction.out + "/" + reproduction_interval.out
				           + ", " + "turns_left:")
			if is_dead then
				Result.append ("N/A")
			else
				Result.append (turns_left.out)
			end
		end
end
