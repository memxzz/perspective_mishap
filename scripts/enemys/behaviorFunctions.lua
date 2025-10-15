local behaviorFunctions = {
	extends = Node,
	mainNode = export(Node3D)
}
function behaviorFunctions:followTarget(target,speed)
	if target.playerStates.damaged == true or target.playerStates.dead == true then self.mainNode.behaviorStats.target_vel = Vector3(0,0,0)return end
	local direction = self.mainNode.global_position:direction_to(target.global_position)
	self.mainNode.behaviorStats.target_vel = direction * speed
	--print(charBody.targetVel)
	--charBody.global_position = lerp(charBody.global_position,target.global_position,delta*speed)
end

return behaviorFunctions
