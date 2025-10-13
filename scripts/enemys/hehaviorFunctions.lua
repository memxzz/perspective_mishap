local behaviorFunctions = {
	extends = Node,
}
function behaviorFunctions:follow(target,charBody,delta,speed)
	charBody.global_position = lerp(charBody.global_position,target.global_position,delta * speed)
end
return behaviorFunctions
