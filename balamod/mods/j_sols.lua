local mod_id = "j_sols_arachnei"
local mod_name = "sols Joker"
local mod_version = "1.0"
local mod_author = "arachnei"

local function jokerEffect(card, context)
    if card.ability.name == "sols" and context.cardarea == G.jokers and not context.before and not context.after and context.scoring_hand and #context.scoring_hand > 4 then
        local hand_seq = ""
        local disastermode_seq = "5776578588"
        for i = 1, #context.scoring_hand do
            hand_seq = hand_seq..tostring(context.scoring_hand[i].base.id)
        end
        if string.find(disastermode_seq, hand_seq) then
            return {
                message = localize{type='variable', key='a_xmult', vars = {card.config.center.config.Xmult}},
                Xmult_mod = card.config.center.config.Xmult
            }
        end
        
        -- local eights = 0
        -- for i = 1, #context.scoring_hand do
        --     if context.scoring_hand[i].base.id == 8 then eights = eights + 1 end
        -- end
        -- if eights >= 1 then
        --     return {
        --         --i have no clue why Xmult isnt showing up in card.ability.xmult, so i just manually go to the config instead
        --         --alternatively, i couldve put Xmult inside of extra and used card.ability.extra.Xmult

        --     }
        -- end
    end
end

table.insert(mods, {
    mod_id = mod_id,
    name = mod_name,
    version = mod_version,
    author = mod_author,
    enabled = true,
    on_enable = function()
        centerHook.addJoker(self, 
            'j_sols_arachnei',  --id
            'sols',             --name
            jokerEffect,        --effect function
            nil,                --order
            true,               --unlocked
            true,               --discovered
            6,                  --cost
            {x=0,y=0},          --sprite position
            nil,                --internal effect description
            {Xmult = 4},         --config
            {"{C:red}X4{} Mult if played", "hand contains at", "least 4 cards and", "contains any sequence", " in {C:attention}5776578588{}"}, --description text
            3,                  --rarity
            true,               --blueprint compatibility
            true,               --eternal compatibility
            nil,                --exclusion pool flag
            nil,                --inclusion pool flag
            nil,                --unlock condition
            true,               --collection alert
            "assets",           --sprite path
            "sols joker.png",   --sprite name
            {px=71, py=95}      --sprite size
        )
    end,
    on_disable = function()
        centerHook.removeJoker(self, "j_sols_arachnei")
    end,
    on_key_pressed = function(key_name)
        if key_name == "left" then
            local joker_id = "j_sols_arachnei"
            local c1 = create_card("Joker", G.jokers, nil, 1, true, false, joker_id, nil)
            c1.area = G.jokers
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                c1.area:remove_card(c1)
                c1:add_to_deck()
                G.jokers:emplace(c1)

                G.CONTROLLER:save_cardarea_focus('jokers')
                G.CONTROLLER:recall_cardarea_focus('jokers')
                return true
                end
            }))
        end
    end
})