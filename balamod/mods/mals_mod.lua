local j_counting = require("Mods/j_counting")

local mals_mod_config ={
    mod_id = "mals_mod_mal_loc",
    mod_name = "Mals Mod",
    mod_version = "1.0",
    mod_author = "mal_loc",
    mod_description = "Adds a counting joker"
}

table.insert(mods,
{
    mod_id = mals_mod_config.mod_id,
    name = mals_mod_config.mod_name,
    version = mals_mod_config.mod_version,
    description = mals_mod_config.mod_description,
    author = mals_mod_config.mod_author,
    enabled = true,
    on_enable = j_counting.onEnable,
    on_disable = j_counting.onDisable
})