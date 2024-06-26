RIBAMover.Component = function(item, name)
    for _, component in ipairs(item.Components) do
        if component.Name == name then
            return component
        end
    end
    return nil
end

RIBAMover.removePrefixAndSuffix = function(input, prefix, suffix)
    local success, result = pcall(function()
        local startIdx = string.find(input, prefix)
        if startIdx then
            startIdx = startIdx + string.len(prefix)
            local endIdx = string.find(input, suffix, startIdx)
            if endIdx then
                return string.sub(input, startIdx, endIdx - 1)
            end
        end
        return ""
    end)
    if success then
        return result
    else
        return ""
    end
end

RIBAMover.GetAttributeValueFromItem = function(item, targetElement, targetAttribute)
    local success, result = pcall(function()
        local AttributeString = tostring(RIBAMover.Component(item,targetElement).originalElement.GetAttribute(tostring(targetAttribute)))
        return RIBAMover.removePrefixAndSuffix(AttributeString, '"', '"')
    end)
    return success and result or nil
end

-- RIBA.GetAttributeValueFromItemHead = function(item, targetAttribute)
--     -- local success, result = pcall(function()
--         local AttributeString = tostring(item.Prefab.originalElement.GetAttribute(tostring(targetAttribute)))
--         return RIBA.removePrefixAndSuffix(AttributeString, '"', '"')
--     -- end)
--     -- return success and result or nil
-- end

RIBAMover.CalculateDistance = function(frst, scnd)
    local dx = scnd.x - frst.x
    local dy = scnd.y - frst.y
    local distance = math.sqrt(dx^2 + dy^2)
    return distance
end

RIBAMover.SplitString = function (inputString, delimiter)
    local result = {}  -- Результирующая таблица строк
    local startIndex = 1
    local endIndex = 0

    while true do
        endIndex = string.find(inputString, delimiter, startIndex) -- Находим индекс разделителя

        if endIndex == nil then  -- Если разделитель не найден, добавляем оставшуюся часть строки в результат
            table.insert(result, string.sub(inputString, startIndex))
            break
        end

        local substring = string.sub(inputString, startIndex, endIndex - 1) -- Выделяем подстроку до разделителя
        table.insert(result, substring) -- Добавляем подстроку в результат
        startIndex = endIndex + string.len(delimiter) -- Обновляем начальный индекс для следующей итерации
    end

    return result
end

RIBAMover.GetCategoryNames = function(item)
    
    local sum = math.floor(item.Prefab.category)
    local categoryNames = {}

    if sum == 0 then
        table.insert(categoryNames, "None")
    else
        local categories = {
            { name = "Structure", value = 1 },
            { name = "Decorative", value = 2 },
            { name = "Machine", value = 4 },
            { name = "Medical", value = 8 },
            { name = "Weapon", value = 16 },
            { name = "Diving", value = 32 },
            { name = "Equipment", value = 64 },
            { name = "Fuel", value = 128 },
            { name = "Electrical", value = 256 },
            { name = "Material", value = 1024 },
            { name = "Alien", value = 2048 },
            { name = "Wrecked", value = 4096 },
            { name = "ItemAssembly", value = 8192 },
            { name = "Legacy", value = 16384 },
            { name = "Misc", value = 32768 }
        }

        for _, category in ipairs(categories) do
            if bit32.band(sum, category.value) ~= 0 then
                table.insert(categoryNames, category.name)
            end
        end
    end

    return categoryNames
end

RIBAMover.ItemOwnerIsPlayer = function(item)
    if CLIENT then
        OwnerName = item.GetRootInventoryOwner().Name
        if OwnerName == Character.Controlled.Name then
            return true
        end
    end
    return false
end

RIBAMover.BitCheck = function(a, b)
    local bbb = b
    local result = 0
    local bit_position = 1
    while a > 0 and b > 0 do
        local bit_a = a % 2
        local bit_b = b % 2
        if bit_a == 1 and bit_b == 1 then
            result = result + bit_position
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bit_position = bit_position * 2
    end
    return result == bbb
end

RIBAMover.PersonalMessage = function(clientName, MSG)
    if Game.IsSingleplayer or CLIENT then
        print(MSG)
    else 
        local netMsg = Networking.Start("PersonalMSG");
        netMsg.WriteString(clientName)
        netMsg.WriteString(MSG)
        Networking.Send(netMsg)
    end
end

if CLIENT then
    Networking.Receive("PersonalMSG", function(msg, sender)
        
        -- local clientName = msg.ReadString()
        if Game.RoundStarted and Character.Controlled.Name == msg.ReadString() then
            print(msg.ReadString())
        end

    end)
end
