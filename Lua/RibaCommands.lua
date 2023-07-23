local ValidArguments = {"EditNotAttachableItems","EditMachines","EditDoors","EditLadders","EditReactors","Rotation","ChangeOfDepth","Flipping","Movement"}

Game.AddCommand("ribamoverset", "[option] [true/false] . Options: ".. table.concat(ValidArguments, ", ") ..".", function (client, args)

    -- if CLIENT then print("Я не СУщаеСТВую") else print ("ясуществую))") end
    
    -- if not client.HasPermission(ClientPermissions.ConsoleCommands) then
    --     print ("you not permited to use console commands")
    --     return
    -- else
    --     print("ololo")
    -- end

    if args[2] ~= "false" and args[2] ~= "true" then
        print("bad arguments")
        return
    end

    for _, validArg in pairs(ValidArguments) do
        if args[1] == validArg then
            RIBAMover.Settings.ReadJSON()
            RIBAMover.Settings.Local[tostring(args[1])] = args[2]=="true"
            RIBAMover.Settings.WriteJSON()
            print(args[1].." is "..args[2])
            return
        end
    end
    print("bad arguments")
    
end, function() return {ValidArguments} end)

Game.AddCommand("ribamoverlist", "Shows the current settings of the RIBA Mover.", function (args)
    RIBAMover.Settings.Update(function()
        for k,v in pairs(RIBAMover.Settings.Local)do
            print(tostring(k).." is "..tostring(v))
        end
    end)
end)