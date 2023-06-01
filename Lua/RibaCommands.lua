local ValidArguments = {"EditNotAttachableItems","EditMachines","EditDoors","EditLadders","Rotation","ChangeOfDepth","Flipping","Movement"}

Game.AddCommand("ribamoverset", "[option] [true/false] . Options: ".. table.concat(ValidArguments, ", ") ..".", function (args)

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
    
    -- sender.HasPermission(0x80)
end, function() return {ValidArguments} end)

Game.AddCommand("ribamoverlist", "Shows the current settings of the RIBA Mover.", function (args)
    RIBAMover.Settings.Update(function()
        for k,v in pairs(RIBAMover.Settings.Local)do
            print(tostring(k).." is "..tostring(v))
        end
    end)
end)