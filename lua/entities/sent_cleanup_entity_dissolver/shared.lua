ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = Model("models/Combine_Helicopter/helicopter_bomb01.mdl")

ENT.PrintName		= "Cleanup Entity Dissolver"
ENT.Author			= "PotcFdk"


ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.PhysgunDisabled = true
ENT.DisableDuplicator = true
ENT.CanConstruct = function() return false end
ENT.CanTool = function() return false end
ENT.m_tblToolsAllowed = {}
