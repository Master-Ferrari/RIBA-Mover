RIBAMover.Settings = {}
RIBAMover.Settings.Path = (RIBAMover.Path .. "/Lua/settings.json")
RIBAMover.Settings.File = json.parse(File.Read(RIBAMover.Settings.Path))
RIBAMover.Settings.Local = {}
RIBAMover.Settings.Callback = function() print("fsdfsdf") end

RIBAMover.Settings.WriteJSON = function()
    File.Write(RIBAMover.Settings.Path, json.serialize(RIBAMover.Settings.Local))
end

RIBAMover.Settings.ReadJSON = function ()
    RIBAMover.Settings.File = json.parse(File.Read(RIBAMover.Settings.Path))
    for key,value in pairs(RIBAMover.Settings.File) do
        RIBAMover.Settings.Local[key]=value==true
    end
end

RIBAMover.Settings.Request = function ()
    if CLIENT then
        local netMsg = Networking.Start("SettingsRequestMSG");
        netMsg.WriteBoolean(true)
        Networking.Send(netMsg)
    end
end
--Response
if SERVER then
    Networking.Receive("SettingsRequestMSG", function(message, client)
        RIBAMover.Settings.File = json.parse(File.Read(RIBAMover.Settings.Path))
        local netMsg = Networking.Start("SettingsResponseMSG");
        local count = 0
        for k, v in pairs(RIBAMover.Settings.File) do
            count = count+1
        end
        netMsg.WriteInt16(count)
        -- print(count)
        for key, value in pairs(RIBAMover.Settings.File) do
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
        RIBAMover.Settings.Local = {}
        local lenght = msg.ReadInt16()
        for i = 1, lenght do
            key = msg.ReadString()
            RIBAMover.Settings.Local[key]=msg.ReadBoolean()
        end 
        RIBAMover.Settings.Callback()
    end)
end

RIBAMover.Settings.Update = function (callback)
    if Game.IsSingleplayer or SERVER then
        RIBAMover.Settings.ReadJSON()
        callback()
    else
        RIBAMover.Settings.Callback = callback
        RIBAMover.Settings.Request()
    end
end

RIBAMover.Settings.Check = function (option)
    return RIBAMover.Settings.Local[option]==true
end
