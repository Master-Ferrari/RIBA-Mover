RIBAMover.ShizDo.Array = {  --fancy table. args types/functions
    move   = {{String, Int16, Int16},fn = function(ItemString, H, V) 
        local Item = Entity.FindEntityByID(tonumber(ItemString))
        Item.Move(Vector2(H, V), false)
    end},

    flip   = {{String, Int16, Int16},fn = function(arg1)
    end},

    depth  = {{String, Int16, Int16},fn = function(arg1)
    end},

    rotate = {{String, Int16, Int16},fn = function(arg1)
    end}
}

--main function. client tells to the server which function to use (and the server tells this backward to clients)
RIBAMover.ShizDo = function(funcName, args)
    if (Game.IsSingleplayer) then
        RIBAMover.ShizDo.Array[funcName].fn(table.unpack(args))
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
            local shiza = RIBAMover.ShizDo.Array[funcName]
            for _, type in ipairs(shiza[1]) do
                
                if type == "Int16" then
                    table.insert(argsTable, msg.ReadInt16())
                elseif type == "String" then
                    table.insert(argsTable, msg.ReadString())
                elseif type == "Boolean" then
                    table.insert(argsTable, msg.ReadBoolean())
                end
                
            end

            local netMsg = Networking.Start("ShizMSG2");
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
        Networking.Receive("ShizMSG2", function(msg, sender)
            local funcName = msg.ReadString()
            
            local argsTable = {}
            local shiza = RIBAMover.ShizDo.Array[funcName]
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


RIBAMover.ShizDo("move", {"232352324", 10, 10})
