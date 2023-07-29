local ValidArguments = {"EditNotAttachableItems","EditMachines","EditDoors","EditLadders","EditReactors",
                        "Rotation","ChangeOfDepth","Flipping","Movement"}

RIBAMover.Commands = {}

RIBAMover.Commands.ribamoverlist = function(client) 

    if not Game.RoundStarted then
        print("start the round first")
        return
    end

    if not Game.IsSingleplayer then 
        if not RIBAMover.BitCheck(client.Permissions,128) then
            RIBAMover.PersonalMessage(client.Name, "You`re not permitted to use console commands")
            return
        end 
    end

    RIBAMover.Settings.Update(function()
        for k,v in pairs(RIBAMover.Settings.Local)do
            RIBAMover.PersonalMessage(client.Name,tostring(k).." is "..tostring(v))
        end
    end)
end

RIBAMover.Commands.ribamoverset = function(client, args) 
    
    if not Game.RoundStarted then
        print("start the round first")
        return
    end

    if not Game.IsSingleplayer then 
        if not RIBAMover.BitCheck(client.Permissions,128) then
            RIBAMover.PersonalMessage(client.Name, "You`re not permitted to use console commands")
            return
        end 
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
end 




Game.AddCommand("ribamoverlist", "Shows the current settings of the RIBA Mover.", function (args) 
    if not Game.IsSingleplayer then
        print("You`re not permitted to use the command \"ribamoverlist\".")
        return
    end
    RIBAMover.Commands.ribamoverlist("nil")
end, function() return {""} end)

Game.AddCommand("ribamoverset", "[option] [true/false] . Options: ".. table.concat(ValidArguments, ", ") ..".", function (args)
    if not Game.IsSingleplayer then
        print("You`re not permitted to use the command \"ribamoverset\".")
        return
    end
    RIBAMover.Commands.ribamoverset("nil", args)
end, function() return {ValidArguments} end)



if CLIENT then return end

Game.AssignOnClientRequestExecute("ribamoverlist", function(client, cursor, args) 
    RIBAMover.Commands.ribamoverlist(client)
end)

Game.AssignOnClientRequestExecute("ribamoverset", function(client, cursor, args) 
    RIBAMover.Commands.ribamoverset(client, args)
end)