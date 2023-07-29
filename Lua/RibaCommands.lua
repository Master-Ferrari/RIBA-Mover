local ValidArguments = {"EditNotAttachableItems","EditMachines","EditDoors","EditLadders","EditReactors",
                        "Rotation","ChangeOfDepth","Flipping","Movement"}

Game.AddCommand("ribamoverlist", "Shows the current settings of the RIBA Mover.", function (args) 
    print("You`re not permitted to use the command \"ribamoverlist\"")
end, function() return {""} end)

Game.AddCommand("ribamoverset", "[option] [true/false] . Options: ".. table.concat(ValidArguments, ", ") ..".", function (args)
    print("You`re not permitted to use the command \"ribamoverset\"")
end, function() return {ValidArguments} end)

if CLIENT then return end -----------------------------------------------------------------------------------------------------

Game.AssignOnClientRequestExecute("ribamoverset", function(client, cursor, args) 

    if not Game.RoundStarted then return end

    if not RIBAMover.BitCheck(client.Permissions,128)>0 then
        RIBAMover.PersonalMessage(client.Name, "You`re not permitted to use console commands")
    end

    if args[2] ~= "false" and args[2] ~= "true" then
        RIBAMover.PersonalMessage(client.Name,"bad arguments\nReference: ribamoverset [option] [true/false]\nOptions: "
                                  .. table.concat(ValidArguments, ", "))
        return
    end
    
    for _, validArg in pairs(ValidArguments) do
        if args[1] == validArg then
            RIBAMover.Settings.ReadJSON()
            RIBAMover.Settings.Local[tostring(args[1])] = args[2]=="true"
            RIBAMover.Settings.WriteJSON()
            RIBAMover.PersonalMessage(client.Name,args[1].." is "..args[2])
            return
        end
    end

    RIBAMover.PersonalMessage(client.Name,"bad arguments\nReference: ribamoverset [option] [true/false]\nOptions: "..
                              table.concat(ValidArguments, ", "))
end)

Game.AssignOnClientRequestExecute("ribamoverlist", function(client, cursor, args) 
    RIBAMover.Settings.Update(function()
        for k,v in pairs(RIBAMover.Settings.Local)do
            RIBAMover.PersonalMessage(client.Name,tostring(k).." is "..tostring(v))
        end
    end)
end)