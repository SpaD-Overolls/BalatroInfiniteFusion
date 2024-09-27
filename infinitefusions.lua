--- STEAMODDED HEADER
--- MOD_NAME: Infinite Fusion
--- MOD_ID: InfiniteFusion
--- MOD_AUTHOR: [SpaD_Overolls, Joey J. Jester]
--- MOD_DESCRIPTION: Fuse any Jokers!
--- PREFIX: infus

-- using a placeholder sprite by Joey J. Jester
-- known fusion issues:
-- -- Sixth Sense doesnt destroy cards
-- -- Blueprint/Brainstorm call status on their target instead of themselves
InfiniteFusion = SMODS.current_mod
InfiniteFusion.badge_colour = HEX('de2323')

SMODS.Joker {
	key = 'fused',
	discovered = true,
	pos = {x = 9, y = 9},
	soul_pos = {x = 5, y = 3},
	omit = true,
	set_ability = function(self, card, initial, delay_sprites)
		if not card.infinifusion then card.infinifusion = {{key = 'j_perkeo'},{key = 'j_joker'}} end
		card.ability_placeholder = card.ability
		for i = 1, #card.infinifusion do
			if not card.infinifusion[i].ability then
				card.config.center = nil
				card.ability = nil
				card:set_ability(G.P_CENTERS[card.infinifusion[i].key], initial, delay_sprites)
				card.infinifusion[i].ability = copy_table(card.ability)
			end
		end
		
		card.config.center = G.P_CENTERS['j_infus_fused']
	end,
	set_sprites = function(self, card, front)
		card.children.center.atlas = G.ASSET_ATLAS["Joker"]
		card.children.center:set_sprite_pos(self.pos)
		card.children.floating_sprite.atlas = G.ASSET_ATLAS["centers"]
		card.children.floating_sprite:set_sprite_pos(self.soul_pos)
	end,
	load = function(self, card, card_table, other_card)
		calculate_infinijoker(card, function(i)
			if G.P_CENTERS[card.infinifusion[i].key].load then
				G.P_CENTERS[card.infinifusion[i].key].load(G.P_CENTERS[card.infinifusion[i].key], card, card_table, other_card)
			end
		end)
	end,
	add_to_deck = function(self, card, from_debuff)
		calculate_infinijoker(card, function(i)
			card.added_to_deck = nil
			card:add_to_deck(from_debuff)
		end)
		card.added_to_deck = true
	end,
	remove_from_deck = function(self, card, from_debuff)
		calculate_infinijoker(card, function(i)
			card.added_to_deck = true
			card:remove_from_deck(from_debuff)
		end)
		card.added_to_deck = false
	end,
	in_pool = function(self)
		return false -- shouldnt naturally spawn
	end,
	inject = function(self)
		G.P_CENTERS[self.key] = self
	end,
	update = function(self, card, dt)
	end,
	calculate = function(self, card, context)
		calculate_infinijoker(card, function(i)
			card:calculate_joker(context)
		end)
	end,
	calc_dollar_bonus = function(self, card)
		calculate_infinijoker(card, function(i)
			card:calculate_dollar_bonus()
		end)
	end,
	
	set_card_type_badge = function(self, card, badges)
	end,
	loc_vars = function(self, info_queue, card)
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
				loc_vars.vars, loc_vars.key = infinifusion_vanilla_loc_var(card.infinifusion[i])
			end
			
			if loc_vars.key and type(loc_vars) == 'string' then key = loc_vars.key end
			info_queue[#info_queue+1] = {key = key, set = set, specific_vars = loc_vars.vars}
		end
		
		card.ability = card.ability_placeholder
		card.config.center = G.P_CENTERS['j_infus_fused']
	end,
}

function calculate_infinijoker(card, calc_func)
	for i = 1, #card.infinifusion do
		card.ability = copy_table(card.infinifusion[i].ability)
		card.config.center = G.P_CENTERS[card.infinifusion[i].key]
		calc_func(i)
		card.infinifusion[i].ability = copy_table(card.ability)
	end
	
	card.ability = card.ability_placeholder
	card.config.center = G.P_CENTERS['j_infus_fused']
end

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
			return true
		end
		return false
	end,
	use = function(self, card, area, copier)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
			infinifusion_fuse_cards({G.jokers.cards[1], G.jokers.cards[#G.jokers.cards]})
            return true end }))
	end
}

