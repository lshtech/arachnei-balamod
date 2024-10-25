--- STEAMODDED HEADER
--- MOD_NAME: Arachnei's Balamods
--- MOD_ID: arachnei
--- MOD_AUTHOR: [arachnei, elbe]
--- MOD_DESCRIPTION: Arachnei's Balamod mods, ported
--- BADGE_COLOUR: 63e19a
--- DISPLAY_NAME: Arachnei
--- PREFIX: arach

---------------------------------------------- 
------------MOD CODE ------------------------- 

---- Consumables
local bezos = true
local ganymede = true
local humanity = true

---- Jokers
local jokers = true
local jonkler = true
local sols = true

---- Other
local coupon_book = true
local hobby_shop = true

if bezos then
  SMODS.Atlas {
    key = "bezos",
    path = "bezos spectral.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Consumable{
    key = 'bezos',
    set = 'Spectral',
    loc_txt = {
        name = "Bezos",
        text = {
            "Gain {C:money}$#1#{}"
        },
    },
    loc_vars = function(self, info_queue, card)
      return {vars = {card.ability.extra}}
    end,
    pos = {
        x = 0,
        y = 0,
    },
    config = { extra = 100 },
    atlas = 'bezos',
    cost = 4,
    unlocked = true,
    discovered = false,
    can_use = function(self, card)
      return true
    end,
    use = function(self, card, area, copier)
          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
              play_sound('timpani')
              ease_dollars(card.ability.extra, true)
              return true end }))
          delay(0.6)
    end,
  }
end

if ganymede then
  SMODS.Atlas {
    key = "ganymede",
    path = "Ganymede.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Consumable{
      set = 'Planet',
      atlas = 'ganymede',
      key = 'ganymede',
      loc_txt = {
          name = "Ganymede",
          text = {
            "Level up all",
            "hands that contain",
            "a {C:attention}Flush"
          },
      },
      config = {},
      pos = {
          x = 0,
          y = 0,
      },
      cost = 5,
      unlocked = true,
      discovered = false,
      can_use = function(self, card)
        return true
      end,
      use = function(self, card, area, copier)
        -- upgrade these hands
        local hands = {}
        for k,v in pairs(SMODS.PokerHands) do
          if k:lower():find("flush") then
            table.insert(hands, k)
          end
        end
        for _, v in ipairs(hands) do
          -- display hand value before level up
          update_hand_text(
              {sound = 'button', volume = 0.4, pitch = 0.8, delay = 0.1},
              {
                  handname=localize(v, 'poker_hands'),
                  chips = G.GAME.hands[v].chips,
                  mult = G.GAME.hands[v].mult,
                  level=G.GAME.hands[v].level
              }
          )
          -- level up the hand
          -- pass card to make tarot card do a little animation
          level_up_hand(card, v)
          -- set hand back to no special state
          update_hand_text(
              {sound = 'button', volume = 0.4, pitch = 1.1, delay = 0},
              {mult = 0, chips = 0, handname = '', level = ''}
          )
        end
      end,
  }
end

if humanity then
  SMODS.Atlas {
    key = "humanity",
    path = "humanity tarot.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Consumable {
    key = 'humanity',
    loc_txt = {
        name = 'Humanity',
        text = {
            "Select up to {C:attention}3{}",
            "cards. Set their rank",
            "to their average"
          }
    },
    set = 'Tarot',
    atlas = "humanity",
    config = { max_highlighted = 3 },
    pos = { x = 0, y = 0 },
    cost = 3,
    unlocked = true,
    discovered = false,
    can_use = function(self, card)
      if G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.PLANET_PACK then
          if #G.hand.highlighted >= 1 and #G.hand.highlighted <= card.ability.max_highlighted then
              --this is supposed to make it so you cant use the card if you highlight a stone card, but
              --i literally do not know why it doesnt work. it literally returns false correctly, but
              --you can still use the card even if you return false
              for i=1, #G.hand.highlighted do
                  if G.hand.highlighted[i].ability.effect == "Stone Card" then
                      return false
                  end
              end
              return true
          end
      end
    end,
    use = function(self, card, area, copier)
      --make the tarot card do a little animation
      G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
          play_sound('tarot1')
          card:juice_up(0.3, 0.5)
          return true end }))

      --flip highlighted cards (i'll be honest i have no clue what percent is for)
      for i=1, #G.hand.highlighted do
          local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
          G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
      end
      delay(0.2)
      G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
          --find average rank
          local rank_avg = 0
          for i=1, #G.hand.highlighted do
              local card_rank = G.hand.highlighted[i].base.id == 14 and 1 or G.hand.highlighted[i].base.id
              rank_avg = rank_avg + card_rank
          end
          rank_avg = math.floor(rank_avg / #G.hand.highlighted)

          --set new ranks
          local rank_name = nil
          if rank_avg == 1 then rank_name = 'A'
          elseif rank_avg < 10 then rank_name = tostring(rank_avg)
          elseif rank_avg == 10 then rank_name = 'T'
          elseif rank_avg == 11 then rank_name = 'J'
          elseif rank_avg == 12 then rank_name = 'Q'
          elseif rank_avg == 13 then rank_name = 'K'
          else return false end
          for i=1, #G.hand.highlighted do
              G.hand.highlighted[i]:set_base(G.P_CARDS[SMODS.Suits[G.hand.highlighted[i].base.suit].card_key..'_'..rank_name])
          end
      return true end}))
      --flip and unhighlight cards
      for i=1, #G.hand.highlighted do
          local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
          G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
      end
      G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
      delay(0.5)
    end
  }
