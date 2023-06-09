--[[
    Hologram indicators
    author: titaniummachine1 / 
    credits:
    pred#2448
]]

local floor = math.floor
local x, y = draw.GetScreenSize()
local font_calibri = draw.CreateFont("Calibri", 18, 18)

local victim
local attacker
local localplayer
local damage
local iscrit
local health
local ping
local dps = 0


local function event_hook(ev)
    if ev:GetName() ~= "player_hurt" then return end -- only allows player_hurt event go through
    victim = entities.GetByUserID(ev:GetInt("userid"))
    attacker = entities.GetByUserID(ev:GetInt("attacker"))
    damage = ev:GetInt("damageamount")
    iscrit = ev:GetString("crit") == 1 and true or false
    health = ev:GetInt("health")
    ping = entities.GetPlayerResources():GetPropDataTableInt("m_iPing")[victim:GetIndex()]
end

local last_tick = globals.TickCount()
local damage_queue = {}

local function OnCreateMove()
    local current_tick = globals.TickCount()
    local tick_diff = current_tick - last_tick
    if #damage_queue >= 200 then
        table.remove(damage_queue, 1)
    end
    if damage == nil then
        damage = 0
    end
    table.insert(damage_queue, damage)
    if tick_diff >= 1 then
        last_tick = current_tick
        local total_damage = 0
        for _, dmg in ipairs(damage_queue) do
            total_damage = total_damage + dmg
        end
        dps = total_damage / tick_diff
        DPS = dps
    end
    damage = 0 -- reset damage to 0 at the end of each call
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
    local height = 40
    
    local input_offsetY = 0
    local input_offsetX = 0

    local CurrentValue
    local Maxvalue

    for i, p in ipairs(players) do
        if p:IsAlive() and not p:IsDormant() and pLocal:GetTeamNumber() ~= p:GetTeamNumber() then
            local screenPos = client.WorldToScreen(p:GetAbsOrigin())
            if screenPos ~= nil then
                local pLocalPos = pLocal:GetAbsOrigin()
                local distance = (pLocalPos - p:GetAbsOrigin()):Length()
                if distance > 500 then goto continue end

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

                   
   


                    -- Draw an outline around the health bar
                    draw.Color(255, 255, 255, 255)
                    draw.OutlinedRect(math.floor(boxX), math.floor(boxY + boxHeight), math.floor(boxX + boxWidth), math.floor(boxY + boxHeight + 8))
                    -- Fill the health bar with a color based on how much health the player has remaining
                                            -- Change the color of the health bar based on the percentage of health remaining
                        if percentage >= 50 then
                            -- Health is above or equal to 50%, set the color to green
                            draw.Color(0, 255, 0, 255)
                        else
                            -- Health is below 50%, set the color to red
                            draw.Color(255, 0, 0, 255)
                        end

                        local CurrentValue2 = CurrentValue

                        if CurrentValue > Maxvalue then
                            while CurrentValue2 > Maxvalue do
                                CurrentValue2 = CurrentValue2 - Maxvalue
                            end
                        end

                        local dodraw1 = false

                        if percentage <= 200 and percentage > 100 then
                            draw.Color(0, 255, 0, 255) -- green
                            dodraw1 = true
                        elseif percentage >= 200 then
                            draw.Color(255, 255, 0, 255) -- yellow
                            dodraw1 = true
                        else
                            draw.Color(0, 255, 0, 255) -- green
                            dodraw1 = false
                        end
                        if dodraw1 == true then draw.FilledRect(math.floor(boxX + 1), math.floor(boxY + boxHeight), math.floor(boxX + boxWidth - 1), math.floor(boxY + boxHeight + 7)) end

                        if percentage <= 200 and percentage > 100 then
                            draw.Color(0, 255, 255, 255)
                        elseif percentage >= 200 then
                            draw.Color(0, 255, 255, 255)
                        elseif percentage > 50 then
                            draw.Color(0, 255, 0, 255)
                        else
                            draw.Color(255, 0, 0, 255) -- Red
                        end
                        draw.FilledRect(math.floor(boxX + 1), math.floor(boxY + boxHeight), math.floor(boxX - 1 + boxWidth * CurrentValue2 / Maxvalue), math.floor(boxY + boxHeight + 7))

                        
                        

                        input_offsetY = -10
                        input_offsetX = 0
                        draw.Text(math.floor(textX - input_offsetX), math.floor(textY - input_offsetY), text)
    
                        -- Set the font to use and color for text to white
                        draw.SetFont(myfont)
                        draw.Color(255, 255, 255, 255)
                        input_offsetY = 10
                        input_offsetX = 0
                        -- Draw the text inside the box
                        if DPS ~= nil then
                            draw.Text(math.floor(textX - input_offsetX - 10), math.floor(textY - input_offsetY), text1)
                        end

                end
                ::continue::
            end
        end
    end
end

callbacks.Register("CreateMove", "MCT_CreateMove", OnCreateMove)             -- Register the "CreateMove" callback
callbacks.Register("Draw", "unique_draw_hook", draw_handler)
callbacks.Register("FireGameEvent", "unique_event_hook", event_hook)