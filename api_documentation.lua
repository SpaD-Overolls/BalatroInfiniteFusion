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
		-- exactly the same as SMODS.Center
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
		-- exactly the same as SMODS.Center
	end,
	
	update = function(self, card, dt)
		-- exactly the same as SMODS.Center
	end,
	
	-- set this to true if you don't want
	-- find_card to search through the subjokers
	-- of this fusion
	disable_find_card = nil,
	
	-- set this to true to disable the use button
	-- for fusions that would otherwise have a use button
	no_use = nil,
	
	-----------------------------------------------------
	--	BEHAVIOUR CHANGES
	-----------------------------------------------------
	-- WARNING: once you change any of these, the InfiniFusion stops calculating using its subjokers
	
	-- set to a valid Joker key if you want this Fusion to create a different Joker instead
	-- the intent of this feature is to register Fusion Jokers from
	-- other mods to create them using InfiniFusion Fusion System
	joker = nil, 
	
	config = {
		-- same as SMODS.Joker
	},
	
	set_ability = function(self, card, initial, delay_sprites)
		-- same as SMODS.Joker
	end,
	
	add_to_deck = function(self, card, from_debuff)
		-- same as SMODS.Joker
	end,
	
	remove_from_deck = function(self, card, from_debuff)
		-- same as SMODS.Joker
	end,
	
	calculate = function(self, card, context)
		-- same as SMODS.Joker
		-- -- except incompatible with Blueprint for consistency
	end,
	
	calc_dollar_bonus = function(self, card)
		-- same as SMODS.Joker
	end,
	
	-- NOTICE: setting any of these will add a Use button to your InfiniFusion
	use = function(self, card, area, copier)
		-- same as SMODS.Consumable
	end,
	
	can_use = function(self, card)
		-- same as SMODS.Consumable
	end,
	
	keep_on_use = function(self, card)
		-- same as SMODS.Consumable
	end,
	
	redeem = function(self)
		-- same as SMODS.Voucher
	end
	
}

-- New features for SMODS.Joker
SMODS.Joker {
	-- Prevent InfiniFusion from fusing this Joker
	-- Use this if InfiniFusion is incompatible with the Joker
	-- and the incompatibility cannot be resolved by tweaking the Joker
	infinifusion_incompat = nil, -- set to true
	
	-- Set this to an InfiniFusion key
	-- if you want this Joker to be treated as
	-- that InfiniFusion for purposes of further Fusion/Unfusion
	infinifusion = nil, -- gets set automatically if an InfiniFusion claims this Joker
	-- You may input an invalid key if you don't want InfiniFusions changing this value automatically
}

-----------------------------
--
--      DebugPlus
--
----------------------------

-- /infuse
-- -- -- Spawn a natural InfiniFusion (2 random Jokers)

-- /infuse all
-- -- -- Fuse all currently owned Jokers.

-- /infuse <InfiniFusion key>
-- -- -- Spawn the InfiniFusion with this key

-- /infuse <argument> <argument>
-- -- -- Fuse the Jokers from specified arguments
-- -- -- -- (can be any amount of arguments as long as at least 2 of them are valid)
-- --
-- -- -- -- Valid arguments:
-- -- -- -- -- InfiniFusion key
-- -- -- -- (for example if_fuze_collector)
-- -- -- Add the contents of this InfiniFusion into the contents of the created InfiniFusion
-- -- --
-- -- -- -- -- Joker key
-- -- -- -- (for example j_joker)
-- -- -- Add this Joker into the contents of the created InfiniFusion
-- -- --
-- -- -- -- -- Numbers
-- -- -- Add the Joker from the corresponding Joker slot into the contents of the created InfiniFusion
-- -- -- (The Joker specified this way will be fused into the resulting InfiniFusion, removing the original copy)

-- /defuse
-- -- -- Split the leftmost InfiniFusion into its components