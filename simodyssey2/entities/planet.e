note
	description: "Summary description for {PLANET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PLANET

inherit
	MOVABLE_ENTITY
		redefine
			ID,
			out
		end

	CPU_ENTITY
		undefine
			ID,
			set_sector,
			out
		end

create
	make

feature -- attributes

	is_attached: BOOLEAN
	supports_life: BOOLEAN
	visited: BOOLEAN
	ID: INTEGER

feature {NONE} -- Initialization

	make (s : SECTOR; next_movable_id : INTEGER)
			-- Initialization for `Current'.
		do
			sector := s
			ID := next_movable_id
			is_attached := False
			supports_life := False
			visited := False
			dead := False
			create char.make ('P')
			create death_message.make_empty
		end

feature -- commands

set_attached
	do
		is_attached := true
		if (turns_left = 0) then
			turns_left := -1
		end
	end

set_supports_life
	do
		supports_life := true
	end

set_visited
	do
		visited := true
	end

set_behaviour (first_behave: BOOLEAN)
	local
		num: INTEGER
	do
		across sector.contents is entity loop
			if attached {STAR} entity as star then
				set_attached
				if attached {YELLOW_DWARF} star as yd then
					num := gen.rchoose (1, 2)
					if num = 2 then
						set_supports_life
					end
				end
			end
		end

		if not is_attached or first_behave then
			turns_left := gen.rchoose (0, 2)
		end
	end

set_death_message (msg: STRING)
	do
		death_message.make_from_string ("Planet" + msg)
	end

feature -- queries
	out: STRING
		do
			create Result.make_from_string ("  ")
			Result.append (  "[" + ID.out + "," + char.out + "]" + "->"
			               + "attached?:" + is_attached.out.substring (1, 1)+ ", "
			               + "support_life?:" + supports_life.out.substring (1, 1) + ", "
			               + "visited?:" + visited.out.substring (1, 1) + ", "
			               + "turns_left:")
			if is_attached or is_dead then
				Result.append ("N/A")
			else
				Result.append (turns_left.out)
			end
		end

end
