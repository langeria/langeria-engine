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
dofile(menupath .. DIR_DELIM .. "dlg_confirm_exit.lua")
dofile(menupath .. DIR_DELIM .. "content/pkgmgr.lua")
dofile(basepath .. DIR_DELIM .. "uifw.lua")

local main_menu = widget("main_menu", "toplevel", function(ui)
	size		(ui, { w = 5, h = 6 })
	position	(ui, { x = 0.5, y = 0.6 })
	style		(ui, StyleType.BUTTON, {
		bgcolor 				= "#3366FF",
		bgcolor_hovered 	= "#5588FF",
		bgcolor_pressed 	= "#1144DD",
		textcolor 			= "#FFFFFF",
		border 				= "true",
		font_size 			= "*2.0"
	})
	style		(ui, StyleType.IMAGE_BUTTON, {
		textcolor 			= "#FFFFFF",
		border 				= "true",
		font_size 			= "*1.75"
	})

	image_button(ui, { 
		x = 0, y = 0.5, 
		w = 5, h = 1.2, 
		texture = "textures/button.png",
		name = "btn_singleplayer", 
		label = fgettext("Singleplayer"),

		on_click = function(widget)
			local dialog = create_create_world_dlg()
			dialog:set_parent(widget)
			widget:hide()
			dialog:show()
		end
	})

	image_button(ui, {
		x = 0, y = 1.75,
		w = 5, h = 1.2,
		texture = "textures/button.png",
		name = "btn_multiplayer",
		label = fgettext("Multiplayer"),

		on_click = function(_)
			gamedata.singleplayer = true
			gamedata.selected_world = menudata.worldlist:get_raw_index(1)

			-- Update last game
			local world = menudata.worldlist:get_raw_element(1)
			local game_obj
			if world then
				game_obj = pkgmgr.find_by_gameid(world.gameid)
				core.settings:set("menu_last_game", game_obj.id)
			end
			core.start()
		end
	});

	image_button(ui, { 
		x = 0, y = 3.0, 
		w = 5, h = 1.2,
		name = "btn_settings", 
		texture = "textures/button.png",
		label = fgettext("Settings"),

		on_click = function(widget)
			-- Show settings dialog
		end
	})

	image_button(ui, { 
		x = 0, y = 4.25, 
		w = 5, h = 1.2,
		name = "btn_quit", 
		texture = "textures/button.png",
		label = fgettext("Exit"),

		on_click = function(widget)
			local dialog = create_exit_dialog()
			dialog:set_parent(widget)
			widget:hide()
			dialog:show()
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