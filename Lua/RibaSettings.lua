RIBA.Settings = {}
RIBA.Settings.Path = (RIBA.Path .. "/Lua/settings.json")
RIBA.Settings.File = json.parse(File.Read(RIBA.Settings.Path))
RIBA.Settings.Local = {}
RIBA.Settings.Callback = function() print("fsdfsdf") end

RIBA.Settings.WriteJSON = function()
    File.Write(RIBA.Settings.Path, json.serialize(RIBA.Settings.Local))
end

RIBA.Settings.ReadJSON = function ()
    RIBA.Settings.File = json.parse(File.Read(RIBA.Settings.Path))
    for key,value in pairs(RIBA.Settings.File) do
        RIBA.Settings.Local[key]=value==true
    end
end

RIBA.Settings.Request = function ()
    if CLIENT then
        local netMsg = Networking.Start("SettingsRequestMSG");
        netMsg.WriteBoolean(true)
        Networking.Send(netMsg)
    end
end
--Response
if SERVER then
    Networking.Receive("SettingsRequestMSG", function(message, client)
        RIBA.Settings.File = json.parse(File.Read(RIBA.Settings.Path))
        local netMsg = Networking.Start("SettingsResponseMSG");
        local count = 0
        for k, v in pairs(RIBA.Settings.File) do
            count = count+1
        end
        netMsg.WriteInt16(count)
        -- print(count)
        for key, value in pairs(RIBA.Settings.File) do
            netMsg.WriteString(tostring(key))
            netMsg.WriteBoolean(value==true)
        end
        Networking.Send(netMsg, client.Connection)
    end)
end
--Listen
if CLIENT then
    Networking.Receive("SettingsResponseMSG", function(msg, sender)
        -- print("ololo")
        RIBA.Settings.Local = {}
        local lenght = msg.ReadInt16()
        for i = 1, lenght do
            key = msg.ReadString()
            RIBA.Settings.Local[key]=msg.ReadBoolean()
        end 
        RIBA.Settings.Callback()
    end)
end

RIBA.Settings.Update = function (callback)
    if (Game.IsSingleplayer) then
        RIBA.Settings.ReadJSON()
        callback()
    else
        RIBA.Settings.Callback = callback
        RIBA.Settings.Request()
    end
end

RIBA.Settings.Check = function (option)
    return RIBA.Settings.Local[option]==true
end