function infinifusion_fuse_cards(cards)
	cards = cards or {}
	if not type(cards) == 'table' or #cards < 2 then return nil end
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0, blockable = false,
	func = function()
		local infinifusion = {}
		for i = 1, #cards do
			if cards[i].config.center.key == 'j_infus_fused' then
				for ii = 1, #cards[i].infinifusion do
					infinifusion[#infinifusion+1] = cards[i].infinifusion[ii]
				end
			else
				local card = {}
				card.key = cards[i].config.center.key
				card.ability = copy_table(cards[i].ability)
				infinifusion[#infinifusion+1] = card
			end
			
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0, blockable = false,
			func = function()
				G.jokers:remove_card(cards[i])
				cards[i]:remove_from_deck()
				cards[i]:remove()
				cards[i] = nil
			return true; end})) 
		end
		
		local new_fusion = Card(G.jokers.T.x + G.jokers.T.w/2, G.jokers.T.y, G.CARD_W, G.CARD_H, nil, G.P_CENTERS['j_infus_fused'],{bypass_discovery_center = true, infinifusion = infinifusion})
		G.jokers:emplace(new_fusion)
		new_fusion:add_to_deck()
		new_fusion:juice_up()
	return true; end})) 
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
		if not G.localization.descriptions.Joker.j_misprint_static then
			G.localization.descriptions.Joker.j_misprint_static = {
				name = G.localization.descriptions.Joker.j_misprint.name,
				text = {'{C:red}#1#'},
				name_parsed = loc_parse_string(G.localization.descriptions.Joker.j_misprint.name),
				text_parsed = {}
			}
			for i = 1, #G.localization.descriptions.Joker.j_misprint_static.text do
				G.localization.descriptions.Joker.j_misprint_static.text_parsed[i] = 
					loc_parse_string(G.localization.descriptions.Joker.j_misprint_static.text[i])
			end
		end
		return {tostring("#@"..G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11 ..G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit:sub(1,1) or 'D')}, 'j_misprint_static'
	
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
	elseif self.key == 'j_runner' or self.key == 'j_ice_cream' or self.key == 'j_square' then
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
		local infinifusion = fusions[i].infinifusion
		for i = 1, #infinifusion do
			if infinifusion[i].key == key then
				result[#result+1] = fusions[i]
				break
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
		local infinifusion = fusions[i].infinifusion
		for i = 1, #infinifusion do
			if infinifusion[i].ability and infinifusion[i].ability.name and infinifusion[i].ability.name == name then
				result[#result+1] = fusions[i]
				break
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
		cardTable.save_fields.center = 'j_infus_fused'
		cardTable.infinifusion = self.infinifusion
		cardTable.ability_placeholder = self.ability_placeholder
	end
	
	return cardTable
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
	self.infinifusion = cardTable.infinifusion
	self.ability_placeholder = cardTable.ability_placeholder
	card_load_ref(self, cardTable, other_card)
end

-- hook for proper copying
local copy_card_ref = copy_card
function copy_card(other, new_card, card_scale, playing_card, strip_edition)
	local new_card = copy_card_ref(other, new_card, card_scale, playing_card, strip_edition)
	
	if other.infinifusion then 
		new_card.infinifusion = copy_table(other.infinifusion) 
		new_card.ability_placeholder = copy_table(other.ability_placeholder)
		G.P_CENTERS["j_infus_fused"].set_sprites(G.P_CENTERS["j_infus_fused"], new_card, new_card.children.front or nil)
	end
	
	return new_card
end

-- hook for cool badge
local update_ref = Game.update
function Game:update(dt)
	update_ref(self, dt)
	InfiniteFusion.badge_colour[1] = 0.6 + 0.2*math.sin(self.TIMERS.REAL*1.2)
	InfiniteFusion.badge_colour[2] = 0.6 + 0.2*math.cos(self.TIMERS.REAL)
	InfiniteFusion.badge_colour[3] = 0.6 + 0.2*math.sin((self.TIMERS.REAL+5)*1.1)
end