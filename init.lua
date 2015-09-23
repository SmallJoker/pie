local hmod = minetest.get_modpath("hunger")
local hbmod = minetest.get_modpath("hbhunger")

local throw_pie = function(player)
	local VELOCITY = 20
	local GRAVITY = -9.81
	
	local pos = player:getpos()
	local dir = player:get_look_dir()
	pos.y = pos.y + 1.5
	dir.y = dir.y + 0.2
	
	local obj = minetest.add_entity(pos, "__builtin:falling_node")
	obj:get_luaentity():set_node({ name = "pie:splat" })
	obj:setvelocity(vector.multiply(dir, VELOCITY))
	obj:setacceleration({x=dir.x*-4, y=GRAVITY, z=dir.z*-4})
end

local copy_merge_table = function(skeleton, original_meat)
	local body = table.copy(skeleton)
	local meat = table.copy(original_meat)
	for k,v in pairs(meat) do
		body[k] = meat[k]
	end
	return body
end

local replace_pie = function(node, puncher, pos)

	if minetest.is_protected(pos, puncher:get_player_name()) then
		return
	end

	local pie = node.name:split("_")[1]
	local num = tonumber(node.name:split("_")[2])

	if num == 3 then
		node.name = "air"
	elseif num < 3 then
		node.name = pie .. "_" .. (num + 1)
	end

	if hmod then
		local h = hunger.read(puncher)
--print ("hunger is "..h)
		h = math.min(h + 4, 30)
		local ok = hunger.update_hunger(puncher, h)
		minetest.sound_play("hunger_eat", {
			pos = pos, gain = 0.7, hear_distance = 5})
	elseif hbmod then
		local h = tonumber(hbhunger.hunger[puncher:get_player_name()])
--print ("hbhunger is "..h)
		h = math.min(h + 4, 30)
		hbhunger.hunger[puncher:get_player_name()] = h
		minetest.sound_play("hbhunger_eat_generic", {
			pos = pos, gain = 0.7, hear_distance = 5})
	else
		local h = puncher:get_hp()
--print ("health is "..h)
		h = math.min(h + 4, 20)
		puncher:set_hp(h)
	end

	minetest.set_node(pos, {name = node.name})

end

local register_pie = function(pie, desc)
local skeleton = {
	paramtype = "light",
	sunlight_propagates = false,
	tiles = {
		pie.."_top.png", pie.."_bottom.png", pie.."_side.png",
		pie.."_side.png", pie.."_side.png", pie.."_side.png"
	},
	drawtype = "nodebox",
	on_punch = function(pos, node, puncher, pointed_thing)
		replace_pie(node, puncher, pos)
	end,
}

minetest.register_node("pie:"..pie.."_0", copy_merge_table(skeleton, {
	description = desc,
	inventory_image = pie.."_inv.png",
	wield_image = pie.."_inv.png",
	groups = {},
	node_box = {
		type = "fixed",
		fixed = {{-0.45, -0.5, -0.45, 0.45, 0, 0.45}},
	},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			return
		end
		throw_pie(user)
		itemstack:take_item()
		return itemstack
	end,
}))

minetest.register_node("pie:"..pie.."_1", copy_merge_table(skeleton, {
	description = "3/4"..desc,
	groups = {not_in_creative_inventory = 1},
	node_box = {
		type = "fixed",
		fixed = {{-0.45, -0.5, -0.25, 0.45, 0, 0.45}},
	},
}))

minetest.register_node("pie:"..pie.."_2", copy_merge_table(skeleton, {
	description = "Half "..desc,
	groups = {not_in_creative_inventory = 1},
	node_box = {
		type = "fixed",
		fixed = {{-0.45, -0.5, 0.0, 0.45, 0, 0.45}},
	},
}))

minetest.register_node("pie:"..pie.."_3", copy_merge_table(skeleton, {
	description = "Piece of "..desc,
	groups = {not_in_creative_inventory = 1},
	node_box = {
		type = "fixed",
		fixed = {{-0.45, -0.5, 0.25, 0.45, 0, 0.45}},
	},
}))

end

-- Normal Cake
register_pie("pie", "Cake")

minetest.register_craft({
	output = "pie:pie_0",
	recipe = {
		{"farming:sugar", "mobs:bucket_milk", "farming:sugar"},
		{"farming:sugar", "mobs:egg", "farming:sugar"},
		{"farming:wheat", "farming:flour", "farming:wheat"},
	},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- Chocolate Cake
register_pie("choc", "Chocolate Cake")

minetest.register_craft({
	output = "pie:choc_0",
	recipe = {
		{"farming:cocoa_beans", "mobs:bucket_milk", "farming:cocoa_beans"},
		{"farming:sugar", "mobs:egg", "farming:sugar"},
		{"farming:wheat", "farming:flour", "farming:wheat"},
	},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- Strawberry Cheesecake
register_pie("scsk", "Strawberry Cheesecake")

minetest.register_craft({
	output = "pie:scsk_0",
	recipe = {
		{"ethereal:strawberry", "mobs:bucket_milk", "ethereal:strawberry"},
		{"farming:sugar", "mobs:egg", "farming:sugar"},
		{"farming:wheat", "farming:flour", "farming:wheat"},
	},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- Coffee Cake
register_pie("coff", "Coffee Cake")

minetest.register_craft({
	output = "pie:coff_0",
	recipe = {
		{"farming:coffee_beans", "mobs:bucket_milk", "farming:coffee_beans"},
		{"farming:sugar", "mobs:egg", "farming:sugar"},
		{"farming:wheat", "farming:flour", "farming:wheat"},
	},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- Red Velvet Cake
register_pie("rvel", "Red Velvet Cake")

minetest.register_craft({
	output = "pie:rvel_0",
	recipe = {
		{"farming:cocoa_beans", "mobs:bucket_milk", "dye:red"},
		{"farming:sugar", "mobs:egg", "farming:sugar"},
		{"farming:flour", "mobs:cheese", "farming:flour"},
	},
	replacements = {{ "mobs:bucket_milk", "bucket:bucket_empty"}}
})

-- Meat Cake
register_pie("meat", "Meat Cake")

minetest.register_craft({
	output = "pie:meat_0",
	recipe = {
		{"mobs:meat_raw", "mobs:egg", "mobs:meat_raw"},
		{"farming:wheat", "farming:wheat", "farming:wheat"},
		{"", "", ""}
	},
})

minetest.register_node("pie:splat", {
	description = "SPLAT!",
	tiles = {"pie_splat.png"},
	buildable_to = true,
	groups = {crumbly=3, falling_node=1, not_in_creative_inventory=1},
	drop = "",
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {{-0.45, -0.5, -0.45, 0.45, 0, 0.45}},
	},
})