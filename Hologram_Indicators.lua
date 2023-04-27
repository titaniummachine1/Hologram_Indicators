--[[
    Hologram indicators
    author: titaniummachine1 / 
    credits:
    pred#2448
]]

local floor = math.floor
local x, y = draw.GetScreenSize()
local font_calibri = draw.CreateFont("Calibri", 18, 18)

local victim_entity
local attacker
local localplayer
local damage
local iscrit
local health
local ping
local DPS

local player_damage = {} -- table to store damage per player
local last_tick = globals.TickCount() -- initialize the last tick count
local function event_hook(ev)
    if ev:GetName() ~= "player_hurt" then return end -- only allows player_hurt event go through
    local victim = entities.GetByUserID(ev:GetInt("userid"))
    attacker = entities.GetByUserID(ev:GetInt("attacker"))
    damage = ev:GetInt("damageamount")
    local is_crit = ev:GetString("crit") == 1 and true or false
    health = ev:GetInt("health")
    ping = entities.GetPlayerResources():GetPropDataTableInt("m_iPing")[victim:GetIndex()]

    if last_real_time == nil then
        last_real_time = 0
    end
    -- calculate damage per second for the attacker
    if attacker:IsPlayer() and victim:IsPlayer() and attacker:GetTeamNumber() ~= victim:GetTeamNumber() then
        local tick = globals.TickCount()
        if tick > last_tick then -- if one tick has passed
            local time_diff = globals.RealTime() - last_real_time -- calculate time difference since last tick
            last_real_time = globals.RealTime() -- update last real time
            for _, player in pairs(player_damage) do -- iterate over all players
                player.dps = player.damage / time_diff -- calculate damage per second
                player.damage = 0 -- reset damage
                --print("Current DPS for player ", player.index, ": ", player.dps) -- print current DPS
                DPS = math.floor(player.dps)
            end
            last_tick = tick -- update last tick
        end
        if not player_damage[attacker:GetIndex()] then
            player_damage[attacker:GetIndex()] = { dps = 0, damage = 0, index = attacker:GetIndex() } -- initialize damage table for new players
        end
        player_damage[attacker:GetIndex()].damage = player_damage[attacker:GetIndex()].damage + damage -- add damage to total
    end
end




local myfont = draw.CreateFont( "Verdana", 16, 800 )
local function draw_handler()
    
    --paint_logs()
    --anim()
    local pLocal = entities.GetLocalPlayer()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end

    local players = entities.FindByClass("CTFPlayer")
    local sideoffset = 40
    local upoffset = -50
    local upoffset2 = -25
    local width = 100
    local height = 100
    
    local CurrentValue
    local Maxvalue

    for i, p in ipairs(players) do
        if p:IsAlive() and not p:IsDormant() and pLocal:GetTeamNumber() ~= p:GetTeamNumber() then
            local screenPos = client.WorldToScreen(p:GetAbsOrigin())
            if screenPos ~= nil then
                local pLocalPos = pLocal:GetAbsOrigin()
                local distance = (pLocalPos - p:GetAbsOrigin()):Length()
                local scale = math.max(0.2, math.min(1, 1000 / distance))
                local heightOffset = 50 + (p:GetAbsOrigin().z - pLocalPos.z) * scale
                width = width * scale
                height = height * scale
                local lloffsetX = screenPos[1] - width / 2
                local lloffsety = screenPos[2] - heightOffset
                local ruoffsetx = lloffsetX + width
                local ruoffsety = lloffsety + height
    
                local enemyPos = p:GetAbsOrigin()
                local enemyEyePos = enemyPos + Vector3(0, 0, 70)
                local enemyMidpoint = (enemyPos + enemyEyePos) / 2
                local enemyScreenPos = client.WorldToScreen(enemyMidpoint)


                draw.Text( 500, 540, "pitch ".. tostring(DPS) )

                if enemyScreenPos ~= nil then
                    local boxWidth = width
                    local boxHeight = height
                    local boxX = enemyScreenPos[1] + sideoffset
                    local boxY = enemyScreenPos[2] - boxHeight / 2 + upoffset + boxHeight / 2
    
                        -- Get the current health and maximum health of the player
                    CurrentValue = p:GetHealth()
                    Maxvalue = p:GetMaxHealth()

                    -- Set the color to black and fill the background with it
                    draw.Color(0, 0, 0, 255)
                    draw.FilledRect(math.floor(boxX), math.floor(boxY), math.floor(boxX + boxWidth), math.floor(boxY + boxHeight))

                    -- Set the color to white and draw an outline around the box
                    draw.Color(255, 255, 255, 255)
                    draw.OutlinedRect(math.floor(boxX), math.floor(boxY), math.floor(boxX + boxWidth), math.floor(boxY + boxHeight))

                    -- Set the font to use and color for text to white
                    draw.SetFont(myfont)
                    draw.Color(255, 255, 255, 255)

                    -- Calculate the percentage of health remaining
                    local percentage = CurrentValue / Maxvalue * 100

                    -- Format the percentage with one decimal point
                    local percent = string.format("%.0f", percentage)

                    -- Add the percent symbol to the string
                    local text = tostring(percent) .. " %"
                    local text1 = tostring(DPS) .. " DPS"
                    -- Get the width and height of the text
                    local textWidth, textHeight = draw.GetTextSize(text)

                    -- Calculate the position of the text to center it inside the box
                    local textX = boxX + (boxWidth - textWidth) / 2
                    local textY = boxY + (boxHeight - textHeight) / 2

                   
   
                        -- Change the color of the health bar based on the percentage of health remaining
                        if percentage >= 50 then
                            -- Health is above or equal to 50%, set the color to green
                            draw.Color(0, 255, 0, 255)
                        else
                            -- Health is below 50%, set the color to red
                            draw.Color(math.floor(-percentage), 0, 0, 255)
                        end

                    -- Draw an outline around the health bar
                    draw.Color(255, 255, 255, 255)
                    draw.OutlinedRect(math.floor(boxX), math.floor(boxY + boxHeight), math.floor(boxX + boxWidth), math.floor(boxY + boxHeight + 7))
                    -- Fill the health bar with a color based on how much health the player has remaining
                    draw.FilledRect(math.floor(boxX), math.floor(boxY + boxHeight), math.floor(boxX + boxWidth * CurrentValue / Maxvalue), math.floor(boxY + boxHeight + 7))

                    -- Draw the text inside the box
                    if DPS ~= nil then
                        draw.Text(math.floor(textX), math.floor(textY - 20), text1)
                    end
                        draw.Text(math.floor(textX), math.floor(textY), text)
                    
                    
                    

                end
            end
        end
    end
    
    
    
    
    
    
    
end

callbacks.Register("Draw", "unique_draw_hook", draw_handler)
callbacks.Register("FireGameEvent", "unique_event_hook", event_hook)