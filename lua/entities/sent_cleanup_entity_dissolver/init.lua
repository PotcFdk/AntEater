AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local Tag="sent_cleanup_entity_dissolver"

-- Used Variables:
-- - ENT.Active
-- - ENT.TargetPlayer
-- - ENT.TargetEntity

function ENT:SetTargetPlayer(ply)
	assert(IsValid(ply), "Invalid target player specified!")
	self.TargetPlayer = ply
end

function ENT:ShouldReact(ent)
	return not ent.dissolved
		and ent ~= self
		and ent:CPPIGetOwner() == self.TargetPlayer
		and ent:GetParent() ~= self.TargetPlayer
end

function ENT:FindTarget()
	if IsValid(self.TargetEntity) and self.TargetEntity.assigned_dissolver == self then
		self.TargetEntity.assigned_dissolver = nil
	end
	
	local best = math.huge
	local found = false
	for _, ent in next, ents.GetAll() do
		if self:ShouldReact(ent) then
			local valid_dissolver = IsValid(ent.assigned_dissolver)
			if not valid_dissolver or valid_dissolver == self then
				local d = self:GetPos():Distance(ent:GetPos())
				if d < best then
					best = d
					self.TargetEntity = ent
					found = true
				end
			end
		end
	end
	
	if IsValid(self.TargetEntity) then
		self.TargetEntity.assigned_dissolver = self
	end
	
	return found
end

function ENT:DissolveEntities()
	for _, ent in next, ents.FindInSphere(self:GetPos(), 42) do
		if self:ShouldReact(ent) then
			ent.dissolved = true
			if not ent:IsValid() then return end
			ent:SetName("dissolvemenao"..tostring(ent:EntIndex()))
			local e=ents.Create'env_entity_dissolver'
			e:SetKeyValue("target","dissolvemenao"..tostring(ent:EntIndex()))
			e:SetKeyValue("dissolvetype","1")
			e:Spawn()
			e:Activate()
			e:Fire("Dissolve",ent:GetName(),0)
			SafeRemoveEntityDelayed(e,0.1)
		end
	end
end

-- MOVEMENT

function ENT:SetupMotionController()
	self.ShadowParams = {}
	self.ShadowParams.secondstoarrive = 1
	self.ShadowParams.angle = self:GetAngles()
	self.ShadowParams.maxangular = 5000
	self.ShadowParams.maxangulardamp = 10000
	self.ShadowParams.maxspeed = 10000000
	self.ShadowParams.maxspeeddamp = 10000
	self.ShadowParams.dampfactor = 0.5
	self.ShadowParams.teleportdistance = 0
end

function ENT:PhysicsSimulate(phys, deltatime)
	if not IsValid(self.TargetEntity) then return end
	
	phys:Wake()
	
	self.ShadowParams.pos = self.TargetEntity:GetPos()
	self.ShadowParams.deltatime = deltatime
	
	phys:ComputeShadowControl(self.ShadowParams)
end

-- / MOVEMENT

function ENT:Think()
	if not self.Active then return end
	if not self:FindTarget() then
		return self:Deactivate()
	end

	self:DissolveEntities()
end

function ENT:Deactivate()
	self.Active = false
	return SafeRemoveEntityDelayed(self, 1)
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self.Active = true
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUnFreezable(true)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetupMotionController()
	self:StartMotionController()
	self:GetPhysicsObject():Wake()
	
	self:SetColor(Color(255,0,0))
	self:SetMaterial("models/shiny")
	self.Trail = util.SpriteTrail(self, 0, Color(255,0,0), false, 15, 1, 10, 1/(15+1)*0.5, "trails/plasma.vmt")
end