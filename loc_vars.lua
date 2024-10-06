
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
	
	
	-- SPECTRALS
	elseif self.key == 'c_immolate' then
		return {self.ability.extra.destroy, self.ability.extra.dollars}
	
	elseif self.key == 'c_ectoplasm' then
		return {G.GAME.ecto_minus or 1}
	
	-- PLANETS
	elseif G.P_CENTERS[self.key] and G.P_CENTERS[self.key].set == 'Planet' then
		local config = self.ability.consumeable
		return {
			G.GAME.hands[config.hand_type].level,localize(config.hand_type, 'poker_hands'), G.GAME.hands[config.hand_type].l_mult, G.GAME.hands[config.hand_type].l_chips,
			colours = {(G.GAME.hands[config.hand_type].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[config.hand_type].level)])}
        }
	
	-- TAROTS
	elseif self.key == 'c_fool' then
		return {G.GAME.last_tarot_planet and G.P_CENTERS[G.GAME.last_tarot_planet] or nil}
	
	elseif self.key == 'c_magician' or self.key == 'c_empress' or self.key == 'c_lovers' 
	or self.key == 'c_heirophant' or self.key == 'c_chariot' or self.key == 'c_justice'
	or self.key == 'c_tower' or self.key == 'c_devil' then
		local config = self.ability.consumeable
		return {config.max_highlighted, localize{type = 'name_text', set = 'Enhanced', key = config.mod_conv}}
	
	elseif self.key == 'c_death' or self.key == 'c_hanged_man' or self.key == 'c_strength' then
		local config = self.ability.consumeable
		return {config.max_highlighted}
	
	elseif self.key == 'c_temperance' then
		local config = self.ability.consumeable
		local _money = 0
		if G.jokers then
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].ability.set == 'Joker' then
					_money = _money + G.jokers.cards[i].sell_cost
				end
			end
		end
		return {config.extra, math.min(config.extra, _money)}
	
	elseif self.key == 'c_emperor' then
		local config = self.ability.consumeable
		return {config.tarots}
		
	elseif self.key == 'c_high_priestess' then
		local config = self.ability.consumeable
		return {config.planets}
	
	elseif self.key == 'c_hermit' then
		local config = self.ability.consumeable
		return {config.extra}
		
	elseif self.key == 'c_wheel_of_fortune' then
		local config = self.ability.consumeable
		return {G.GAME.probabilities.normal, config.extra}
	
	elseif self.key == 'c_star' or self.key == 'c_moon'
	or self.key == 'c_sun' or self.key == 'c_world' then
		local config = self.ability.consumeable
		return {config.max_highlighted, localize(config.suit_conv, 'suits_plural'), colours = {G.C.SUITS[config.suit_conv]}}
		
	end
	
	return {self.ability.extra and self.ability.extra or nil}
end