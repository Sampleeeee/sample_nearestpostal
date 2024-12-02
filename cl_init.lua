function Round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(num * mult + 0.5) / mult
    end
    
    return math.floor(num + 0.5)
end

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

    return POSTALS[nearestIndex].code, Round(nearestDistance, 2)
end
exports( "GetNearestPostal", GetNearestPostal )
exports( 'getPostal', function() GetNearestPostal( GetEntityCoords( PlayerPedId() ) ) end )

-- Commenting this out, nearest is never defined? this would just throw an error.....
-- exports( 'getPostal', function() if nearest ~= nil then return postals[nearest.i].code else return nil end end )

do
	local postal, distance

	Citizen.CreateThread(function()
		while true do		
			if postal == nil or distance == nil then
				exports.sample_util:DrawTextRightOfMinimap( exports.sample_util:GetHudColor() .. "Nearest Postal: ~w~Loading...", 0, 0.04 )
			else
				exports.sample_util:DrawTextRightOfMinimap( exports.sample_util:GetHudColor() .. "Nearest Postal: ~w~"..postal.." ("..distance.."m)", 0, 0.04 )
			end

			Citizen.Wait(0)
		end
	end)

	Citizen.CreateThread( function()
		while true do
			local p = PlayerPedId()
			local c = GetEntityCoords(p)
			postal, distance = GetNearestPostal( c )
		
			Citizen.Wait( 250 )
		end
	end )
end

do
    local waypointSet = false
    local blip, location = nil, nil

    function RemoveRoute()
        RemoveBlip( blip )

        blip, location = nil, nil
        waypointSet = false
    end

    function PostalCommand( _, args )
        if args[1] == nil and waypointSet then
            RemoveRoute()
            return
        end

        for k, v in ipairs(POSTALS) do
            if string.lower( v.code ) == string.lower( args[1] ) then
                postal = v
                break
            end
        end

        if args[1] == nil and not waypointSet then
            TriggerEvent( 'chat:addMessage', {
                args = { "^4Postal", "Unable to find postal" }
            } )
            return
        end

        if postal == nil then
            TriggerEvent( 'chat:addMessage', {
                args = { "^4Postal", "Unable to find postal" }
            } )
            
            return
        end

        RemoveRoute()

        location = vector2( postal.x, postal.y )
        blip = AddBlipForCoord( location )
        waypointSet = true

        SetBlipColour( blip, 30 )
        SetBlipRoute( blip, true )
        SetBlipRouteColour( blip, 30 )
        SetBlipSprite( blip, 8 )

        TriggerEvent( 'chat:addMessage', {
            args = { "^4Postal", "Drawing route to postal " .. args[1] }
        } )

        while true do
            local p = PlayerPedId()
            local c = GetEntityCoords( p )

            if #( location - vector2( c.x, c.y ) ) < 50 then
                RemoveRoute()
            end

            Citizen.Wait( 20 )
        end
    end

    --[[function PostalCommand( _, args )

        local postal = args[1]

        if postal == nil then
            TriggerEvent( 'chat:addMessage', {
                args = { "^4Postal", "Unable to find postal" }
            } )
        end

    end]]--

    RegisterCommand( "postal", PostalCommand )
    RegisterCommand( "p", PostalCommand )

    TriggerEvent( 'chat:addSuggestion', '/postal', 'Draws a route to the given postal.\nYou can also use this command\'s alias \'/p\'.', {
        { name = "postal", help = "The postal to draw a route to." },
    } )

    TriggerEvent( 'chat:addSuggestion', '/p', 'Draws a route to the given postal. (alias of /postal)', {
        { name = "postal", help = "The postal to draw a route to." },
    } )
end
