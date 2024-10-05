--- STEAMODDED HEADER
--- MOD_NAME: Infinite Fusion
--- MOD_ID: InfiniteFusion
--- MOD_AUTHOR: [SpaD_Overolls, humplydinkle]
--- MOD_DESCRIPTION: Fuse any Jokers!
--- PREFIX: infus
--- VERSION: 0.0.6b

-- using a placeholder sprite by humplydinkle

InfiniteFusion = SMODS.current_mod
InfiniteFusion.debugplus = false
InfiniteFusion.badge_colour = HEX('de2323')

InfiniteFusion.incompatible_jokers = {
	'j_cry_equilib' -- [Cryptid] Ace Aequilibrium
}

SMODS.Joker {
	key = 'fused',
	pos = {x = 9, y = 9},
	soul_pos = {x = 5, y = 3},
	omit = true,
	rarity = 3,
	set_ability = function(self, card, initial, delay_sprites)
		local natural = nil
		if not card.infinifusion then 
			card.infinifusion = generate_random_infinifusion(2) 
			natural = true
		end
		
		if self.has_behaviour(card) then
			local api = card.infinifusion_api
			if api.config and type(api.config) == 'table' then 
				for k, v in pairs(api.config) do
					card.ability[k] = type(v) == 'table' and copy_table(v) or v
				end
			end
			if api.set_ability and type(api.set_ability) == 'function' then
				api.set_ability(self, card, initial, delay_sprites)
			end
		end
		
		if natural then card.ability.natural_infinifusion = true end
		infinifusion_init_ability(card)
		
		card.config.center = G.P_CENTERS['j_infus_fused']
		self.set_sprites(self, card, front)
	end,
	has_behaviour = function(card)
		if not card.infinifusion_api then return nil 
		else
			local api = card.infinifusion_api
			if api.config and type(api.config) == 'table' then return true end
			if api.set_ability and type(api.set_ability) == 'function' then return true end
			if api.calculate and type(api.calculate) == 'function' then return true end
			if api.add_to_deck and type(api.add_to_deck) == 'function' then return true end
			if api.remove_from_deck and type(api.remove_from_deck) == 'function' then return true end
			if api.calc_dollar_bonus and type(api.calc_dollar_bonus) == 'function' then return true end
		end
		return nil
	end,
	set_sprites = function(self, card, front)
		if not card.infinifusion then return nil end
		infinifusion_check_fusion(card)
		local atlas = G.ASSET_ATLAS["Joker"]
		local soul_atlas = G.ASSET_ATLAS["centers"]
		local pos = self.pos
		local soul_pos = self.soul_pos
		local set_sprites = nil
		
		local has_soul = true
		
		-- InfiniFusion API
		if card.infinifusion_api then
			local fus = card.infinifusion_api
			if (fus.atlas and G.ASSET_ATLAS[fus.atlas]) or fus.pos then
				atlas = G.ASSET_ATLAS[fus.atlas] or G.ASSET_ATLAS["Joker"]
				pos = fus.pos or {x = 0, y = 0}
			end
			
			if not fus.soul_pos and not fus.soul_atlas then
				soul_pos = {x = -2, y = -2}
			else
				soul_pos = fus.soul_pos or {x = 1, y = 1}
				soul_atlas = G.ASSET_ATLAS[fus.soul_atlas] or atlas
			end
			
			if fus.set_sprites and type(fus.set_sprites) == 'function' then
				set_sprites = fus.set_sprites
			end
		end
		
		if not card.infinifusion_api or (card.infinifusion_api 
		and not ((card.infinifusion_api.atlas and G.ASSET_ATLAS[card.infinifusion_api.atlas]) or card.infinifusion_api.pos) 
		or (card.infinifusion_api.set_sprites and type(card.infinifusion_api.set_sprites) == 'function')) then -- Procedural generation
			local same_check = card.infinifusion[1].key
			local wee = nil
			local square = nil
			for i = 1, #card.infinifusion do
				if card.infinifusion[i].key ~= same_check then
					same_check = nil
				end
				
				if card.infinifusion[i].key == 'j_wee' then wee = true end
				if card.infinifusion[i].key == 'j_square' then square = true end
			end
			
			if same_check then
				atlas = G.ASSET_ATLAS[G.P_CENTERS[same_check]] or G.ASSET_ATLAS["Joker"]
				soul_atlas = atlas
				pos = G.P_CENTERS[same_check].pos or {x = 0, y = 0}
				soul_pos = G.P_CENTERS[same_check].soul_pos or {x = -2, y = -2}
			end
			local args = {same_check = same_check, wee = wee, square = square}
			set_sprites = function(self, card, front)
				local H = G.CARD_H
				local W = G.CARD_W
				local scale = args.wee and 0.7 or 1
				if args.same_check then
					local same_center = G.P_CENTERS[same_check]
					if same_center.set_sprites and type(same_center.set_sprites) == 'function' then
						card.config.center = same_center
						card.ability = card.infinifusion[1].ability
						same_center.set_sprites(same_center, card, front)
						card.config.center = G.P_CENTERS['j_infus_fused']
						card.ability = card.ability_placeholder
						return nil
					end
					
					if same_check == 'j_half' then
						H = H/1.7
					end
					
					if same_check == 'j_photograph' then
						H = H/1.2
					end
				end
				
				if args.square then
					H = W
				end
				
				-- TODO: Fix floating_sprite resize
				-- square looks ok enough for me to not do this to it
				if args.wee then
					card.children.floating_sprite:set_sprite_pos({x = -2, y = -2})
				end
				
				card.T.h = H*scale
				card.T.w = W*scale
				
				card.VT.h = card.T.h
				card.VT.w = card.T.w
				
				if args.same_check then
					if args.square then
						card.children.center.scale.y = card.children.center.scale.x
					end
					
					if same_check == 'j_half' then
						card.children.center.scale.y = card.children.center.scale.y/1.7
					end
					
					if same_check == 'j_photograph' then
						card.children.center.scale.y = card.children.center.scale.y/1.2
					end
				end
			end
		end
		
		card.children.center.atlas = atlas
		card.children.center:set_sprite_pos(pos)
		card.children.floating_sprite.atlas = soul_atlas
		card.children.floating_sprite:set_sprite_pos(soul_pos)
		
		if set_sprites then set_sprites(card.infinifusion_api or self, card, front) end
	end,
	load = function(self, card, card_table, other_card)
		calculate_infinifusion(card, nil, function(i)
			if G.P_CENTERS[card.infinifusion[i].key].load then
				G.P_CENTERS[card.infinifusion[i].key].load(G.P_CENTERS[card.infinifusion[i].key], card, card_table, other_card)
			end
		end)
	end,
	add_to_deck = function(self, card, from_debuff)
		if not self.has_behaviour(card) then
			calculate_infinifusion(card, {no_edition = true}, function(i)
				card.added_to_deck = nil
				card:add_to_deck(from_debuff)
			end)
			
			card.added_to_deck = true
		else
			local api = card.infinifusion_api
			if api.add_to_deck and type(api.add_to_deck) == 'function' then
				api.add_to_deck(self, card, from_debuff)
			end
			infinifusion_sync_ability(card)
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not self.has_behaviour(card) then
			calculate_infinifusion(card, {no_edition = true}, function(i)
				card.added_to_deck = true
				card:remove_from_deck(from_debuff)
			end)
			card.added_to_deck = false
		else
			local api = card.infinifusion_api
			if api.remove_from_deck and type(api.remove_from_deck) == 'function' then
				api.remove_from_deck(self, card, from_debuff)
			end
			infinifusion_sync_ability(card)
		end
	end,
	
	update = function(self, card, dt)
	end,
	
	calculate = function(self, card, context)
		if not context.blueprint then
			if not self.has_behaviour(card) then
				local global_ret = nil
				local current_joker = nil
				local restore_func = function(i)
					if current_joker then
						card.config.center = G.P_CENTERS[current_joker.key]
						card.ability = current_joker.ability
					end
				end
				
				if not context.joker_retrigger then -- fusion mustn't retrigger itself
					calculate_infinifusion(card, nil, function(i)
						-- cryptid doublescale compat
						local original_cry_doublescale = nil
						if Card.cry_double_scale_calc then
							original_cry_doublescale = G.GAME.cry_double_scale[card.sort_id]
							if not card.infinifusion[i].cry_double_scale then
								G.GAME.cry_double_scale[card.sort_id] = nil
							else
								G.GAME.cry_double_scale[card.sort_id] = card.infinifusion[i].cry_double_scale
							end
						end
						
						local ret = card:calculate_joker(context)
						-- sixth sense edgecase
						if context.destroying_card and not context.blueprint then
							global_ret = ret
						end
						
						-- cryptid doublescale compat
						if Card.cry_double_scale_calc then
							card.infinifusion[i].cry_double_scale = G.GAME.cry_double_scale[card.sort_id]
							G.GAME.cry_double_scale[card.sort_id] = original_cry_doublescale
						end
					end,
					-- precalc_func
					function(i)
						if card.config.center ~= G.P_CENTERS['j_infus_fused'] and not current_joker then
							current_joker = {
								key = card.config.center.key,
								ability = copy_table(card.ability)
							}
						end
					end,
					-- postcalc_func 
					restore_func(i), restore_func(i))
				end
				
				if global_ret then return global_ret end
			else
				local api = card.infinifusion_api
				local ret = nil
				if api.calculate and type(api.calculate) == 'function' then
					ret = api.calculate(self, card, context)
				end
				infinifusion_sync_ability(card)
				
				-- cryptid doublescale compat
				calculate_infinifusion(card, nil, function(i)
					local original_cry_doublescale = nil
					if Card.cry_double_scale_calc then
						original_cry_doublescale = G.GAME.cry_double_scale[card.sort_id]
						if not card.infinifusion[i].cry_double_scale then
							G.GAME.cry_double_scale[card.sort_id] = nil
						else
							G.GAME.cry_double_scale[card.sort_id] = card.infinifusion[i].cry_double_scale
						end
						
						card:doublescale_scale_calc(orig_ability, in_context_scaling)
						
						card.infinifusion[i].cry_double_scale = G.GAME.cry_double_scale[card.sort_id]
						G.GAME.cry_double_scale[card.sort_id] = original_cry_doublescale
					end
				end)
			
				return ret
			end
		end
	end,
	
	calc_dollar_bonus = function(self, card)
		if not self.has_behaviour(card) then
			local global_ret = 0
			calculate_infinifusion(card, nil, function(i)
				global_ret = global_ret + (card:calculate_dollar_bonus() or 0)
			end)
			if global_ret ~= 0 then
				return global_ret
			end
		else
			local api = card.infinifusion_api
			local ret = nil
			if api.calc_dollar_bonus and type(api.calc_dollar_bonus) == 'function' then
				ret = api.calc_dollar_bonus(self,card)
			end
			infinifusion_sync_ability(card)
			return ret
		end
	end,
	
	-- non-calc functions
	set_card_type_badge = function(self, card, badges)
		if card.infinifusion_api then
			local fus = card.infinifusion_api
			if fus.set_card_type_badge and type(fus.set_card_type_badge) == 'function' then 
				fus.set_card_type_badge(fus, card, badges)
			end
		end
		if card.ability_placeholder.natural_infinifusion then
			badges[#badges+1] = create_badge(localize('k_rare'), G.C.RARITY[self.rarity], nil, 1.2)
		end
	end,
	loc_vars = function(self, info_queue, card)
		local loc_vars = infinifusion_loc_vars(card)
		local ret = {}
		infinifusion_check_fusion(card)
		
		local show_info_queue = true
		local api_info_queue = {}
		-- InfiniFusion API
		if card.infinifusion_api then
			local fus = card.infinifusion_api
			-- Hide infinifusion's subjoker info_queue
			if fus.no_info_queue then show_info_queue = false end
			
			-- Custom loc_txt
			if G.localization.descriptions.Joker[fus.key] then
				-- Fix up missing name/description (needs testing)
				if not G.localization.descriptions.Joker[fus.key].name then
					G.localization.descriptions.Joker[fus.key].name = G.localization.descriptions.Joker["j_infus_fused"].name
					G.localization.descriptions.Joker[fus.key].name_parsed = G.localization.descriptions.Joker["j_infus_fused"].name_parsed
				end
				
				if not G.localization.descriptions.Joker[fus.key].text then
					G.localization.descriptions.Joker[fus.key].text = G.localization.descriptions.Joker["j_infus_fused"].text
					G.localization.descriptions.Joker[fus.key].text_parsed = G.localization.descriptions.Joker["j_infus_fused"].text_parsed
				end
				
				-- set the ret key to the fusion's key
				ret.key = fus.key
			end
			
			-- Custom loc_vars
			if fus.loc_vars and type(fus.loc_vars) == 'function' then
				local fus_vars = fus.loc_vars(fus, api_info_queue, card, loc_vars)
				for k, v in pairs(fus_vars) do
					ret[k] = v
				end
			end
		end
		-- Subjoker info_queue
		if show_info_queue then
			for i = 1, #loc_vars do
				info_queue[#info_queue+1] = {key = loc_vars[i].key, set = loc_vars[i].set, specific_vars = loc_vars[i].vars}
			end
		end
		
		-- Fusion API info_queue (tacked on the end bcos subjokers are more important)
		for i = 1, #api_info_queue do
			info_queue[#info_queue+1] = api_info_queue[i]
		end
		
		card.ability = card.ability_placeholder
		card.config.center = G.P_CENTERS['j_infus_fused']
		return ret
	end,
	inject = function(self)
		G.P_CENTERS[self.key] = self -- bypass normal injection (to not create a G.CENTER_POOLS.Joker entry)
		SMODS.insert_pool(G.P_JOKER_RARITY_POOLS[self.rarity], self)
	end,
	can_use = function(self, card)
		if not card.ability_placeholder.consumeable then return nil end
		local can_use_fus = nil
		-- TODO: write custom behavior api for this
		calculate_infinifusion(card, nil, function(i)
			card:update(dt) -- needed for certain consumeables
			local _can_use = card:can_use_consumeable()
			if _can_use then can_use_fus = true end
			card.infinifusion[i].can_use = _can_use
		end)
		return can_use_fus
	end,
	use = function(self, card, area, copier)
		if not card.ability_placeholder.consumeable then return nil end
		local backup = G.GAME.last_tarot_planet
		local highlighted = {}
		for i = 1, #G.hand.highlighted do
			highlighted[#highlighted+1] = G.hand.highlighted[i]
		end
		calculate_infinifusion(card, nil, function(i)
			card.infinifusion[i].use_events = {}
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0, func = function()
				card.ability = card.infinifusion[i].ability
				card.config.center = G.P_CENTERS[card.infinifusion[i].key]
				if #highlighted ~= 0 then
					G.hand.highlighted = {}
					for _, v in pairs(highlighted) do
						v.highlighted = true
						G.hand.highlighted[#G.hand.highlighted+1] = v
					end
				end
				card:update(dt)
				local _state = G.STATE
				G.STATE = G.STATES.SELECTING_HAND
				local sanity = card:can_use_consumeable(true, true)
				G.STATE = _state
				card.config.center = G.P_CENTERS['j_infus_fused']
				if not sanity then
					for k, v in pairs(card.infinifusion[i].use_events) do
						v.func = function() return true end
						v.delay = 0
					end
				end
				
				return true end }))
			local place = #G.E_MANAGER.queues.base+1
			card:use_consumeable(area, copier)
			delay(0.2)
			
			card.infinifusion[i].use_events[i] = {}
			for ii = place, #G.E_MANAGER.queues.base do
				local iii = #card.infinifusion[i].use_events+1
				card.infinifusion[i].use_events[iii] = G.E_MANAGER.queues.base[ii]
			end
		end, nil, nil,
			function(i)
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0, func = function()
					card.ability = card.ability_placeholder
					card.config.center = G.P_CENTERS['j_infus_fused']
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
						G.GAME.STOP_USE = 0
						G.GAME.last_tarot_planet = backup
						return true end }))
					return true end }))
			end)
	end,
	keep_on_use = function(self, card)
		return nil
	end,
	in_pool = function(self)
		return true, {allow_duplicates = true}
	end
}

