RIBA.Settings = {}
RIBA.Settings.File = json.parse(File.Read(RIBA.Path .. "/Lua/settings.json"))
RIBA.Settings.Local = {}

RIBA.Settings.WriteJSON = function()
    File.Write(RIBA.Path .. "/Lua/settings.json", json.serialize(RIBA.Settings.Local))
end

RIBA.Settings.ReadJSON = function ()
    RIBA.Settings.File = json.parse(File.Read(RIBA.Path .. "/Lua/settings.json"))
    if SERVER then
        for key,value in pairs(RIBA.Settings.File) do
            RIBA.Settings.Local[key]=value~=nil and value==true or false
            -- print(tostring(key).." "..tostring(value))
        end
    end
end

RIBA.Settings.Request = function ()
    if CLIENT then
        local netMsg = Networking.Start("SettingsRequestMSG");
        netMsg.WriteBoolean(true)
        Networking.Send(netMsg)
    end
end

RIBA.Settings.Response = function ()
    if SERVER then
        Networking.Receive("SettingsRequestMSG", function(message, client)
            RIBA.Settings.File = json.parse(File.Read(RIBA.Path .. "/Lua/settings.json"))
            local netMsg = Networking.Start("SettingsResponseMSG");
            netMsg.WriteInt16(#RIBA.Settings.File)
            for key, value in pairs(RIBA.Settings.File) do
                netMsg.WriteString(tostring(key))
                netMsg.WriteBoolean(value==true)
            end
            Networking.Send(netMsg, client.Connection)
        end)
    end
end

RIBA.Settings.Listen = function (callback)
    if CLIENT then
        Networking.Receive("SettingsResponseMSG", function(msg, sender)
            print("ololo")
            RIBA.Settings.Local = {}
            local lenght = msg.ReadInt16()
            for i = 1, lenght do
                key = msg.ReadString()
                RIBA.Settings.Local[key]=msg.ReadBoolean()
            end 
            callback()
        end)
    end
end

RIBA.Settings.Update = function (callback)
    -- RIBA.Settings.ReadJSON()
    RIBA.Settings.Request()
    RIBA.Settings.Response()
    RIBA.Settings.Listen(callback)
end

RIBA.Settings.Check = function (option)
    return RIBA.Settings.Local[option]
end
