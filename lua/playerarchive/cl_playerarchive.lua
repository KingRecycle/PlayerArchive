--Require Atlas. Helps keep code clean with simple Derma creation
--include("autorun/atlas.lua")

--Local variables and what nots
local SW = ScrW()/2
local SH = ScrH()/2

local EVENTS = {}
local P_EVENTS = {}

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

function EVENTS:ShowEvents()
    self.Frame = Atlas:Create("DFrame", nil, SW, SH, 900, 500, "Player Archives", true, true, true)
    self.Frame:Center()
    
     self.PanelBar = Atlas:Create("DPanel",self.Frame, 5, 25, 890, 25)
     self.Text = Atlas:Create("DLabel", self.PanelBar, 5, 2, 600, 21, "THE EVENTS ARE CLEARED EVERY: "..tostring((P_EVENTS.End/60)/60).." hours. (Player Archive is a WIP by [Cow] King Recycle)", "default", Color(0, 170, 255, 255))
    -- self.Textentry = Atlas:Create("DTextEntry", self.PanelBar, 70, 2, 100, 21, "-#INF", false, true)
        -- if ( not LocalPlayer():IsAdmin() ) then
            -- self.TextEntry:SetEditable(false)
        -- end
        
    -- self.ToggleText = Atlas:Create("DLabel", self.PanelBar, 200, 2, 100, 21, "Toggle Events:", "default", Color(0, 170, 255, 255))
    -- self.ComboOpt = Atlas:Create("DComboBox", self.PanelBar, 280, 2, 100, 21)
    -- EVENTS:FillComboBox()
    

    --On Now tab stuff
    self.SearchType = Atlas:Create("DCategoryList", self.Frame, 10, 55, 170, 440)
    self.EventType = self.SearchType:Add("Event Type")
    self.EventPlayers = self.SearchType:Add("Players")

   
    self.EventList = Atlas:Create("DListView", self.Frame, 185, 55, 705, 440, false)
    self.EventList:AddColumn("Time"):SetFixedWidth(60)
    self.EventList:AddColumn("i"):SetFixedWidth(16)
    self.EventList:AddColumn("Action"):SetFixedWidth(80)
    self.EventList:AddColumn("Player"):SetFixedWidth(230)
    self.EventList:AddColumn("Description")

    self:LoadList(P_EVENTS)
    self:FillCategories()
end

-------TODO
----Fix functions
--
--Check for any way to improve anything
--Try adding more to player category

function EVENTS:FilterByType( etype )
    if ( table.Count(P_EVENTS) > 0 ) then
            local newlist = {}
        self.EventList:Clear() -- Without this you will get copies of shit
        if (etype == EVENT_SHOWALL) then
            EVENTS:LoadList(P_EVENTS)
        else
            for id,v in pairs(P_EVENTS) do
                --SteamID, Table
                if (type(v) == "table") then
                    for cattype, j in pairs(v) do
                        --CatType, table
                        for n,m in pairs(j) do
                            --index, event
                            if (m.action == etype) then
                                newlist[m.player:SteamID()] = { cattype = j } -- TYPE FILTER FUNCTION
                            end
                        end
                    end
                end
            end
        end
        EVENTS:LoadList(newlist)
    end
end

function EVENTS:FilterByPlayer(ply)
    if ( table.Count(P_EVENTS) > 0 ) then
            local newlist = {}
        self.EventList:Clear() -- Without this you will get copies of shit
            for id,v in pairs(P_EVENTS) do
                --SteamID, Table
                if ( ply:SteamID() == id ) then
                    newlist[ply:SteamID()] = v
                end
            end
        EVENTS:LoadList(newlist)
    end
end