-- [InfiniFusion API Object]
-- This API is used to replace InfiniFusion's loc_txt/sprite
-- with a custom one, with the intention to allow other mods
-- to add their custom looks/names/descriptions to specific InfiniFusions

SMODS.InfiniFusions = {}
SMODS.InfiniFusion = SMODS.GameObject:extend {
	obj_table = SMODS.InfiniFusions,
	obj_buffer = {},
	set = 'InfiniFusion',
	class_prefix = 'if',
	discovered = false,
	required_params = {
		'key',
		'contents' -- a table containing the keys of all jokers
	},				-- that make up the fusion, in any order.
	pre_inject_class = function(self)
		G.INFINIFUSIONS = {}
		G.INFINIFUSION_POOLS = {}
	end,
	inject = function(self)
		if self.contents and type(self.contents) == 'table' and #self.contents >= 2 then
			local valid = true
			
			for i = 1, #self.contents do
				if not G.P_CENTERS[self.contents[i]] or unfusable(G.P_CENTERS[self.contents[i]]) then
					valid = false
				end
			end
			
			if valid then
				G.INFINIFUSIONS[self.key] = self		
				if not G.INFINIFUSION_POOLS[#self.contents] then G.INFINIFUSION_POOLS[#self.contents] = {} end
				table.insert(G.INFINIFUSION_POOLS[#self.contents], self)
				
				if self.joker and G.P_CENTERS[self.joker] and not G.P_CENTERS[self.joker].infinifusion then
					G.P_CENTERS[self.joker].infinifusion = self.key
				end
			else print('[Invalid Fusion] - '..self.key.." - contains incompatible/nonexistent Jokers") end
		else print("[Invalid Fusion] - "..self.key.." - self.contents must be a table of 2 or more elements") end
	end,
	post_inject_class = function(self)
		table.sort(G.INFINIFUSIONS, function(a, b)
			local a_order = a.order or #G.INFINIFUSIONS
			local b_order = b.order or (#G.INFINIFUSIONS + 1)
			return a_order < b_order 
		end)
	end,
	process_loc_text = function(self)
		if self.loc_txt then
			-- doing process_loc_text as Joker because thats needed to use loc_vars' key
			SMODS.process_loc_text(G.localization.descriptions.Joker, self.key, self.loc_txt)
		end
	end,
}

function infinifusion_find_fusion(contents)
	if not contents then return nil end
	if type(contents) ~= 'table' then return nil end
	if #contents < 2 then return nil end
	if not G.INFINIFUSION_POOLS[#contents] then return nil end
	
	for i = 1, #G.INFINIFUSION_POOLS[#contents] do
		-- sort both tables in the same way
		local my_contents = copy_table(contents)
		table.sort(my_contents, function(a, b) return a:lower() < b:lower() end)
		local their_contents = copy_table(G.INFINIFUSION_POOLS[#contents][i].contents)
		table.sort(their_contents, function(a, b) return a:lower() < b:lower() end)
		
		local success = true
		for ii = 1, #contents do -- check if they match up
			if my_contents[ii] ~= their_contents[ii] then
				success = nil
				break
			end
		end
		
		if success then return G.INFINIFUSION_POOLS[#contents][i] end
	end
	
	return nil
end

function infinifusion_check_fusion(card)
	if not card then return nil end
	if not card.infinifusion then return nil end
	if not card.infinifusion_api_checked then
		local contents = {}
		for i = 1, #card.infinifusion do
			contents[i] = card.infinifusion[i].key
		end
		local result = infinifusion_find_fusion(contents)
		card.infinifusion_api = result
		card.infinifusion_api_checked = true
	end
end

-- [The Experiment]
-- This is the Spectral card
-- currently used to fuse Jokers

SMODS.Atlas {
	key = 'experiment',
	path = 'experiment.png',
	px = 71,
	py = 95
}

SMODS.Consumable {
	key = 'experiment',
	set = 'Spectral',
	atlas = 'experiment',
	discovered = true,
	can_use = function(self, card)
		if G.jokers and G.jokers.cards and #G.jokers.cards >= 2 then
			if not unfusable(G.jokers.cards[1].config.center) and
			not unfusable(G.jokers.cards[#G.jokers.cards].config.center) then
				return true
			end
		end
		return false
	end,
	use = function(self, card, area, copier)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
			local new_card = create_infinifusion{contents = {G.jokers.cards[1], G.jokers.cards[#G.jokers.cards]}}
			G.jokers:emplace(new_card)
			new_card:add_to_deck()
			new_card:juice_up()
			--infinifusion_fuse_cards({G.jokers.cards[1], G.jokers.cards[#G.jokers.cards]})
            return true end }))
	end
}

-- other functions --
function generate_random_infinifusion(num)
	num = num or 2
	if num < 2 then num = 2 end
	local pool = {}
	local final_ability = {}
	for k, v in ipairs(G.P_CENTER_POOLS.Joker) do
		if v.unlocked and not v.infinifusion and not unfusable(v) then
			local in_pool, pool_opts
			local pool_flags = nil
			local in_pool_exists, pool_flags_exist
			
			if v.in_pool and type(v.in_pool) == 'function' then
				in_pool, pool_opts = v:in_pool()
				in_pool_exists = true
			end
			
			if v.no_pool_flag and G.GAME.pool_flags[v.no_pool_flag] then pool_flags = nil end
			if v.yes_pool_flag and not G.GAME.pool_flags[v.yes_pool_flag] then pool_flags = nil end
			if v.no_pool_flag or v.yes_pool_flag then pool_flags_exist = true end
			
			if in_pool or pool_flags or (not in_pool_exists and not pool_flags_exist) then
				if not G.GAME.used_jokers[v.key] or (pool_opts and pool_opts.allow_duplicates) or next(SMODS.find_card('j_ring_master')) then
					pool[#pool + 1] = v
				end
			end
		end
	end
	
	for i = 1, num do
		final_ability[#final_ability+1] = {key = pseudorandom_element(pool, pseudoseed('fusion')).key}
	end
	
	for k, v in pairs(final_ability) do
		if not v.key then v.key = 'j_joker' end
	end
	
	if #final_ability < 2 then return {{key = 'j_joker'}, {key = 'j_joker'}} end
	
	return final_ability
end

function calculate_infinifusion(card, context, calc_func, precalc_func, postcalc_func, finalcalc_func)
	context = context or {}
	if context.no_edition and card.edition then
		card.infus_editions = card.edition and copy_table(card.edition)
		card:set_edition(nil, true, true)
	end
	
	for i = 1, #card.infinifusion do
		if precalc_func and type(precalc_func) == 'function' then precalc_func(i) end
		card.ability = card.infinifusion[i].ability
		card.config.center = G.P_CENTERS[card.infinifusion[i].key]
		if calc_func and type(calc_func) == 'function' then calc_func(i) end
		card.infinifusion[i].ability = card.ability
		if postcalc_func and type(postcalc_func) == 'function' then postcalc_func(i) end
	end
	
	if not context.no_sync then
		infinifusion_sync_ability(card)
	end
	card.ability = card.ability_placeholder
	card.config.center = card.infinifusion_center or G.P_CENTERS['j_infus_fused']
	
	if context.no_edition and card.infus_editions then
		card:set_edition(card.infus_editions, true, true)
		card.infus_editions = nil
	end
	if finalcalc_func and type(finalcalc_func) == 'function' then finalcalc_func(i) end
end

function infinifusion_sync_handle_value(card, keys, final_table)
	for i = 1, #keys do
		local k = keys[i]
		for ii = 1, #card.infinifusion do
			if card.infinifusion[ii].ability[k] then
				if k == 'perish_tally' then
					if not final_table[k] then final_table[k] = G.GAME.perishable_rounds end
					final_table[k] = math.min(final_table[k] or G.GAME.perishable_rounds, card.infinifusion[ii].ability[k])
				elseif type(card.infinifusion[ii].ability[k]) == 'boolean' and not card.infinifusion[ii].ability[k] == false then
					final_table[k] = card.infinifusion[ii].ability[k]
				else
					if not final_table[k] then final_table[k] = 0 end
					final_table[k] = final_table[k] + card.infinifusion[ii].ability[k]
				end
			end
		end
	end
end

function infinifusion_sync_ability(card)
	local keys = {'extra_value', 'perish_tally'}
	local final_table = {}
	
	infinifusion_sync_handle_value(card, keys, final_table)
	
	for k, v in pairs(final_table) do
		card.ability_placeholder[k] = v
	end
	
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0, blockable = false,
		func = function()
			card:set_cost()
		return true; end})) 
end

function infinifusion_init_ability(card)
	card.ability_placeholder = card.ability
	for i = 1, #card.infinifusion do
		if not card.infinifusion[i].ability then
			card.config.center = nil
			card.ability = nil
			card:set_ability(G.P_CENTERS[card.infinifusion[i].key], initial, delay_sprites)
			card.infinifusion[i].ability = copy_table(card.ability)
		end
	end
		
	card.ability = card.ability_placeholder
	card.config.center = card.infinifusion_center or G.P_CENTERS['j_infus_fused']
	card:set_sprites(card.config.center)
	
	local keys = {'extra_value', 'perish_tally'}
	local stickers = {}
	local sticker_compats = {}
	local final_sticker_compats = {}
	local final_table = {}
	
	for k, v in pairs(SMODS.Stickers) do
		stickers[#stickers+1] = v.key
	end
	
	infinifusion_sync_handle_value(card, keys, final_table)
	infinifusion_sync_handle_value(card, stickers, final_table)
	
	for k, v in pairs(final_table) do
		card.ability_placeholder[k] = v
	end
	
	for k, v in pairs(SMODS.Stickers) do
		if final_table[v.key] then
			sticker_compats[v.key] = {}
			for i = 0, #card.infinifusion do
				local target = i == 0 and {key = card.config.center.key, ability = card.ability} or card.infinifusion[i]
				if target.key ~= 'j_infus_fused' then
					if v.should_apply and type(v.should_apply) == 'function' then
						sticker_compats[v.key][i] = v:should_apply(card, G.P_CENTERS[target.key], G.jokers, true)
					else
						if v.key == 'etertnal' then
							sticker_compats[v.key][i] = G.P_CENTERS[target.key].eternal_compat
						elseif v.key == 'perishable' then
							sticker_compats[v.key][i] = G.P_CENTERS[target.key].perishable_compat
						else
							sticker_compats[v.key][i] = true
						end
					end
				end
			end
		end
	end
	
	for k, v in pairs(sticker_compats) do
		local compat = true
		for i = 1, #card.infinifusion do
			if v[i] ~= true then
				compat = nil
				break
			end
		end
		if compat then
			final_sticker_compats[k] = true
		end
	end
	
	if final_sticker_compats['eternal'] and final_sticker_compats['perishable'] then
		local choice = {'eternal', 'perishable'}
		final_sticker_compats[pseudorandom_element(choice, pseudoseed('fusion'))] = nil
	end
	
	for k, v in pairs(SMODS.Stickers) do
		if final_table[v.key] and not final_sticker_compats[v.key] then
			for i = 0, #card.infinifusion do
				local tbl = i == 0 and card.ability_placeholder or card.infinifusion[i].ability
				tbl[v.key] = nil
			end
		end
	end
	
	card.base_cost = 0
	for i = 1, #card.infinifusion do
		card.base_cost = card.base_cost + (G.P_CENTERS[card.infinifusion[i].key].cost or 1)
	end
	for i = 1, #card.infinifusion do
		if card.infinifusion[i].ability.consumeable then 
			card.ability_placeholder.consumeable = {max_highlighted = 5}
			break
		end
	end
end

function infinifusion_loc_vars(card)
	if not card then return nil end
	local ret = {}
	for i = 1, #card.infinifusion do
		local key = card.infinifusion[i].key
		local set = G.P_CENTERS[key].set
		local loc_vars = {}
		local faux_info_queue = {}
		
		if G.P_CENTERS[key].loc_vars and type(G.P_CENTERS[key].loc_vars) == 'function' then
			card.ability = copy_table(card.infinifusion[i].ability)
			card.config.center = G.P_CENTERS[key]
			loc_vars = G.P_CENTERS[key].loc_vars(G.P_CENTERS[key], faux_info_queue, card)
		else
			loc_vars.vars = infinifusion_vanilla_loc_var(card.infinifusion[i])
			loc_vars.key = card.infinifusion[i].key == 'j_misprint' and 'j_misprint_static' or nil
		end
		
		if not loc_vars or type(loc_vars) ~= 'table' then loc_vars = {} end
		loc_vars.key = loc_vars.key or key
		loc_vars.set = set
		loc_vars.original_key = key
		ret[#ret+1] = loc_vars
	end
	return ret
end

function create_infinifusion(args)
	if not args then return nil end
	local target = nil
	local contents = {}
	local cards = {}
	local infuse_tbl = {}
	local editions = {}
	local new_card = nil
	local force_joker = nil
	local infus_api = nil
	
	if args.key then
		if G.INFINIFUSIONS[args.key] then
			target = G.INFINIFUSIONS[args.key]
			contents = target.contents
			if target.joker and G.P_CENTERS[target.joker] then
				force_joker = G.P_CENTERS[target.joker]
			end
		else
			print("Bad Key - create_infinifusion")
			return nil
		end
	elseif args.target then
		if args.target.joker and G.P_CENTERS[args.target.joker] then
			force_joker = G.P_CENTERS[args.target.joker] 
		end
		target = args.target
		contents = target.contents
	elseif args.contents and type(args.contents) == 'table' then
		if #args.contents > 1 then
			contents = args.contents
			local check_contents = {}
			for i = 1, #contents do
				if type(contents[i]) == "table" then
					if contents[i].config and contents[i].config.center then
						check_contents[i] = contents[i].config.center.key
					end
				else check_contents[i] = contents[i] end
			end
			target = infinifusion_find_fusion(check_contents)
			if target and target.joker and G.P_CENTERS[target.joker] then
				force_joker = G.P_CENTERS[target.joker] 
			end
		else
			print("Not enough contents - create_infinifusion")
			return nil 
		end
	end
	
	-- checking compatibility with infinifusion
	for i = 1, #contents do
		-- if contents is a table
		if type(contents[i]) == 'table' then
			-- if contents is a card
			if contents[i].config and contents[i].config.center then
				local card = contents[i]
				if card.config.center.key == 'j_infus_fused' then
					for ii = 1, #card.infinifusion do
						infuse_tbl[#infuse_tbl + 1] = card.infinifusion[ii]
					end
					cards[#cards+1] = card
				elseif card.config.center.infinifusion and G.INFINIFUSIONS[card.config.center.infinifusion] then
					local infinifusion = G.INFINIFUSIONS[card.config.center.infinifusion]
					for ii = 1, #infinifusion.contents do
						infuse_tbl[#infuse_tbl + 1] = {key = infinifusion.contents[ii]}
					end
					cards[#cards+1] = card
				elseif not unfusable(card.config.center) then
					infuse_tbl[#infuse_tbl + 1] = {
						key = card.config.center.key,
						ability = copy_table(card.ability)
					}
					cards[#cards+1] = card
				end
			-- if contents is infinifusion data
			elseif contents[i].key and not unfusable(contents[i].key) then
				infuse_tbl[#infuse_tbl + 1] = contents[i]
			end
		end
		
		if type(contents[i]) == 'string' and contents[i] ~= 'j_infus_fused' then
			if G.P_CENTERS[contents[i]] and 
			not unfusable(G.P_CENTERS[contents[i]]) then
				infuse_tbl[#infuse_tbl + 1] = {key = contents[i]}
			else print("Bad Joker key - "..contents[i].." - create_infinifusion") end
		end
	end
	-- prevent fusion if there's not enough targets
	if #infuse_tbl < 2 then 
		print("Not enough contents (infuse_tbl) - create_infinifusion")
		return nil 
	end
	
	if args.edition then editions[#editions+1] = args.edition end
	
	for i = 1, #cards do
		editions[#editions+1] = cards[i].edition and copy_table(cards[i].edition)
		
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0, blockable = false,
		func = function()
			cards[i].area:remove_card(cards[i])
			cards[i]:remove_from_deck()
			cards[i]:remove()
			cards[i] = nil
		return true; end})) 
	end
	
	if not force_joker then
		new_card = Card(
			args.X or (G.jokers.T.x + G.jokers.T.w/2), 
			args.Y or G.jokers.T.y, 
			G.CARD_W, G.CARD_H, nil, 
			G.P_CENTERS['j_infus_fused'],{
				bypass_discovery_center = true, 
				infinifusion = infuse_tbl, 
				infus_api = infus_api})
		new_card.edition = pseudorandom_element(editions, pseudoseed('fusion'))
	else 
		new_card = Card(
			args.X or (G.jokers.T.x + G.jokers.T.w/2), 
			args.Y or G.jokers.T.y, 
			G.CARD_W, G.CARD_H, nil, 
			force_joker,{
				bypass_discovery_center = true,
				infinifusion = infuse_tbl,
				infus_api = target})
		new_card.infinifusion_center = force_joker
		new_card.edition = pseudorandom_element(editions, pseudoseed('fusion'))
		infinifusion_init_ability(new_card)
	end
	return new_card
end

function split_infinifusion(card, args)
	if not card then return {} end
	if not card.infinifusion then return {} end
	if not args then args = {total = true} end
	local cards = {}
	local new_tables = {}
	
	if args.total then
		for i = 1, #card.infinifusion do
			new_tables[#new_tables+1] = {card.infinifusion[i]}
		end
	elseif args.eject_key and type(args.eject_key) == 'string' then
		-- TODO: rewrite this to be cleaner
		local detected_keys = {}
		new_tables[1] = {}
		for i = 1, #card.infinifusion do
			if card.infinifusion[i].key == args.eject_key then
				detected_keys[i] = true
			end
		end
		
		local ejections_left = args.eject_amount or #detected_keys
		if ejections_left > #detected_keys then ejections_left = #detected_keys end
		
		
		
	elseif args.equal then
		local parts = 2
		local part_size = 1
		if type(args.equal) == 'number' and args.equal >= 2 then
			parts = math.ceil(args.equal)
		end
		
		part_size = math.ceil(#card.infinifusion/parts)
		math.randomseed(pseudoseed('defusion'))
		local shuffle = {}
		for i = 1, #card.infinifusion do
			local id = math.random(#card.infinifusion)
			shuffle[#shuffle+1] = table.remove(card.infinifusion, id)
		end
		card.infinifusion = shuffle
		
		local cur_part = 1
		for i = 1, #card.infinifusion do
			if not new_tables[cur_part] then new_tables[cur_part] = {} end
			
			new_tables[cur_part][#new_tables[cur_part]+1] = card.infinifusion[i]
			
			if i % part_size == 0 then cur_part = cur_part + 1 end
		end
	end
	
	if #new_tables < 2 then return {} end
	
	for _, v in ipairs(new_tables) do
		if #v == 1 then
			local i = #cards+1
			cards[i] = Card(
			(card.T.x + card.T.w/2), 
			card.T.y, 
			G.CARD_W, G.CARD_H, nil, 
			G.P_CENTERS[v[1].key],
			{bypass_discovery_center = true,
			infus_old_ability = v[1].ability})
			
			cards[i].edition = card.edition and copy_table(card.edition)
		else
			cards[#cards+1] = create_infinifusion({
				contents = v,
				edition = card.edition,
				X = (card.T.x + card.T.w/2),
				Y = card.T.y
			})
		end
	end
	
	if not args.keep_old_card then
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0, blockable = false,
		func = function()
			card.area:remove_card(card)
			card:remove_from_deck()
			card:remove()
			card = nil
		return true; end})) 
	end
	
	return cards
end

function infinifusion_vanilla_loc_var(self)
	if self.key == 'j_joker' or self.key == 'j_ceremonial' or self.key == 'j_swashbuckler' then 
		return {self.ability.mult}
	
	elseif self.key == 'j_greedy_joker' or self.key == 'j_lusty_joker'
	or self.key == 'j_wrathful_joker' or self.key == 'j_gluttenous_joker' then
		return {self.ability.extra.s_mult, localize(self.ability.extra.suit, 'suits_singular')}
	
	elseif self.key == 'j_jolly' or self.key == 'j_zany' 
	or self.key == 'j_mad' or self.key == 'j_crazy' or self.key == 'j_droll' then
		return {self.ability.t_mult, localize(self.ability.type, 'poker_hands')}
	
	elseif self.key == 'j_sly' or self.key == 'j_wily' 
	or self.key == 'j_clever' or self.key == 'j_devious' or self.key == 'j_crafty' then
		return {self.ability.t_chips, localize(self.ability.type, 'poker_hands')}
	
	elseif self.key == 'j_half' then
		return {self.ability.extra.mult, self.ability.extra.size}
	
	elseif self.key == 'j_fortune_teller' then
		return {self.ability.extra, (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot or 0)}
	
	elseif self.key == 'j_steel_joker' then
		return {self.ability.extra, 1 + self.ability.extra*(self.ability.steel_tally or 0)}
	
	elseif self.key == 'j_space' then
		return {''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra}
	
	elseif self.key == 'j_stone' then
		return {self.ability.extra, self.ability.extra*(self.ability.stone_tally or 0)}
	
	elseif self.key == 'j_drunkard' then
		return {self.ability.d_size}
	
	elseif self.key == 'j_green_joker' then
		return {self.ability.extra.hand_add, self.ability.extra.discard_sub, self.ability.mult}
	
	elseif self.key == 'j_blue_joker' then
		return {self.ability.extra, self.ability.extra*((G.deck and G.deck.cards) and #G.deck.cards or 52)}
	
	elseif self.key == 'j_hack' or self.key == 'j_dusk' or self.key == 'j_sock_and_buskin' then
		return {self.ability.extra+1}
	
	elseif self.key == 'j_faceless' then
		return {self.ability.extra.dollars, self.ability.extra.faces}
	
	elseif self.key == 'j_juggler' then
		return {self.ability.h_size}
	-- pure x_mult
	elseif self.key == 'j_stencil' or self.key == 'j_card_sharp' then
		return {self.ability.x_mult}
	
	elseif self.key == 'j_misprint' then
		G.localization.descriptions.Joker.j_misprint_static.name =  G.localization.descriptions.Joker.j_misprint.name
		G.localization.descriptions.Joker.j_misprint_static.name_parsed =  G.localization.descriptions.Joker.j_misprint.name_parsed
		
		local foresight = "#@"
		if G.deck and G.deck.cards[1] then
			foresight = foresight..tostring(G.deck.cards[#G.deck.cards].base.id)..tostring(G.deck.cards[#G.deck.cards].base.suit:sub(1,1))
		else
			foresight = foresight.."11D"
		end
		return {foresight}
	
	elseif self.key == 'j_mystic_summit' then
		return {self.ability.extra.mult, self.ability.extra.d_remaining}
	
	elseif self.key == 'j_loyalty_card' then
		return {self.ability.extra.Xmult, self.ability.extra.every + 1, localize{type = 'variable', key = (self.ability.loyalty_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = {self.ability.loyalty_remaining}}}
	
	elseif self.key == 'j_8_ball' then
		return {''..(G.GAME and G.GAME.probabilities.normal or 1),self.ability.extra}
	
	elseif self.key == 'j_abstract' then
		return {self.ability.extra, (G.jokers and G.jokers.cards and #G.jokers.cards or 0)*self.ability.extra}
		
	elseif self.key == 'j_gros_michel' then
		return {self.ability.extra.mult, ''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds}
		
	elseif self.key == 'j_scholar' then
		return {self.ability.extra.mult, self.ability.extra.chips}
	
	elseif self.key == 'j_business' then
		return {''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra}
		
	elseif self.key == 'j_trousers' then
		return {self.ability.extra, localize('Two Pair', 'poker_hands'), self.ability.mult}
	
	elseif self.key == 'j_ride_the_bus' or self.key == 'j_red_card' or self.key == 'j_flash' then
		return {self.ability.extra, self.ability.mult}
	
	elseif self.key == 'j_blackboard' then
		return {self.ability.extra, localize('Spades', 'suits_plural'), localize('Clubs', 'suits_plural')}
	-- chip scalers
	elseif self.key == 'j_runner' or self.key == 'j_ice_cream' or self.key == 'j_square' or self.key == 'j_wee' then
		return {self.ability.extra.chips, self.ability.extra.chip_mod}
	-- extra and x_mult
	elseif self.key == 'j_constellation' or self.key == 'j_glass' or self.key == 'j_hit_the_road'
	or self.key == 'j_throwback' or self.key == 'j_madness' or self.key == 'j_vampire'
	or self.key == 'j_hologram' or self.key == 'j_obelisk' or self.key == 'j_lucky_cat'
	or self.key == 'j_campfire' then
		return {self.ability.extra, self.ability.x_mult}
	
	elseif self.key == 'j_todo_list' then
		return {self.ability.extra.dollars, localize(self.ability.to_do_poker_hand, 'poker_hands')}
		
	elseif self.key == 'j_troubadour' then
		return {self.ability.extra.h_size, -self.ability.extra.h_plays}
	
	elseif self.key == 'j_bloodstone' then
		return {''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds, self.ability.extra.Xmult}
		
	elseif self.key == 'j_merry_andy' then
		return {self.ability.d_size, self.ability.h_size}
		
	elseif self.key == 'j_idol' then
		return {self.ability.extra, localize(G.GAME.current_round.idol_card.rank, 'ranks'), localize(G.GAME.current_round.idol_card.suit, 'suits_plural'), colours = {G.C.SUITS[G.GAME.current_round.idol_card.suit]}}
	
	elseif self.key == 'j_duo' or self.key == 'j_trio' or self.key == 'j_family'
	or self.key == 'j_order' or self.key == 'j_tribe' then
		return {self.ability.x_mult, localize(self.ability.type, 'poker_hands')}
	
	elseif self.key == 'j_cavendish' then
		return {self.ability.extra.Xmult, ''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds}
	
	elseif self.key == 'j_seance' then
		return {localize(self.ability.extra.poker_hand, 'poker_hands')}
	
	elseif self.key == 'j_cloud_9' then
		return {self.ability.extra, self.ability.extra*(self.ability.nine_tally or 0)}
	
	elseif self.key == 'j_rocket' then
		return {self.ability.extra.dollars, self.ability.extra.increase}
		
	elseif self.key == 'j_turtle_bean' then
		return {self.ability.extra.h_size, self.ability.extra.h_mod}
	
	elseif self.key == 'j_erosion' then
		return {self.ability.extra, math.max(0,self.ability.extra*(G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0)), G.GAME.starting_deck_size}
	
	elseif self.key == 'j_reserved_parking' then
		return {self.ability.extra.dollars, ''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds}
	
	elseif self.key == 'j_mail' then
		return {self.ability.extra, localize(G.GAME.current_round.mail_card.rank, 'ranks')}
	
	elseif self.key == 'j_hallucination' then
		return {G.GAME.probabilities.normal, self.ability.extra}
	
	elseif self.key == 'j_bull' then
		return {self.ability.extra, self.ability.extra*math.max(0,G.GAME.dollars) or 0}
	
	elseif self.key == 'j_diet_cola' then
		return {localize{type = 'name_text', set = 'Tag', key = 'tag_double', nodes = {}}}
	
	elseif self.key == 'j_popcorn' then
		return {self.ability.mult, self.ability.extra}
	
	elseif self.key == 'j_ramen' then
		return {self.ability.x_mult, self.ability.extra}
	
	elseif self.key == 'j_ancient' then
		return {self.ability.extra, localize(G.GAME.current_round.ancient_card.suit, 'suits_singular'), colours = {G.C.SUITS[G.GAME.current_round.ancient_card.suit]}}
	
	elseif self.key == 'j_walkie_talkie' then
		return {self.ability.extra.chips, self.ability.extra.mult}
	
	elseif self.key == 'j_castle' then
		return {self.ability.extra.chip_mod, localize(G.GAME.current_round.castle_card.suit, 'suits_singular'), self.ability.extra.chips, colours = {G.C.SUITS[G.GAME.current_round.castle_card.suit]}}
	
	elseif self.key == 'j_stuntman' then
		return {self.ability.extra.chip_mod, self.ability.extra.h_size}
	
	elseif self.key == 'j_invisible' then
		return {self.ability.extra, self.ability.invis_rounds}
		
	elseif self.key == 'j_satellite' then
		local planets_used = 0
		for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Planet' then planets_used = planets_used + 1 end end
		return{self.ability.extra, planets_used*self.ability.extra}
	
	elseif self.key == 'j_drivers_license' then
		return {self.ability.extra, self.ability.driver_tally or '0'}
	
	elseif self.key == 'j_bootstraps' then
		return {self.ability.extra.mult, self.ability.extra.dollars, self.ability.extra.mult*math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0))/self.ability.extra.dollars)}
	
	elseif self.key == 'j_caino' then
		return {self.ability.extra, self.ability.caino_xmult}
	
	elseif self.key == 'j_yorick' then
		return {self.ability.extra.xmult, self.ability.extra.discards, self.ability.yorick_discards, self.ability.x_mult}
	
	end
	
	return {self.ability.extra and self.ability.extra or nil}
end

-- hook for passive jokers like splash
local find_card_ref = SMODS.find_card
function SMODS.find_card(key, count_debuffed)
	local result = find_card_ref(key, count_debuffed)
	local fusions = find_card_ref('j_infus_fused', count_debuffed)
	
	for i = 1, #fusions do
		if not fusions[i].infinifusion_api or not fusions[i].infinifusion_api.disable_find_card then
			local infinifusion = fusions[i].infinifusion
			for i = 1, #infinifusion do
				if infinifusion[i].key == key then
					result[#result+1] = fusions[i]
					break
				end
			end
		end
	end
	
	return result
end

-- same but thunked
local find_joker_ref = find_joker
function find_joker(name, non_debuff)
	local result = find_joker_ref(name, non_debuff)
	local fusions = find_card_ref('j_infus_fused', non_debuff)
	
	for i = 1, #fusions do
		if not fusions[i].infinifusion_api or not fusions[i].infinifusion_api.disable_find_card then
			local infinifusion = fusions[i].infinifusion
			for i = 1, #infinifusion do
				if infinifusion[i].ability and infinifusion[i].ability.name and infinifusion[i].ability.name == name then
					result[#result+1] = fusions[i]
					break
				end
			end
		end
	end
	
	return result
end

-- hooks for proper saving
local card_save_ref = Card.save
function Card:save()
	local cardTable = card_save_ref(self)
	
	if self.infinifusion then
		cardTable.save_fields.center = self.infinifusion_center and self.infinifusion_center.key or 'j_infus_fused'
		cardTable.infinifusion = self.infinifusion
		cardTable.ability_placeholder = self.ability_placeholder or self.ability
		
		if self.infinifusion_api then
			cardTable.infinifusion_api = self.infinifusion_api.key
		end
	end
	
	return cardTable
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
	self.infinifusion = cardTable.infinifusion
	if self.infinifusion and cardTable.save_fields.center ~= 'j_infus_fused' then
		self.infinifusion_center = G.P_CENTERS[cardTable.save_fields.center]
	end
	self.ability_placeholder = cardTable.ability_placeholder
	if cardTable.infinifusion_api and G.INFINIFUSIONS[cardTable.infinifusion_api] then
		self.infinifusion_api = G.INFINIFUSIONS[cardTable.infinifusion_api]
		self.infinifusion_api_checked = true
	end
	card_load_ref(self, cardTable, other_card)
end

-- hook for cool badge
local update_ref = Game.update
function Game:update(dt)
	update_ref(self, dt)
	InfiniteFusion.badge_colour[1] = 0.6 + 0.2*math.sin(self.TIMERS.REAL*1.2)
	InfiniteFusion.badge_colour[2] = 0.6 + 0.2*math.cos(self.TIMERS.REAL)
	InfiniteFusion.badge_colour[3] = 0.6 + 0.2*math.sin((self.TIMERS.REAL+5)*1.1)
end

local set_edition_ref = Card.set_edition
function Card:set_edition(edition, immediate, silent)
	if self.infus_editions and self.infus_editions.key then
		if not edition then
			self.edition = nil
		else
			self.edition = copy_table(self.infus_editions)
		end
	else
		local restore_cons = nil
		if self.infinifusion and self.ability.consumeable then
			restore_cons = self.ability.consumeable 
			self.ability.consumeable = nil
		end
		set_edition_ref(self, edition, immediate, silent)
		if restore_cons then
			self.ability.consumeable = restore_cons
		end
	end
end

------------------------
-- Compat
------------------------

function unfusable(self)
	local k
	if type(self) == 'string' then k = self
	elseif self.key then k = self.key
	elseif self.config and self.config.center then
		k = self.config.center.key
	else return true end
	
	if not G.P_CENTERS[k] then return true end
	if G.P_CENTERS[k].infinifusion_incompat then return true
	else
		for i = 1, #InfiniteFusion.incompatible_jokers do
			if InfiniteFusion.incompatible_jokers[i] == k then
				table.remove(InfiniteFusion.incompatible_jokers, i)
				G.P_CENTERS[k].infinifusion_incompat = true
				return true
			end
		end
	end
	
	return nil
end

------------------------
--   DebugPlus command
------------------------

local success, dpAPI = pcall(require, "debugplus-api")

local logger = {
    log = print,
    debug = print,
    info = print,
    warn = print,
    error = print
}

if success and dpAPI.isVersionCompatible(0) then
    local debugplus = dpAPI.registerID("InfiniteFusion")
    logger = debugplus.logger
	
    debugplus.addCommand({
		name = "infuse",
		source = "InfiniteFusion",
		shortDesc = "Spawns an InfiniFusion.",
		desc = "Spawns an InfiniFusion, can be specified using InfiniFusion keys, Joker keys and Joker slots.",
		exec = function(args, rawArgs, dp)
			if G.STAGE ~= G.STAGES.RUN then
				return "This command must be run during a run.", "ERROR"
			end
			local new_card = nil
			local contents = {}
			local jokers = {}
			if not args[1] then
				new_card = Card(
					(G.jokers.T.x + G.jokers.T.w/2), 
					G.jokers.T.y, 
					G.CARD_W, G.CARD_H, nil, 
					G.P_CENTERS['j_infus_fused'],{bypass_discovery_center = true,})
			elseif #args == 1 then
				if args[1] == 'all' then 
					if #G.jokers.cards < 2 then return "Not enough Jokers to create a Fusion.", "ERROR" end
					for k, v in ipairs(G.jokers.cards) do
						if not unfusable(v) then contents[#contents+1] = v end
					end
					new_card = create_infinifusion({contents = contents})
				elseif not string.find(args[1], '^if_') or not G.INFINIFUSIONS[args[1]] then
					return "Invalid InfiniFusion key.", "ERROR"
				else
					new_card = create_infinifusion({key = args[1]})
				end
			else
				for i = 1, #args do
					local id = tonumber(args[i])
					if id and id <= #G.jokers.cards and id > 0 then
						if not jokers[id] and not unfusable(G.jokers.cards[id].config.center) then
							jokers[id] = true
							contents[#contents+1] = G.jokers.cards[id]
						end
					elseif string.find(args[i], '^if_') then
						if G.INFINIFUSIONS[args.i] then
							for ii = 1, #G.INFINIFUSIONS[args.i].contents do
								local key = G.INFINIFUSIONS[args.i].contents[ii]
								if G.P_CENTERS[key] and not unfusable(G.P_CENTERS[key]) then
									contents[#contents+1] = key
								end
							end
						end
					else
						if G.P_CENTERS[args[i]] and not unfusable(G.P_CENTERS[args[i]]) then
							contents[#contents+1] = args[i]
						end
					end
				end
				
				if #contents >= 2 then
					new_card = create_infinifusion({contents = contents})
				else return "Not enough Jokers to create a Fusion.", "ERROR" end
			end
			
			if new_card then
				G.jokers:emplace(new_card)
				new_card:add_to_deck()
				new_card:juice_up()
				if not args[1] then return "Natural Fusion successful."
				else return "Fusion successful." end
			else return "Fusion failed.", "ERROR" end
		end
	})
	
	local find_defuse_tar = function(t)
		local card = nil
		if not t then 
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].infinifusion then
					card = G.jokers.cards[i]
					break
				end
			end
		else
			if G.jokers.cards[t] and G.jokers.cards[t].infinifusion then
				card = G.jokers.cards[t]
			end
		end
		return card
	end
	
	debugplus.addCommand({
		name = "defuse",
		source = "InfiniteFusion",
		shortDesc = "Splits an InfiniFusion.",
		desc = "Splits the InfiniFusion in the specified Joker slot.",
		exec = function(args, rawArgs, dp)
			if G.STAGE ~= G.STAGES.RUN then
				return "This command must be run during a run.", "ERROR"
			end
			local cards = {}
			local card = nil
			
			if not args[1] then --/defuse
				card = find_defuse_tar()
				if card then 
					cards = split_infinifusion(card)
				else 
					return "Fusion split failed - No valid targets.", "ERROR" 
				end
			end
			
			if args[1] then --/defuse <slot>
				local id = tonumber(args[1])
				if id and id <= #G.jokers.cards and id > 0 then
					card = find_defuse_tar(id)
					if card then 
						cards = split_infinifusion(card)
					else 
						return "Fusion split failed - Invalid target.", "ERROR" 
					end
				else
					if args[2] then
						local id = tonumber(args[2])
						if id and id <= #G.jokers.cards and id > 0 then
							card = find_defuse_tar(id)
							if not card then 
								card = find_defuse_tar()
								if not card then return "Fusion split failed - No valid targets.", "ERROR" end
							end
						end
					else
						card = find_defuse_tar()
						if not card then return "Fusion split failed - No valid targets.", "ERROR" end
					end
					
					if card then -- /defuse total or /defuse all
						if args[1] == 'total' or args[1] == 'all' then
							cards = split_infinifusion(card)
						elseif (args[1] == 'key' or args[1] == 'eject') and false then
							if args[3] then -- /defuse key <slot> <key> <amount>
								cards = split_infinifusion(card, {eject_key = args[3], eject_amount = args[4] and tonumber(args[4])})
							end
						elseif args[1] == 'equal' then -- /defuse equal <amount>
							cards = split_infinifusion(card, {equal = args[3] and tonumber(args[3]) or 2})
						end
					end
				end
			end
			
			if #cards > 1 then
				for k, v in ipairs(cards) do
					G.jokers:emplace(v)
					v:add_to_deck()
					v:juice_up()
				end
				return "Fusion split successfully."
			else return "Fusion split failed - No cards could be split.", "ERROR" end
		end
	})
end
