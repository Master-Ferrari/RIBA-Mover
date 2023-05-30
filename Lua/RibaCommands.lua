local ValidArguments = {"EditNotAttachableItems","EditMachines","Rotation","ChangeOfDepth","Flipping","Movement"}

Game.AddCommand("ribamover", "[".. table.concat(ValidArguments, "/") .."] [true/false]", function (args)

    if args[2] ~= "false" and args[2] ~= "true" then
        print("bad arguments")
        return
    end

    for _, validArg in pairs(ValidArguments) do
        if args[1] == validArg then
            RIBA.Settings.ReadJSON()
            RIBA.Settings.Local[tostring(args[1])] = args[2]=="true"
            RIBA.Settings.WriteJSON()
            print(args[1].." is "..args[2])
            return
        end
    end
    print("bad arguments")
    
    -- sender.HasPermission(0x80)
end, function() return {ValidArguments} end)