function EVENTS:LoadList( events )
    if ( table.Count(events) > 0 ) then
        self.EventList:Clear() -- Without this you will get copies of shit
        for id,v in pairs(events) do
            --SteamID, Table
            if (type(v) == "table") then
                for cattype, j in pairs(v) do
                    --CatType, table
                    for n,m in pairs(j) do
                        --index, event
                        local name, steamid = "", "";
                        if ( IsValid( m.player ) && m.player:IsPlayer() ) then
                            name = m.player:Nick();
                            steamid = m.player:SteamID();
                        end
                        local eventIcon = "";      
                        if ( m.icon && type(m.icon) != "nil" ) then
                            eventIcon = vgui.Create("DImage", FrameListView)
                            eventIcon:SetImage( m.icon )
                            eventIcon:SizeToContents() // make the control the same size as the image.
                            self.EventList:AddLine(m.time, eventIcon, EVENTS.TYPE[m.action], name.." ("..steamid..")", tostring(m.Desc))
                            self.EventList:SortByColumn( 1, true )
                            self.EventList.OnRowRightClick = function(parent, line, isselected)
                                local menu = DermaMenu()
                                local x, y = gui.MousePos()
                                menu:SetPos(x,y)
                                local selected = self.EventList:GetSelected()
                                menu:AddOption(self.EventList:GetLine(line):GetValue(1), function() SetClipboardText(self.EventList:GetLine(line):GetValue(1)) end)
                                menu:AddOption(self.EventList:GetLine(line):GetValue(3), function() SetClipboardText(self.EventList:GetLine(line):GetValue(3)) end)
                                menu:AddOption(name, function() SetClipboardText(name) end) 
                                menu:AddOption(steamid, function() SetClipboardText(steamid) end) 
                                menu:AddOption(tostring(m.Desc), function() SetClipboardText(tostring(m.Desc)) end)              
                                menu:AddOption(tostring("At "..m.time..", "..name.." ".."( "..steamid.." ) "..m.Desc), function() SetClipboardText(tostring("At "..m.time..", "..name.." ".."( "..steamid.." ) "..m.Desc)) end)                       
                                menu:Open()
                            end
                        end
                    end
                end
            end
        end
    end
end



function EVENTS:GetEventAmount(event)
local amount = 0
    if ( table.Count(P_EVENTS) > 0 ) then
            for id,v in pairs(P_EVENTS) do
                --SteamID, Table
                if (type(v) == "table") then
                    for cattype, j in pairs(v) do
                        --CatType, table
                        for n,m in pairs(j) do
                            --index, event
                             if (event == EVENTS.TYPE[9]) then
                                amount = amount + 1
                            else
                                if (EVENTS.TYPE[m.action] == event) then
                                    amount = amount +1
                                end
                            end
                        end
                    end
                end
            end
        return amount
    end
end

function EVENTS:GetPlayerEventAmount(ply)
local amount = 0
    if ( table.Count(P_EVENTS) > 0 ) then
            for id,v in pairs(P_EVENTS) do
                --SteamID, Table
                if (type(v) == "table") then
                    for cattype, j in pairs(v) do
                        --CatType, table
                        for n,m in pairs(j) do
                            --index, event
                            if (m.player == ply) then
                                amount = amount +1
                            end
                        end
                    end
                end
            end
        return amount
    end
end

---FILL SHIT OUT
function EVENTS:FillCategories()
    for k = 1, #self.TYPE do
		local v = self.TYPE[k]
        local item = self.EventType:Add(v.." ("..tostring(EVENTS:GetEventAmount(v))..")" )
        local type = k
            item.DoClick = function( button )
               EVENTS:FilterByType(type)
            end
    end
    ---Player Category
    local t_players = player.GetAll()
    for i = 1, #t_players do
		local p = t_players[i]
        local pitem = self.EventPlayers:Add(p:Name().." ("..tostring(EVENTS:GetPlayerEventAmount(p))..")" )
            pitem.DoClick = function( button )
                EVENTS:FilterByPlayer(p)
            end
    end
end

function EVENTS:FillComboBox()
self.CheckBoxOpt = Atlas:Create("DCheckBoxLabel", self.PanelBar, 390, 5, 100, 21, "")
        for k = 1, #self.TYPE do
            local v = self.TYPE[k]
            local item = self.ComboOpt:AddChoice(v)
            self.ComboOpt.OnSelect = function( panel, index, value, data)
                if ( value == nil ) then
                    self.CheckBoxOpt:SetText("")
                else
                    self.CheckBoxOpt:SetText("Track "..value.."?")
                end
            end
        end
end




net.Receive( "sendEvents", function( length, client )
    local events = net.ReadTable()
    events.player = net.ReadEntity();
    P_EVENTS = events
end )
concommand.Add("player_events", function()     EVENTS:ShowEvents() end )

concommand.Add("player_events_clear", function()
    if (LocalPlayer():IsAdmin()) then
        net.Start( "clearEvents" )
        net.SendToServer() 
    end
end)