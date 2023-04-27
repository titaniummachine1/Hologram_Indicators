--[[
    animated hitlog recoded
    remade animation
    author: pred#2448
]]

local queue = {}
local floor = math.floor
local x, y = draw.GetScreenSize()
local font_calibri = draw.CreateFont("Calibri", 18, 18)

local function event_hook(ev)
    if ev:GetName() ~= "player_hurt" then return end -- only allows player_hurt event go through
    --declare variables
    --to get all structures of event: https://wiki.alliedmods.net/Team_Fortress_2_Events#player_hurt
    
    local victim_entity = entities.GetByUserID(ev:GetInt("userid"))
    local attacker = entities.GetByUserID(ev:GetInt("attacker"))
    local localplayer = entities.GetLocalPlayer()
    local damage = ev:GetInt("damageamount")
    local iscrit = ev:GetString("crit") == 1 and true or false
    local health = ev:GetInt("health")
    local ping = entities.GetPlayerResources():GetPropDataTableInt("m_iPing")[victim_entity:GetIndex()]

    --if attacker ~= localplayer then return end
    --insert table
    table.insert(queue, {
        string = string.format("Hit %s for %d damage (%d health remaining)", victim_entity:GetName(), damage, health, iscrit, ping),
        delay = globals.RealTime() + 5.5,
        alpha = 0,
    })

    printc(100, 255, 100, 255, string.format("[LMAOBOX] Hit %s for %d damage (%d health remaining)", victim_entity:GetName(), damage, health, iscrit, ping))
end

local function paint_logs()
    draw.SetFont(font_calibri)
    for i, v in pairs(queue) do
        local alpha = floor(v.alpha)
        local text = v.string
        local y_pos = floor(y / 2) + (i * 20)
        local players = entities.FindByClass("CTFPlayer")
        --for players 
        --local enemypos = 
        draw.Color(255, 255, 255, alpha)
        draw.Text(700, y_pos - 100, text)
    end
end

local function anim()
    for i, v in pairs(queue) do
        if globals.RealTime() < v.delay then --checks if delay is over or not
            v.alpha = math.min(v.alpha + 1, 255) --fade in animation
        else
            v.string = string.sub(v.string, 1, string.len(v.string) - 1) --removes last character
            if 0 >= string.len(v.string) then
                table.remove(queue, i) --if theres no text left, remove the table
            end
        end
    end
end

local myfont = draw.CreateFont( "Verdana", 16, 800 )
local function draw_handler()
    paint_logs()
    anim()
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
    local sideoffset = 40
    local upoffset = -70
    local width = 100
    local height = 100
    
    for i, p in ipairs(players) do
        if p:IsAlive() and not p:IsDormant() then
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
                if enemyScreenPos ~= nil then
                    local boxWidth = width
                    local boxHeight = height
                    local boxX = enemyScreenPos[1] + sideoffset
                    local boxY = enemyScreenPos[2] - boxHeight / 2 + upoffset + boxHeight / 2
    
                    draw.Color(0, 0, 0, 255)
                    draw.FilledRect(math.floor(boxX), math.floor(boxY), math.floor(boxX + boxWidth), math.floor(boxY + boxHeight))
                    draw.Color(255, 255, 255, 255)
                    draw.OutlinedRect(math.floor(boxX), math.floor(boxY), math.floor(boxX + boxWidth), math.floor(boxY + boxHeight))
                    draw.SetFont(myfont)
                    draw.Color(255, 255, 255, 255)
                    local currentHealth = p:GetHealth()
                    local maxHealth = p:GetMaxHealth()
                    local percentage = currentHealth / maxHealth * 100
                    local percent = string.format("%.1f", percentage) -- format the percentage with one decimal point
                    local text = tostring(percent) .. "%" -- add the percent symbol to the string
                    local textWidth, textHeight = draw.GetTextSize(text)
                    local textX = boxX + (boxWidth - textWidth) / 2
                    local textY = boxY + (boxHeight - textHeight) / 2
                    draw.FilledRect(math.floor(boxX), math.floor(boxY + boxHeight), math.floor(boxX + boxWidth * currentHealth / maxHealth), math.floor(boxY + boxHeight + 5))
                    draw.OutlinedRect(math.floor(boxX), math.floor(boxY + boxHeight), math.floor(boxX + boxWidth), math.floor(boxY + boxHeight + 5))
                    draw.Text(math.floor(textX), math.floor(textY), text)
                    
                    
                    

                end
            end
        end
    end
    
    
    
    
    
    
    
end

callbacks.Register("Draw", "unique_draw_hook", draw_handler)
callbacks.Register("FireGameEvent", "unique_event_hook", event_hook)