end

if jokers then
  SMODS.Atlas {
    key = "jokers",
    path = "Jokers.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Joker {
    key = 'jokers',
    loc_txt = {
      name = 'Jokers',
      text = {
        "Played cards",
        "gain {C:red}+#1#{} Mult"
      }
    },
    loc_vars = function(self, info_queue, card)
      return {vars = {card.ability.mult}}
    end,
    config = { mult = 2 },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = false,
    atlas = 'jokers',
    pos = { x = 0, y = 0 },
    calculate = function(self, card, context)
      if context.individual and context.cardarea == G.play then
        return {
          mult = card.ability.mult,
          card = card
        }
      end
    end
  }
end

if jonkler then
  SMODS.Atlas {
    key = "jonkler",
    path = "the jonkler.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Joker {
    key = 'jonkler',
    loc_txt = {
      name = 'The Jonkler',
      text = {
        "{C:red}X1.8{} Mult",
        "{C:inactive}is he stupid?"
      }
    },
    loc_vars = function(self, info_queue, card)
      return {vars = {card.ability.mult}}
    end,
    config = { extra={Xmult = 1.8} },
    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = false,
    atlas = 'jonkler',
    pos = { x = 0, y = 0 },
    calculate = function(self, card, context)
      if context.cardarea == G.jokers and not context.before and not context.after then
        return {
            message = localize{type='variable', key='a_xmult', vars = {card.ability.extra.Xmult}},
            Xmult_mod = card.ability.extra.Xmult
        }
      end
    end
  }
end

if sols then
  SMODS.Atlas {
    key = "sols",
    path = "sols joker.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Joker {
    key = 'sols',
    loc_txt = {
      name = 'sols',
      text = {
        "{C:red}X4{} Mult if played",
        "hand contains at",
        "least 4 cards and",
        "contains any sequence",
        "in {C:attention}5776578588{}"
      }
    },
    loc_vars = function(self, info_queue, card)
      return {vars = {}}
    end,
    config = { extra={Xmult = 4} },
    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = false,
    atlas = 'sols',
    pos = { x = 0, y = 0 },
    calculate = function(self, card, context)
      if context.cardarea == G.jokers and not context.before and not context.after and context.full_hand and #context.full_hand >= 4 then
        local hand_seq = ""
        local disastermode_seq = "5776578588"
        for i = 1, #context.full_hand do
          hand_seq = hand_seq..tostring(context.full_hand[i].base.id)
        end
        if string.find(disastermode_seq, hand_seq) then
          return {
            --i have no clue why Xmult isnt showing up in card.ability.xmult, so i just manually go to the config instead
            --alternatively, i couldve put Xmult inside of extra and used card.ability.extra.Xmult
            message = localize{type='variable', key='a_xmult', vars = {card.ability.extra.Xmult}},
            Xmult_mod = card.ability.extra.Xmult
          }
        end
      end
    end
  }
end

if coupon_book then
  G.localization.misc.dictionary.k_coupon_book = "Coupon Book"
  SMODS.Atlas {
    key = "coupon_book",
    path = "coupon book.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Booster {
  key = 'coupon_book',
  atlas = 'coupon_book',
  group_key = "k_coupon_book",
  loc_txt = {
    name = "Coupon Book",
    text = {
      "Choose {C:attention}1{} of up to",
      "{C:attention}2{} Vouchers to be",
      "redeemed immediately",
      "{C:inactive}Art by: thatobserver"
    }
  },
  weight = 0.2,
  cost = 12,
  name = "Coupon Book",
  pos = {x = 0, y = 0},
  config = {extra = 2, choose = 1, name = "Coupon Book"},
  create_card = function(self, card)
    return create_card("Voucher", G.pack_cards, nil, nil, true, nil, nil, 'couponbook')
  end
}
end

if hobby_shop then
  SMODS.Atlas {
    key = "hobby_shop",
    path = "card shop.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS',
  }
  SMODS.Voucher {
    key = 'hobby_shop',
    loc_txt = {
      name = 'Hobby Shop',
      text = {
        "Shop rerolls also restock",
        "purchased {C:attention}Booster Pack{}"
      }
    },
    pos = {
      x = 0,
      y = 0
    },
    cost = 10,
    discovered = true,
    redeem = function(self)
    end,
    atlas = "hobby_shop"
  }

  local function my_reroll_shop(num)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            if not (G.GAME.current_round and G.GAME.current_round.used_packs and G.shop_booster and G.shop_booster.cards) then
                return true
            end
            for i = #G.shop_booster.cards,1, -1 do
                local c = G.shop_booster:remove_card(G.shop_booster.cards[i])
                c:remove()
                c = nil
            end

            play_sound('coin2')
            play_sound('other1')

            for i = 1, num - #G.shop_booster.cards do
                G.GAME.current_round.used_packs = G.GAME.current_round.used_packs or {}
                G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key
                local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                create_shop_card_ui(card, 'Booster', G.shop_booster)
                card.ability.booster_pos = i
                card:start_materialize()
                G.shop_booster:emplace(card)
            end
        return true
        end
    }))
    G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
  end

  local G_FUNCS_reroll_shop_ref=G.FUNCS.reroll_shop
  G.FUNCS.reroll_shop = function(e)
      G_FUNCS_reroll_shop_ref(e)
      if G.GAME.used_vouchers["v_arach_hobby_shop"] then
        my_reroll_shop(get_booster_pack_max())
      end
  end
end
----------------------------------------------
------------MOD CODE END---------------------
