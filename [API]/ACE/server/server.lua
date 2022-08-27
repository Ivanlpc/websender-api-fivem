ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local r = Router.new()
r:Post("/add", function(req, res)
    
    if(not req:Body().products or not req:Body().token or not req:Body().steamid) then
        res:Send("Missing parameters")
    else

        check_token(req:Body().token, function(result)
            
            if result then
                
                check_player_online(req:Body().steamid, function(isOnline, id)
                    
                    if isOnline then
                        
                        for _,v in pairs(req:Body().products) do
                            give_product(id, req:Body().steamid, v)
                        end

                        show_notification(id)
                        res:Send("The player is online and has received the product", 200)
                    else
                        
                        for _,v in pairs(req:Body().products) do
                            addProduct(req:Body().steamid, v)
                        end
                        res:Send("Added to the pending products", 200)
                    end
                end)
                
            else
                res:Send("Token not found", 403)
            end

    end)
        
    end
end)

Server.use("", r)
Server.listen()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    local id = playerData
    local steamid = GetPlayerIdentifier(playerData)
    MySQL.query("SELECT command,id FROM pending_products WHERE steamid = @id", {
        ["@id"] = steamid
    },function(result)
        if result then
            
            for k,v in pairs(result) do
                give_product(id, steamid, v.command)
                MySQL.single("DELETE FROM pending_products WHERE id = @id", {
                    ["@id"] = v.id
                })
                Citizen.Wait(500)
            end
            show_notification(id)
    end
    end)
    
end)
function show_notification(id)
    local xPlayer = ESX.GetPlayerFromId(id)
    xPlayer.showNotification("¡Gracias por su compra! Revise su inventario para ver los objetos, en caso de tener algún problema contacte con el staff.")

end


function give_product(id, steam, command)
    ExecuteCommand(string.format(command, id))
    print(string.format("^3EXECUTING COMMAND -> %s",string.format(command, id)))
    print(string.format("^3Steam: %s",steam))
   
end

function check_player_online(steamid, callback)
    for _, playerId in ipairs(GetPlayers()) do

        if GetPlayerIdentifier(playerId) == steamid then
            
            return callback(true, playerId)
            
        end
    end
    callback(false, nil)
end
      

function addProduct(steamid, command)
    MySQL.single("INSERT INTO pending_products (steamid, command) VALUES(@steam, @command)", {
        ["@steam"] = steamid,
        ["@command"] = command
    })
end



function check_token(token, cb)
    MySQL.single("SELECT * FROM api WHERE token = @token" ,{
            ["@token"] = token
        }, 
        function(result)
            if result then
                cb(true)
            else
                cb(false)
            end
    end)
end
