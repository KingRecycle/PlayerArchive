--AddCSLuaFile( "playerarchive/cl_player_events.lua" )
local EVENTS = {}
local ARCHIVE = {}

EVENT_SPAWN = 1
EVENT_DEATH = 2
EVENT_CONNECT = 3
EVENT_DISCONNECT = 4
EVENT_PROPSPAWN = 5
EVENT_PLAYERSAY = 6
EVENT_USETOOL = 7
EVENT_DRIVE = 8
EVENT_SHOWALL = 9

EVENTS.TYPE = {
	[EVENT_SPAWN] = "Spawn", 
	[EVENT_DEATH] = "Death",
	[EVENT_CONNECT] = "Connect", 
	[EVENT_DISCONNECT] = "Disconnect", 
	[EVENT_PROPSPAWN] = "Prop Spawn", 
	[EVENT_PLAYERSAY] = "Say", 
	[EVENT_USETOOL] = "Tool", 
	[EVENT_DRIVE] = "Drive", 
	[EVENT_SHOWALL] = "Show All"
}


EVENTS.PlayerKilled = true
EVENTS.PlayerConnect = true
EVENTS.PlayerDisconnect = true
EVENTS.PlayerSpawn = true
EVENTS.PlayerSay = true
EVENTS.PlayerPropSpawn = true
EVENTS.PlayerUseTool = true
EVENTS.PlayerDrive = true
EVENTS.MAXEVENTS = 5000
EVENTS.REMOVETIME = 21600 --HOW LONG BEFORE CLEARING THE TABLE IN SECONDS


--TODO:
--Improve tables
--Improve data sending
--Spam Check (maybe)
--Data saving

function EVENTS:RegisterPlayer( steamid )
    if ( ARCHIVE[steamid] ~= nil or steamid == nil ) then return end
    
        if (ARCHIVE[steamid] == nil ) then
            ARCHIVE[steamid] = {
                SPAWN = {},
                DEATH = {},
                CONNECT = {},
                DISCONNECT = {},
                PROPSPAWN = {},
                PLAYERSAY = {},
                USETOOL = {},
                DRIVE = {}
            }
        print("[PlayerArchive] New player added to the archives.")
        end
end

------Events
--Player Death
hook.Add("PlayerDeath","PlayerDeath", function(victim, killer) 
    if (EVENTS.PlayerKilled == true or EVENTS.PlayerKilled == 1) then
        local name
        if (killer:IsPlayer() ) then name = killer:Name() elseif ( killer:IsWorld() ) then name = "worldspawn" elseif ( killer:IsNPC() ) then name = killer end
            table.insert(ARCHIVE[victim:SteamID()].DEATH, {time = tostring(os.date("%H:%M:%S")), action = EVENT_DEATH, player = victim, Desc = "Was killed by "..tostring(name), icon = "icon16/lightbulb_off.png"})
            SendEvents()
    end
end)


hook.Add("PlayerAuthed","PlayerAuthed", function(ply, steamid, uid) 
    EVENTS:RegisterPlayer( steamid )
        if (EVENTS.PlayerConnect == true or EVENTS.PlayerConnect == 1) then
            table.insert(ARCHIVE[steamid].CONNECT, {time = tostring(os.date("%H:%M:%S")), action = EVENT_CONNECT, player = ply, Desc = "Connected to the server.", icon = "icon16/connect.png"})
            SendEvents()
        end
end)

hook.Add("PlayerDisconnected","PlayerDisconnected", function(ply) 
    if (EVENTS.PlayerDisconnect == true or EVENTS.PlayerDisconnect == 1) then
        table.insert(ARCHIVE[ply:SteamID()].DISCONNECT, {time = tostring(os.date("%H:%M:%S")), action = EVENT_DISCONNECT, player = ply, Desc = "Disconnected from the server.", icon = "icon16/disconnect.png"})
        SendEvents()    
    end
end)

