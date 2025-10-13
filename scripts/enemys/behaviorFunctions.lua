local behaviorFunctions = {
	extends = Node,
	mainNode = export(Node3D)
}
function behaviorFunctions:followTarget(target,speed)
	local direction = self.mainNode.global_position:direction_to(target.global_position)
	self.mainNode.behaviorStats.target_vel = direction * speed
	--print(charBody.targetVel)
	--charBody.global_position = lerp(charBody.global_position,target.global_position,delta*speed)
end

return behaviorFunctions
