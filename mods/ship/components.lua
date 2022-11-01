--------------------------------------
--Registration of ship component Nodes
--------------------------------------

minetest.register_node("ship:core", {
    description = "The main starting point for you ship",
    tiles = {"ship_core.png"},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand}
})

minetest.register_node("ship:engine", {
    description = "What allows you to move faster in space",
    tiles = {"ship_engine.png"},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand}
})

minetest.register_node("ship:farm", {
    description = "Generates food so that your crew can survive",
    tiles = {"ship_farm.png"},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand}
})

minetest.register_node("ship:generator", {
    description = "Allows the rest of the ship to have power",
    tiles = {"ship_generator.png"},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand}
})

minetest.register_node("ship:lifesupport", {
    description = "What allows you crew to live you got to breath",
    tiles = {"ship_lifesupport.png"},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand}
})

minetest.register_node("ship:salvager", {
    description = "Allows you to pick up metal from astroids and derelicts",
    tiles = {"ship_salvager.png"},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand}
})

minetest.register_node("ship:scanner", {
    description = "Allows you to see whats out there",
    tiles = {"ship_scanner.png"},
    is_ground_content = false,
    groups = {oddly_breakable_by_hand}
})

--------------------------------------
--Create metatable for component Nodes
--------------------------------------
