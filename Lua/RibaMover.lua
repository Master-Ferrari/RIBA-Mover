local FocusedItem

local EditableErrorPrint = function (Item,string)
    print("You can't interact with \""..tostring(Item.Name).."\" because "..string..".\n" ..
          "This restriction can be disabled with the console command \"ribamoverset\" or in the host's settings.json")
end

RIBAMover.EditableCheck = function(Item)
    
    if not RIBAMover.Settings.Check("EditNotAttachableItems") then
        local isAttachable = RIBAMover.GetAttributeValueFromItem(Item, "Holdable", "attachable")=="true"
        if isAttachable then
            EditableErrorPrint(Item, "this item not detachable")
            return false
        end
    end

    if not RIBAMover.Settings.Check("EditMachines") then
        local CategoryNames = RIBAMover.GetCategoryNames(Item)
        local isMachine = false
        for k,v in pairs(CategoryNames) do
            if v == "Machine" then
                isMachine = true
                break
            end
        end
        if isMachine then
            EditableErrorPrint(Item, "it is Machine category item")
            return false
        end
    end

    if not RIBAMover.Settings.Check("EditLadders") then
        local isLadder = Item.IsLadder
        if isLadder then
            EditableErrorPrint(Item, "it is Ladder")
            return false
        end
    end

    if not RIBAMover.Settings.Check("EditDoors") then
        local isLadder = RIBAMover.Component(Item,"Door")~=nil
        if isLadder then
            EditableErrorPrint(Item, "it is Door")
            return false
        end
    end

    if not RIBAMover.Settings.Check("EditReactors") then
        local isLadder = RIBAMover.Component(Item,"Reactor")~=nil
        if isLadder then
            EditableErrorPrint(Item, "it is Reactor")
            return false
        end
    end


    return true
end



if SERVER then

--     Hook.Add("loaded", "RIBAMove", function()
--         Networking.Receive("MoveMSG", function(msg, sender)
--             local Item = Entity.FindEntityByID(tonumber(msg.ReadString()))
--             local H = msg.ReadInt16()
--             local V = msg.ReadInt16()
--             Item.Move(Vector2(H, V), false)
--         end)
--     end)

--     Hook.Add("loaded", "RIBAFlip", function()
--         Networking.Receive("FlipMSG", function(msg, sender)
--             local Item = Entity.FindEntityByID(tonumber(msg.ReadString()))
--             local X = msg.ReadBoolean()
--             if X then
--                 Item.FlipX(false)
--             else
--                 Item.FlipY(false)
--             end
--         end)
--     end)

--     Hook.Add("loaded", "RIBADepth", function()
--         Networking.Receive("DepthMSG", function(msg, sender)
--             local Item = Entity.FindEntityByID(tonumber(msg.ReadString()))
--             local newDepth = msg.ReadInt16()
--             Item.SpriteDepth = newDepth
--         end)
--     end)

--     Hook.Add("loaded", "RIBARotate", function()
--         Networking.Receive("RotateMSG", function(msg, sender)
--             local Item = Entity.FindEntityByID(tonumber(msg.ReadString()))
--             local newRotate = msg.ReadInt16()
--             Item.Rotation = newRotate
--         end)
--     end)

    -- return
-- end

