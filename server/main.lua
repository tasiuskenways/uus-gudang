local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('gudang:server:GetWareHouse', function(source, cb, id)
    local cid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local identifier = QBCore.Functions.GetIdentifier(source, 'steam')
    local ada = false
    AutoKickWareHouse()
    MySQL.Async.fetchAll('SELECT * FROM gudang WHERE gid = @gid AND CID = @CID', {
        ['@CID'] = cid,
        ['@gid'] = id
    }, function(result)
        if result[1] ~= nil then
            ada = true
        end
        cb(ada, identifier)
    end)
end)

function BuyStorage(id, cid ,endtime)
    MySQL.insert('INSERT INTO gudang (gid, CID, end_time) VALUES (:id ,:CID, :endtime)', {
        id = id,
        CID = cid,
        endtime = endtime,
    })
end

function AutoKickWareHouse()
    MySQL.Async.execute('DELETE FROM gudang WHERE end_time < NOW()', {}, function(result)
        if result > 0 then
            print( result .. ' Is Expired From The Database.')
        end
    end)
end

function RegisterStash(cid, id)
    if Config.Inventory ~= "ox_inventory" then return end
    local identifier = QBCore.Functions.GetIdentifier(source, 'steam')
    exports.ox_inventory:RegisterStash("locker_"..id .. cid, "Locker " .. id, Config.Slot, Config.Weight, identifier)
end

RegisterNetEvent('gudang:server:buyStorage')
AddEventHandler('gudang:server:buyStorage', function(day, price, id)
    local Player = QBCore.Functions.GetPlayer(source)
    local CID = Player.PlayerData.citizenid
    s1 = os.time()
    x1 = os.date('*t',s1)

    x1.day = x1.day + day
    x1.isdst = nil -- this prevents DST time changes

    s2 = os.time(x1)
    local endtime = os.date("%Y/%m/%d %X", s2)
    if Player.PlayerData.money.cash >= price then
        BuyStorage(id, CID, endtime)
        RegisterStash(CID, id)
        Player.Functions.RemoveMoney('cash', price, "bought-storage")
        TriggerClientEvent('QBCore:Notify', source, 'You Bought Storage For '..day..' Days For $'..price, 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'You Dont Have Enough Money', 'error')
    end
end)