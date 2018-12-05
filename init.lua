local commands = {}

minetest.register_chatcommand("dev", {
	params = "<command> <arguments>",
	description = "Launch a dev tools command. Type /dev help for command list.",
	privs = {},
	func = function(pname, params)
		local found = string.find(params, " ", 1) or (#params + 1)
		local command = string.sub(params, 1, found - 1)
		local params = string.sub(params, found + 1)

		if command == '' then
			return commands.help.func(pname, '')
		end

		if commands[command] then
			return commands[command].func(pname, params)
		end

		return false, "Unknown command '"..command.."'. Type /dev help for command list."
	end
})

--TODO use table.concat and string.format!
commands.help = {
	params = "<command>",
	description = "Describes a dev command or list available commands.",
	func = function(pname, params)
			if params == nil or params == '' then
				local output = ''
				local count = 0
				for command, def in pairs(commands) do
					count = count + 1
					output = output.."\n/dev "..command..": "..def.description
				end
				return true, count..' available /dev commands:'..output
			else
				if not commands[params] then
					return false, "Unknown command '"..(params or '').."'. Type /dev help for command list."
				end
				return true, "/dev "..params.." "..commands[params].params.."\n"..commands[params].description
			end
		end,
}

commands.entities = {
	params = "<radius>",
	description = "Dumps to log the list of entities inside <radius>.",
	func = function(pname, param)
			local player = minetest.get_player_by_name(pname)
			if not player then
				return false, "Player not found"
			end
			local distance = param -- TODO : check params
			local count=0
			local output = '\n***** Entity dump start *****'
			for _, objref in pairs(minetest.get_objects_inside_radius(player:get_pos(), distance)) do
				if not minetest.is_player(objref) then
					local entity = objref:get_luaentity()
					output = output..'\n"'..entity.name..'" at '..minetest.pos_to_string(objref:get_pos())
					output = output..'\n'..dump(entity)
					count = count + 1
				end
			end
			minetest.log('action', output..'\n***** Entity dump stop *****\n')
			return true, count.." entities dumped in log"
		end,
}
