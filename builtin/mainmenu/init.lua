-- Luanti
-- Copyright (C) 2014 sapier
-- SPDX-License-Identifier: LGPL-2.1-or-later

MAIN_TAB_W = 15.5
MAIN_TAB_H = 7.1
TABHEADER_H = 0.85
GAMEBAR_H = 1.25
GAMEBAR_OFFSET_DESKTOP = 0.375
GAMEBAR_OFFSET_TOUCH = 0.15

local menupath = core.get_mainmenu_path()
local basepath = core.get_builtin_path()
defaulttexturedir = core.get_texturepath_share() .. DIR_DELIM .. "base" .. DIR_DELIM .. "pack" .. DIR_DELIM

dofile(basepath .. "common" .. DIR_DELIM .. "filterlist.lua")
dofile(menupath .. DIR_DELIM .. "common.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "dialog.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "buttonbar.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "tabview.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "ui.lua")
dofile(menupath .. DIR_DELIM .. "game_theme.lua")
dofile(menupath .. DIR_DELIM .. "dlg_create_world.lua")
dofile(menupath .. DIR_DELIM .. "content/pkgmgr.lua")
dofile(basepath .. DIR_DELIM .. "uifw.lua")

local main_menu = widget("main_menu", "toplevel", function(ui) 
	size		(ui, { w = 5, h = 7 })
	position	(ui, { x = 0.5, y = 0.6 })
	style		(ui, StyleType.BUTTON, {
		bgcolor 				= "#3366FF",
		bgcolor_hovered 	= "#5588FF",
		bgcolor_pressed 	= "#1144DD",
		textcolor 			= "#FFFFFF",
		border 				= "true",
		font_size 			= "*2.0"
	})

	button(ui, { 
		x = 0, y = 0.5, 
		w = 5, h = 2, 
		name = "btn_singleplayer", 
		label = fgettext("Singleplayer"),

		on_click = function(widget)
			local dialog = create_create_world_dlg()
			dialog:set_parent(widget)
			widget:hide()
			dialog:show()
		end
	})

	button(ui, { 
		x = 0, y = 1.5, 
		w = 5, h = 2, 
		name = "btn_multiplayer", 
		label = fgettext("Multiplayer"),

		on_click = function(_)
			-- Show server list
		end
	})

	button(ui, { 
		x = 0, y = 2.5, 
		w = 5, h = 2, 
		name = "btn_settings", 
		label = fgettext("Settings"),

		on_click = function(widget)
			-- Show settings dialog
		end
	})

	button(ui, { 
		x = 0, y = 3.5, 
		w = 5, h = 2, 
		name = "btn_quit", 
		label = fgettext("Exit"),

		on_click = function(_)
			core.close()
		end
	})
end)

local function show_menu()
	gamedata.worldindex = 0

	menudata.worldlist = filterlist.create(
		core.get_worlds,
		compare_worlds,
		-- Unique id comparison function
		function(element, uid)
			return element.name == uid
		end,
		-- Filter function
		function(element, gameid)
			return element.gameid == gameid
		end
	)

	menudata.worldlist:add_sort_mechanism("alphabetic", sort_worlds_alphabetic)
	menudata.worldlist:set_sortmode("alphabetic")

	mm_game_theme.init()
	mm_game_theme.set_dirt_bg()

	local games = core.get_games()
	if games and #games > 0 then
		mm_game_theme.set_game(games[1])
	else
		mm_game_theme.set_engine()
	end

	ui.add(main_menu)
	ui.set_default("main_menu")
	ui.update()
end

show_menu()

local function my_dialog_formspec(dialogdata)
    return "formspec_version[6]" ..
        "size[8,5]" ..
        "label[0.5,0.5;This is my custom dialog]" ..
        "button[1,3;3,0.8;btn_ok;OK]" ..
        "button[4,3;3,0.8;btn_cancel;Cancel]"
end

local function my_dialog_buttonhandler(this, fields)
	if fields.btn_ok then
		this:delete()
		return true
	end
	
	if fields.btn_cancel then
		this:delete()
		return true
	end
	
	return false
end

local function my_dialog_eventhandler(event)
	if event == "DialogShow" then
		-- Don't change theme when showing dialog
		return true
	end
	
	if event == "DialogHide" then
		-- Theme will be restored by parent's show() method
		return true
	end

	return false
end

