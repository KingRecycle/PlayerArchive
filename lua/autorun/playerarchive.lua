if (SERVER) then
	AddCSLuaFile("autorun/playerarchive.lua")
	AddCSLuaFile("playerarchive/cl_playerarchive.lua")
    AddCSLuaFile("autorun/atlas.lua")
	include("playerarchive/sv_playerarchive.lua")
else
	include("playerarchive/cl_playerarchive.lua")
    include("autorun/atlas.lua")
end
