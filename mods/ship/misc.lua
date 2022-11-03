function get_eye_pos(player)
	local player_pos = player:get_pos()
	local eye_height = player:get_properties().eye_height
	local eye_offset = player:get_eye_offset()
	player_pos.y = player_pos.y + eye_height
	player_pos = vector.add(player_pos, eye_offset)

	return player_pos
end
