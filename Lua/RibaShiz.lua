RIBAMover.Shiz = {}

RIBAMover.Shiz.Array = {  --fancy table. args types / functions

    move   = {{"String", "Int16", "Int16"},fn = function(ItemString, H, V) 
        local Item = Entity.FindEntityByID(tonumber(ItemString))
        Item.Move(Vector2(H, V), false)
    end},

    flip   = {{"String", "Boolean"},fn = function(ItemString, X)
        local Item = Entity.FindEntityByID(tonumber(ItemString))
        if X then
            Item.FlipX(false)
        else
            Item.FlipY(false)
        end
    end},

    depth  = {{"String", "Int16"},fn = function(ItemString, newDepth)
        local Item = Entity.FindEntityByID(tonumber(ItemString))
        Item.SpriteDepth = math.round(newDepth/1000.0, 3)
    end},

    rotate = {{"String", "Int16"},fn = function(ItemString, newRotate)
        local Item = Entity.FindEntityByID(tonumber(ItemString))
        Item.Rotation = newRotate
    end}
}

--main function. client tells to the server which function to use (and the server tells this backward to clients)
RIBAMover.Shiz.Do = function(funcName, args)
    if (Game.IsSingleplayer) then
        RIBAMover.Shiz.Array[funcName].fn(table.unpack(args))
    else
        local netMsg = Networking.Start("ShizMSG");
        --first arg is name of target function, others is others
        netMsg.WriteString(funcName) 
        for _, arg in ipairs(args) do

            local argType = type(arg)
            if argType == "number" then
                netMsg.WriteInt16(arg)
            elseif argType == "string" then
                netMsg.WriteString(arg)
            elseif argType == "boolean" then
                netMsg.WriteBoolean(arg)
            end
            
        end
        Networking.Send(netMsg)
    end
end


if SERVER then
    Hook.Add("loaded", "Shiza", function()
        Networking.Receive("ShizMSG", function(msg, sender)
            local funcName = msg.ReadString()
            
            local argsTable = {}
            local shiza = RIBAMover.Shiz.Array[funcName]

            for _, type in ipairs(shiza[1]) do
                
                if type == "Int16" then
                    table.insert(argsTable, msg.ReadInt16())
                elseif type == "String" then
                    table.insert(argsTable, msg.ReadString())
                elseif type == "Boolean" then
                    table.insert(argsTable, msg.ReadBoolean())
                end
            end



            local netMsg = Networking.Start("2ShizMSG2");
            --send instructions to clients
            netMsg.WriteString(funcName) 
            for _, arg in ipairs(argsTable) do
                local argType = type(arg)
                if argType == "number" then
                    netMsg.WriteInt16(arg)
                elseif argType == "string" then
                    netMsg.WriteString(arg)
                elseif argType == "boolean" then
                    netMsg.WriteBoolean(arg)
                end
            end
            Networking.Send(netMsg)

            shiza.fn(table.unpack(argsTable)) --executing
        end)
    end)
end


if CLIENT then
    Hook.Add("loaded", "Shiza", function()
        Networking.Receive("2ShizMSG2", function(msg, sender)
            local funcName = msg.ReadString()
            
            local argsTable = {}
            local shiza = RIBAMover.Shiz.Array[funcName]
            for _, type in ipairs(shiza[1]) do
                
                if type == "Int16" then
                    table.insert(argsTable, msg.ReadInt16())
                elseif type == "String" then
                    table.insert(argsTable, msg.ReadString())
                elseif type == "Boolean" then
                    table.insert(argsTable, msg.ReadBoolean())
                end
                
            end

            shiza.fn(table.unpack(argsTable)) --executing
        end)
    end)
end


