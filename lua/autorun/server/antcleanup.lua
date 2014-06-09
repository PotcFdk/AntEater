local function findPlayer (nick)
	if type(nick) == "Player" then return nick end
	if not isstring(nick) then return end
	local matches = {}
	for _, ply in next, player.GetAll() do
		if ply:Nick():lower():find(string.Trim(nick):lower(), 1, true) then
			table.insert(matches, ply)
		end
	end
	if #matches <= 0 then
		return
	elseif #matches > 1 then
		return false
	else -- 1
		return matches[1]
	end
end

local function tell (ply, txt)
	timer.Simple(0, function() return IsValid(ply) and ply:ChatPrint(txt) end)
end

local function execute (target)
	local c = 0 
	for k,v in next, ents:GetAll() do 
		if v:CPPIGetOwner() == target and v:GetParent() ~= target then 
			c = c + 1
		end 
	end

	c = math.min(math.max(1, math.floor(c/10)), 10)

	for i=1, c do
		local pE = ents.Create("sent_cleanup_entity_dissolver")
		pE:SetPos(target:GetPos())
		pE:SetTargetPlayer(target)
		pE:Spawn()
	end	
end

local function antcleanup (ply, target)
	if not IsValid(ply) then return end
	if not ply:IsAdmin() then
		target = ply
	end
	
	target = findPlayer(target)
	
	if target == false then
		return tell(ply, "Found multiple players!")
	elseif not target or not IsValid(target) then
		return tell(ply, "Player not found!")
	end
	
	if ply ~= target and not ply:IsAdmin() then
		return tell(ply, "Access denied!")
	end
	
	return execute(target)
end

hook.Add("PlayerSay", "AntCleanup", function(ply, txt)
	if not IsValid(ply) or not isstring(txt) then return end
	txt = txt:lower()
	
	local cmd, target = txt:match("^[!/~.](antcleanup)%s(.+)")
	if not cmd then cmd = txt:match("^[!/~.](antcleanup)") end
	if cmd ~= "antcleanup" then return end
	
	return antcleanup(ply, target)
end)

concommand.Add("antcleanup", function(ply, cmd, args)
	antcleanup(ply, args[1])
end)