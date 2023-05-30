RIBA.Component = function(item, name)
    for _, component in ipairs(item.Components) do
        if component.Name == name then
            return component
        end
    end
end

RIBA.removePrefixAndSuffix = function(input, prefix, suffix)
    local success, result = pcall(function()
        local startIdx = string.find(input, prefix)
        if startIdx then
            startIdx = startIdx + string.len(prefix)
            local endIdx = string.find(input, suffix, startIdx)
            if endIdx then
                return string.sub(input, startIdx, endIdx - 1)
            end
        end
        return nil
    end)
    if success then
        return result
    else
        return nil
    end
end

RIBA.GetAttributeValueFromItem = function(item, targetElement, targetAttribute)
    local success, result = pcall(function()
        local AttributeString = tostring(RIBA.Component(item,targetElement).originalElement.GetAttribute(tostring(targetAttribute)))
        return RIBA.removePrefixAndSuffix(AttributeString, '"', '"')
    end)
    return success and result or nil
end

RIBA.GetAttributeValueFromItemHead = function(item, targetAttribute)
    local success, result = pcall(function()
        local AttributeString = tostring(item.Prefab.GetAttribute(tostring(targetAttribute)))
        return RIBA.removePrefixAndSuffix(AttributeString, '"', '"')
    end)
    return success and result or nil
end

RIBA.CalculateDistance = function(frst, scnd)
    local dx = scnd[1] - frst[1]
    local dy = scnd[2] - frst[2]
    local distance = math.sqrt(dx^2 + dy^2)
    return distance
end

RIBA.FindClientCharacter = function(character)
    if CLIENT then return nil end
    
    for key, value in pairs(Client.ClientList) do
        if value.Character == character then
            return value
        end
    end
end