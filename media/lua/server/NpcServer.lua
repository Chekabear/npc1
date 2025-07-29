local npcList = {}

function createNpcAt(x, y, z, followPlayerId)
    local npcId = tostring(math.random(100000,999999))
    local npc = {
        id = npcId,
        x = x,
        y = y,
        z = z,
        follow = followPlayerId,
        state = "follow",
        dialog = "Hi, ich bin ein NPC!"
    }
    npcList[npcId] = npc
    return npc
end

function sendNpcDataToAllClients(npc)
    sendServerCommand("MyNpcMod", "SyncNpc", npc)
end

function updateNpcPositions()
    for _, npc in pairs(npcList) do
        if npc.follow then
            local player = getPlayerByOnlineID(npc.follow)
            if player then
                local dx = player:getX() - npc.x
                local dy = player:getY() - npc.y
                if math.abs(dx) > 1 or math.abs(dy) > 1 then
                    npc.x = npc.x + (dx > 0 and 1 or (dx < 0 and -1 or 0))
                    npc.y = npc.y + (dy > 0 and 1 or (dy < 0 and -1 or 0))
                end
            end
        end
        sendNpcDataToAllClients(npc)
    end
end

Events.EveryTenMinutes.Add(updateNpcPositions)

Events.OnServerCommand.Add(function(module, command, player, args)
    if module ~= "MyNpcMod" then return end
    if command == "SpawnNpc" then
        local npc = createNpcAt(args.x, args.y, args.z, player:getOnlineID())
        sendNpcDataToAllClients(npc)
    elseif command == "NpcTalk" then
        local npc = npcList[args.npcId]
        if npc then
            npc.dialog = args.text or "..."
            sendNpcDataToAllClients(npc)
        end
    end
end)
