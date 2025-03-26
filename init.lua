minetest.register_node("decrafter:table", {
    description = "Decrafter",
    tiles = {"decrafter_top.png", "decrafter_bottom.png", "decrafter_side.png"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2},

    on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 9)
		meta:set_string("formspec", "size[10.5,8.5]" ..
			"label[1,1;Oggetto da decraftare]" ..
			"list[current_name;input;1,2;1,1;]" ..
			"label[5,0.5;Materiali ottenuti]" ..
			"list[current_name;output;5,1;3,3;]" ..
			"list[current_player;main;1,4.5;8,4;]")
	end,


    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "input" then
            return stack:get_count()
        end
        return 0
    end,

    on_metadata_inventory_put = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local input_stack = inv:get_stack("input", 1)
        local output = {}

        for i = 1, 9 do output[i] = nil end

        if not input_stack:is_empty() then
            local craft = minetest.get_craft_recipe(input_stack:get_name())
            if craft and craft.items then
                for i, item in ipairs(craft.items) do
                    output[i] = ItemStack(item)
                end
                inv:set_list("output", output)
            end
        else
            inv:set_list("output", {}) -- svuota se non c'è nulla
        end
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if listname == "output" then
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local input_stack = inv:get_stack("input", 1)
            if not input_stack:is_empty() then
                -- Rimuove l’oggetto solo quando si inizia a prendere dalla griglia
                inv:set_stack("input", 1, nil)
            end
        end
        return stack:get_count()
    end,

    on_metadata_inventory_take = function(pos, listname, index, stack, player)
        if listname == "output" then
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()

            local all_items = inv:get_list("output")
            local leftover = player:get_inventory():add_item("main", stack)
            for i, item in ipairs(all_items) do
                if i ~= index then
                    player:get_inventory():add_item("main", item)
                end
            end
            inv:set_list("output", {}) -- pulisce la griglia dopo aver preso
        end
    end,
})

minetest.register_craft({
    output = "decrafter:table",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:mese_crystal", "default:wood"},
        {"default:wood", "default:wood", "default:wood"}
    }
})
