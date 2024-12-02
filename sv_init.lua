function GetNearestPostal(coords)
    local nearestDistance = -1
    local nearestIndex = -1

    for k, v in ipairs(POSTALS) do
        local distance = #(vector3(v.x, v.y, 0.0) - vector3(coords.x, coords.y, 0.0))

        if nearestDistance == -1 or distance < nearestDistance then
            nearestIndex = k
            nearestDistance = distance
        end
    end

    return POSTALS[nearestIndex].code, Round(nearestDistance, 2), POSTALS[nearestIndex].x, POSTALS[nearestIndex].y
end
exports("GetNearestPostal", GetNearestPostal)

function GetNearestPostalForShotSpotter(coords)
    local nearestDistance = -1
    local nearestIndex = -1

    for k, v in ipairs(POSTALS) do
        local distance = #(vector3(v.x, v.y, 0.0) - vector3(coords.x, coords.y, 0.0))

        if nearestDistance == -1 or distance < nearestDistance then
            nearestIndex = k
            nearestDistance = distance
        end
    end

    return { postal = POSTALS[nearestIndex].code, coords = vector3(POSTALS[nearestIndex].x, POSTALS[nearestIndex].y, 0.0) }
end
exports("GetNearestPostalForShotSpotter", GetNearestPostalForShotSpotter)

function Round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(num * mult + 0.5) / mult
    end
    
    return math.floor(num + 0.5)
end