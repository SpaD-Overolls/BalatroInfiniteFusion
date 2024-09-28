SMODS.InfiniFusion {
	-- required arguments
	key = 'example',
	contents = {
		-- must consist of at least 2 keys
		-- the order of the jokers doesn't matter
		'j_joker', 'j_joker'
	},
	
	-- everything else is optional
	atlas = 'joker',
	pos = {x = 0, y = 0},
	
	soul_atlas = 'exm_joker', -- IMPORTANT: soul_atlas requires raw key (with the mod prefix)
	soul_pos = {x = 1, y = 0},-- if fusion doesn't have soul_atlas or soul_pos, then it hides the floating sprite
	
	set_sprites = function(self, card, front)
		-- exactly the same as SMODS.Center counterpart
	end,
	
	no_info_queue = nil, -- set to true if you want to hide the subjoker info_queue
	
	loc_txt = {
		-- same as a normal joker's loc_txt
		-- in localization files, fusion texts are located
		-- at descriptions.Joker to allow InfiniFusion easy access to them
		
		-- but unlike jokers, fusions' object prefix is 'if'
		
		--     this fusion would be at
		-- G.localization.descriptions.Joker.if_exm_example
	},
	
	loc_vars = function(self, info_queue, card, subjokers)
		-- similar to SMODS.Center counterpart
		-- subjokers is the table of subjoker data
		-- each entry is similar to loc_vars output, but also contains extra data
		-- -- subjoker extra data:
		-- -- -- original_key = the key of the subjoker's center
		-- -- -- set = the set of subjoker's center (just in case)
		
		-- info_queue returned from this function is appended
		-- after all of the subjokers
	end,
	
	set_card_type_badge = function(self, card, badges)
		-- exactly the same as SMODS.Center counterpart
	end,
	
	
}