else

    -- RIBAMover.RotateAttached = function(value, Item)
    --     if true then
    --         if (not Game.IsSingleplayer) then
    --             local netMsg = Networking.Start("RotateMSG");
    --             netMsg.WriteString(tostring(Item.ID))
    --             netMsg.WriteInt16(value)
    --             Networking.Send(netMsg)
    --         end
    --         FocusedItem.Rotation = value
    --     end
    -- end

    -- RIBAMover.DepthAttached = function(value, Item)
    --     if true then
    --         local newSpriteDepth = math.round(value/1000.0, 3)
    --         if (not Game.IsSingleplayer) then
    --             local netMsg = Networking.Start("DepthMSG");
    --             netMsg.WriteString(tostring(Item.ID))
    --             netMsg.WriteInt16(newSpriteDepth)
    --             Networking.Send(netMsg)
    --         end
    --         FocusedItem.SpriteDepth = newSpriteDepth
    --     end
    -- end

    -- RIBAMover.moveAttached = function(H, V, Item)
    --     if (Game.IsSingleplayer) then
    --         Item.Move(Vector2(H, V), false)
    --     else
    --         local netMsg = Networking.Start("MoveMSG");
    --         netMsg.WriteString(tostring(Item.ID))
    --         netMsg.WriteInt16(H)
    --         netMsg.WriteInt16(V)
    --         Networking.Send(netMsg)
    --         Item.Move(Vector2(H, V), false)
    --     end
    -- end

    -- RIBAMover.flipAttached = function(X, Item)
    --     if (Game.IsSingleplayer) then
    --         if X then
    --             Item.FlipX(false)
    --         else
    --             Item.FlipY(false)
    --         end
    --     else
    --         local netMsg = Networking.Start("FlipMSG");
    --         netMsg.WriteString(tostring(Item.ID))
    --         netMsg.WriteBoolean(X)
    --         Networking.Send(netMsg)
    --         if X then
    --             Item.FlipX(false)
    --         else
    --             Item.FlipY(false)
    --         end
    --     end
    -- end


    -- our main frame where we will put our custom GUI
    local frame = GUI.Frame(GUI.RectTransform(Vector2(1, 1)), nil)  --ваще весь экран
    frame.CanBeFocused = false

    MainMenu = GUI.Frame(GUI.RectTransform(Vector2(1, 1), frame.RectTransform, GUI.Anchor.Center), nil)  --наш слой на экране
    MainMenu.CanBeFocused = false
    MainMenu.Visible = false

    RIBAMover.decoratorUI = function(FocusedItem)
        -- menu frame
        MainMenu.ClearChildren()
        -- put a button that goes behind the menu content, so we can close it when we click outside
        local closeButton = GUI.Button(GUI.RectTransform(Vector2(1, 1), MainMenu.RectTransform, GUI.Anchor.Center),
                                       "", GUI.Alignment.Center, nil)  --кнопка закрыть всё
        closeButton.OnClicked = function ()
            MainMenu.Visible = not MainMenu.Visible
        end

        local menuContent = GUI.Frame(GUI.RectTransform(Vector2(0.18, 0.115), MainMenu.RectTransform, GUI.Anchor.BottomCenter))

        menuContent.RectTransform.RelativeOffset = Vector2(0, 0.1)

        local menuH = GUI.ListBox(GUI.RectTransform(Vector2(1, 1), menuContent.RectTransform, GUI.Anchor.BottomCenter),
                                  true, Color(0,0,0,0), nil) -- содержимое горизонталь

        local imageFrame = GUI.Frame(GUI.RectTransform(Point(100, 100), menuH.Content.RectTransform, GUI.Anchor.CenterLeft),
                                     "GUITextBox", Color(0,0,0,0), "InnerFrame")  ---иконка
        imageFrame.RectTransform.RelativeOffset = Vector2(0.062, 0)

        local sprite = FocusedItem.Prefab.InventoryIcon
        if sprite == nil then
            sprite = FocusedItem.Prefab.Sprite
        end 
        if sprite==nil then
            sprite = ItemPrefab.GetItemPrefab("poop").Sprite
        end
        local image = GUI.Image(GUI.RectTransform(Point(100, 100), imageFrame.RectTransform, GUI.Anchor.Center), sprite)
        imageFrame.CanBeFocused = false

        --правая часть
        local menuHV = GUI.ListBox(GUI.RectTransform(Vector2(0.6, 0.9), menuH.Content.RectTransform, GUI.Anchor.CenterLeft),
                                   false, Color(0,0,0,150), "InnerFrame") -- содержимое вертикаль
        menuHV.Color = Color(0,0,0,0)
        menuHV.HoverColor = Color(0,0,0,0)
        menuHV.RectTransform.RelativeOffset = Vector2(0.058, 0)

        --Крутилки
        local menuHVH0 = GUI.ListBox(GUI.RectTransform(Vector2(1, 0.33), menuHV.Content.RectTransform, GUI.Anchor.TopCenter),
                                     true, Color(0,0,0,0), nil) -- содержимое вертикаль
        menuHVH0.RectTransform.RelativeOffset = Vector2(0.018, 0.06)
        menuHVH0.Padding = Vector4(0, 0, 0, 0)
        menuHVH0.Spacing = 3
        menuHVH0.PadBottom = false
        menuHVH0.CanBeFocused = false

        if RIBAMover.Settings.Check("ChangeOfDepth") then
            local depthInput = GUI.NumberInput(GUI.RectTransform(Vector2(RIBAMover.Settings.Check("Rotation") and 0.46 or 0.95, 0.5),
                                               menuHVH0.Content.RectTransform), NumberType.Int) -- крутилка
            depthInput.MinValueInt = 001
            depthInput.MaxValueInt = 899
            depthInput.valueStep = 10
            local depthInt = math.floor(FocusedItem.SpriteDepth*1000.0)
            if depthInt ~= nil then
                depthInput.IntValue = depthInt
            end
            depthInput.OnValueChanged = function ()
                -- RIBAMover.DepthAttached(depthInput.IntValue, FocusedItem)
                RIBAMover.Shiz.Do("depth", {tostring(FocusedItem.ID),depthInput.IntValue})
            end
        end
        if RIBAMover.Settings.Check("Rotation") then
            local degreesInput = GUI.NumberInput(GUI.RectTransform(Vector2(RIBAMover.Settings.Check("ChangeOfDepth") and 0.46 or 0.95, 0.4),
                                                 menuHVH0.Content.RectTransform), NumberType.Int) -- крутилка
            degreesInput.MinValueInt = 000
            degreesInput.MaxValueInt = 360
            degreesInput.valueStep = 1
            local degreesInt = math.floor(FocusedItem.Rotation)
            if degreesInt ~= nil then
                degreesInput.IntValue = degreesInt
            end
            degreesInput.OnValueChanged = function ()
                -- RIBAMover.RotateAttached(degreesInput.IntValue, FocusedItem)
                RIBAMover.Shiz.Do("rotate", {tostring(FocusedItem.ID),degreesInput.IntValue})
            end
        end

        if RIBAMover.Settings.Check("Flipping") then
            --Отражалки
            local menuHVH1 = GUI.ListBox(GUI.RectTransform(Vector2(0.95, 0.2), menuHV.Content.RectTransform, GUI.Anchor.TopCenter),
                                         true, Color(0,0,0,0), nil) -- содержимое вертикаль
            menuHVH1.Color = Color(0,0,0,0)
            menuHVH1.HoverColor = Color(0,0,0,0)
            menuHVH1.Padding = Vector4(0, 0, 0, 0)
            menuHVH1.CanBeFocused = false

            local FlipXButton = GUI.Button(GUI.RectTransform(Vector2(0.5, 1), menuHVH1.Content.RectTransform),
                                           "FlipX", GUI.Alignment.Center, "GUIButtonSmall")
            FlipXButton.OnClicked = function ()
                RIBAMover.Shiz.Do("flip", {tostring(FocusedItem.ID),true})
                -- RIBAMover.flipAttached(true, FocusedItem)
            end
            local FlipXButton = GUI.Button(GUI.RectTransform(Vector2(0.5, 1), menuHVH1.Content.RectTransform),
                                           "FlipY", GUI.Alignment.Center, "GUIButtonSmall")
            FlipXButton.OnClicked = function ()
                RIBAMover.Shiz.Do("flip", {tostring(FocusedItem.ID),false})
                -- RIBAMover.flipAttached(false, FocusedItem)
            end
        end

        if RIBAMover.Settings.Check("Movement") then
            --Большие кнопочки
            local menuHVH2 = GUI.ListBox(GUI.RectTransform(Vector2(0.95, 0.2), menuHV.Content.RectTransform, GUI.Anchor.TopCenter), true, Color(0,0,0,0), nil) -- содержимое вертикаль
            menuHVH2.Color = Color(0,0,0,0)
            menuHVH2.HoverColor = Color(0,0,0,0)
            menuHVH2.Padding = Vector4(0, 0, 0, 0)
            menuHVH2.CanBeFocused = false

            local leftButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform),
                                          "L", GUI.Alignment.Center, "GUIButtonSmall")
            leftButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),-10,0})
                -- RIBAMover.moveAttached(-10,0,FocusedItem)
            end
            local rightButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform),
                                           "R", GUI.Alignment.Center, "GUIButtonSmall")
            rightButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),10,0})
                -- RIBAMover.moveAttached(10,0,FocusedItem)
            end
            local upButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform), 
                                        "U", GUI.Alignment.Center, "GUIButtonSmall")
            upButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),0,10})
                -- RIBAMover.moveAttached(0,10,FocusedItem)
            end
            local downButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform), 
                                          "D", GUI.Alignment.Center, "GUIButtonSmall")
            downButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),0,-10})
                -- RIBAMover.moveAttached(0,-10,FocusedItem)
            end

            --Маленькие кнопочки
            local menuHVH2 = GUI.ListBox(GUI.RectTransform(Vector2(0.95, 0.2), menuHV.Content.RectTransform, GUI.Anchor.TopCenter), true, Color(0,0,0,0), nil) -- содержимое вертикаль
            menuHVH2.Color = Color(0,0,0,0)
            menuHVH2.HoverColor = Color(0,0,0,0)
            menuHVH2.Padding = Vector4(0, 0, 0, 0)
            menuHVH2.CanBeFocused = false

            local leftButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform), "l", GUI.Alignment.Center, "GUIButtonSmall")
            leftButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),-1,0})
                -- RIBAMover.moveAttached(-1,0,FocusedItem)
            end
            local rightButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform), "r", GUI.Alignment.Center, "GUIButtonSmall")
            rightButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),1,0})
                -- RIBAMover.moveAttached(1,0,FocusedItem)
            end
            local upButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform), "u", GUI.Alignment.Center, "GUIButtonSmall")
            upButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),0,1})
                -- RIBAMover.moveAttached(0,1,FocusedItem)
            end
            local downButton = GUI.Button(GUI.RectTransform(Vector2(0.25, 1), menuHVH2.Content.RectTransform), "d", GUI.Alignment.Center, "GUIButtonSmall")
            downButton.OnClicked = function ()
                RIBAMover.Shiz.Do("move", {tostring(FocusedItem.ID),0,-1})
                -- RIBAMover.moveAttached(0,-1,FocusedItem)
            end
        end
        MainMenu.Visible = true
    end

    Hook.Patch("Barotrauma.GameScreen", "AddToGUIUpdateList", function()
        frame.AddToGUIUpdateList()
    end)


    Hook.Add("RIBAMoverAlways", "RIBAMoverAlways", function(effect, deltaTime, item, targets, worldPosition) --отключить если далеко
        if FocusedItem~=nil and MainMenu.Visible then
--item.ParentInventory and 
            if item.ParentInventory == nil then return end
            local owner = item.ParentInventory.Owner
            print (owner.Name)
            if owner~=nil then
                IsMoverInHands = false
                for k,v in owner.HeldItems do
                    if item.Prefab.Identifier.Value == k.Prefab.Identifier.Value then
                        IsMoverInHands = true
                    end
                end
                local distance = RIBAMover.CalculateDistance(owner.WorldPosition, FocusedItem.WorldPosition)
                if distance > item.InteractDistance or not IsMoverInHands then
                    MainMenu.Visible = false
                end
            -- else
            --     MainMenu.Visible = false
            end
        end
    end)

end

Hook.Add("RIBAMoverOnUse", "RIBAMoverOnUse", function(statusEffect, delta, item) --включить интерфейс
    if RIBAMover.ItemOwnerIsPlayer(item) or Game.IsSingleplayer then
        RIBAMover.Settings.Update(function()
            if CLIENT then
                FocusedItem = Character.Controlled.FocusedItem
                if FocusedItem~=nil and RIBAMover.EditableCheck(FocusedItem) then
                    RIBAMover.decoratorUI(FocusedItem)
                end
            end
        end)
    end
end)