hook.Add("PlayerSay","PlayerSay", function(ply, msg) 
    if (EVENTS.PlayerSay == true or EVENTS.PlayerSay == 1) then
       table.insert(ARCHIVE[ply:SteamID()].PLAYERSAY, {time = tostring(os.date("%H:%M:%S")), action = EVENT_PLAYERSAY, player = ply, Desc = "said, "..msg, icon = "icon16/user_comment.png"})
        SendEvents()    
    end
end)

hook.Add("PlayerSpawn","PlayerSpawn", function(ply)
    if (EVENTS.PlayerSpawn == true or EVENTS.PlayerSpawn == 1) then
        if ( ARCHIVE[ply:SteamID()] == nil ) then return end
            table.insert(ARCHIVE[ply:SteamID()].SPAWN, {time = tostring(os.date("%H:%M:%S")), action = EVENT_SPAWN, player = ply, Desc = "Has spawned.", icon = "icon16/lightbulb.png"})
            SendEvents()
    end
end)

hook.Add("PlayerSpawnedProp","PlayerSpawnedProp", function(ply, prop)
    if (EVENTS.PlayerPropSpawn == true or EVENTS.PlayerPropSpawn == 1) then
        table.insert(ARCHIVE[ply:SteamID()].PROPSPAWN, {time = tostring(os.date("%H:%M:%S")), action = EVENT_PROPSPAWN, player = ply, Desc = "Spawned, "..prop, icon = "icon16/bricks.png"})
        SendEvents()
    end
end)

hook.Add("CanTool","CanTool", function(ply, tr, tool)
    if (EVENTS.PlayerUseTool == true or EVENTS.PlayerUseTool == 1) then 
        table.insert(ARCHIVE[ply:SteamID()].USETOOL, {time = tostring(os.date("%H:%M:%S")), action = EVENT_USETOOL, player = ply, 
        Desc = "Used "..tostring(tool).." tool on "..string.GetFileFromFilename(tr.Entity:GetModel()), icon = "icon16/wrench.png"})
        --string.GetFileFromFilename(me:GetModel()):match("(.+)%.mdl") --Gets rid of .mdl
        SendEvents()
    end
end)

hook.Add("CanDrive","CanDrive", function(ply, ent)
    if (EVENTS.PlayerDrive == true or EVENTS.PlayerDrive == 1) then 
       table.insert(ARCHIVE[ply:SteamID()].DRIVE, {time = tostring(os.date("%H:%M:%S")), action = EVENT_DRIVE, player = ply, 
        Desc = "Started driving "..string.GetFileFromFilename(ent:GetModel()), icon = "icon16/car.png"})
        --string.GetFileFromFilename(me:GetModel()):match("(.+)%.mdl") --Gets rid of .mdl
        SendEvents()
    end
end)


function EVENTS:ClearArchives()

        ARCHIVE = nil
        ARCHIVE = {}

        for k,v in pairs(player.GetAll()) do
            EVENTS:RegisterPlayer( v:SteamID() )
        end
        print("[PlayerArchive] Archive has been cleared.")
    SendEvents()
end


timer.Create( "RemoveTimer", EVENTS.REMOVETIME, 0, function() EVENTS:ClearArchives() end )


----TODO:
--Create net stuff to update variables

util.AddNetworkString( "sendSingleEvent" )
util.AddNetworkString( "sendEvents" )
util.AddNetworkString( "clearEvents" )

function SendEvents()
    local tbl = table.Copy(ARCHIVE);
    local ply = tbl.player;
    tbl.player = nil;
    ARCHIVE.End = EVENTS.REMOVETIME

    net.Start( "sendEvents" )
        net.WriteTable(ARCHIVE)
        net.WriteEntity(ply);
    net.Broadcast()
end

function SendSingleEvent(event)
    local tbl = table.Copy(event);
    local ply = tbl.player;
    tbl.player = nil;
    
    net.Start( "sendSingleEvent" )
        net.WriteTable(event)
        net.WriteEntity(ply);
    net.Broadcast()
        print("Sending Single Event")
end

net.Receive( "clearEvents", function( length, client )
    EVENTS:ClearArchives()
end )
