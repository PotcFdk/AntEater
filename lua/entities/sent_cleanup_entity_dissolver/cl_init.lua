include('shared.lua')

function ENT:Draw()
	self:SetModelScale(0.5, 0)
	self:SetRenderOrigin(self:GetPos())

	self:DrawShadow(false)
	self:DrawModel()
	self:SetRenderOrigin(nil)
end