function create_my_dialog()
	local dlg = dialog_create(
		"my_dialog",
		my_dialog_formspec,
		my_dialog_buttonhandler,
		my_dialog_eventhandler
	)

	return dlg
end

-- dofile(menupath .. DIR_DELIM .. "async_event.lua")
-- dofile(menupath .. DIR_DELIM .. "content" .. DIR_DELIM .. "init.lua")
-- dofile(menupath .. DIR_DELIM .. "serverlistmgr.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_config_world.lua")
-- dofile(basepath .. "common" .. DIR_DELIM .. "settings" .. DIR_DELIM .. "init.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_create_world.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_delete_content.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_delete_world.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_register.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_rename_modpack.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_version_info.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_reinstall_mtg.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_rebind_keys.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_clients_list.lua")
-- dofile(menupath .. DIR_DELIM .. "dlg_server_list_mods.lua")
-- dofile(basepath .. "common" .. DIR_DELIM .. "menu.lua")

-- local tabs = {
-- 	content  = dofile(menupath .. DIR_DELIM .. "tab_content.lua"),
-- 	about = dofile(menupath .. DIR_DELIM .. "tab_about.lua"),
-- 	local_game = dofile(menupath .. DIR_DELIM .. "tab_local.lua"),
-- 	play_online = dofile(menupath .. DIR_DELIM .. "tab_online.lua")
-- }

-- local function main_event_handler(tabview, event)
-- 	if event == "MenuQuit" then
-- 		local show_dialog = core.settings:get_bool("enable_esc_dialog")
-- 		if not ui.childlist["mainmenu_quit_confirm"] and show_dialog then
-- 			tabview:hide()
-- 			local dlg = create_exit_dialog()
-- 			dlg:set_parent(tabview)
-- 			dlg:show()
-- 		else
-- 			core.close()
-- 		end
-- 		return true
-- 	end
-- 	return true
-- end

-- local function init_globals()
-- 	-- Permanent warning if on an unoptimized debug build
-- 	if core.is_debug_build() then
-- 		local set_topleft_text = core.set_topleft_text
-- 		core.set_topleft_text = function(s)
-- 			s = core.colorize("#f22", core.gettext("Debug build, expect worse performance"))
-- 			set_topleft_text(s)
-- 		end
-- 	end

-- 	-- Init gamedata
-- 	gamedata.worldindex = 0

-- 	menudata.worldlist = filterlist.create(
-- 		core.get_worlds,
-- 		compare_worlds,
-- 		-- Unique id comparison function
-- 		function(element, uid)
-- 			return element.name == uid
-- 		end,
-- 		-- Filter function
-- 		function(element, gameid)
-- 			return element.gameid == gameid
-- 		end
-- 	)

-- 	menudata.worldlist:add_sort_mechanism("alphabetic", sort_worlds_alphabetic)
-- 	menudata.worldlist:set_sortmode("alphabetic")

-- 	mm_game_theme.init()
-- 	mm_game_theme.set_engine() -- This is just a fallback.

-- 	-- Create main tabview
-- 	local tv_main = tabview_create("maintab", {x = MAIN_TAB_W, y = MAIN_TAB_H}, {x = 0, y = 0})

-- 	tv_main:set_autosave_tab(true)
-- 	tv_main:add(tabs.local_game)
-- 	tv_main:add(tabs.play_online)
-- 	tv_main:add(tabs.content)
-- 	tv_main:add(tabs.about)

-- 	tv_main:set_global_event_handler(main_event_handler)
-- 	tv_main:set_fixed_size(false)

-- 	local last_tab = core.settings:get("maintab_LAST")
-- 	if last_tab and tv_main.current_tab ~= last_tab then
-- 		tv_main:set_tab(last_tab)
-- 	end

-- 	tv_main:set_end_button({
-- 		icon = defaulttexturedir .. "settings_btn.png",
-- 		label = fgettext("Settings"),
-- 		name = "open_settings",
-- 		on_click = function(tabview)
-- 			local dlg = create_settings_dlg()
-- 			dlg:set_parent(tabview)
-- 			tabview:hide()
-- 			dlg:show()
-- 			return true
-- 		end,
-- 	})

-- 	ui.set_default("maintab")
-- 	tv_main:show()
-- 	ui.update()

-- 	-- synchronous, chain parents to only show one at a time
-- 	local parent = tv_main
-- 	parent = migrate_keybindings(parent)
-- end

