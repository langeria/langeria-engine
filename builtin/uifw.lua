StyleType = {
	BUTTON = "button",
	-- other style types
}

function unwrap_or(value, default) 
	if value == nil then
		return default
	else
		return value
	end
end

function on_show(ui, func)
	ui.on_show = func
end

function style(ui, ty, params)
	ui.data = ui.data .. "style_type[" .. ty .. ";"

	local keys = {}
	for k in pairs(params) do
		table.insert(keys, k)
	end
	
	table.sort(keys)

	for i, k in ipairs(keys) do
		local v = params[k]
		ui.data = ui.data .. k .. "=" .. v
		if i < #keys then
			ui.data = ui.data .. ";"
		end
	end

	ui.data = ui.data .. "]"
end

function size(ui, params)
	params.w = unwrap_or(params.w, 0)
	params.h = unwrap_or(params.h, 0)

	ui.data = ui.data .. "size[" .. params.w .. "," .. params.h .. "]"
end

function position(ui, params)
	params.x = unwrap_or(params.x, 0)
	params.y = unwrap_or(params.y, 0)

	ui.data = ui.data .. "position[" .. params.x .. "," .. params.y .. "]"
end

function button(ui, params)
	params.x = unwrap_or(params.x, 0)
	params.y = unwrap_or(params.y, 0)
	params.w = unwrap_or(params.w, 0)
	params.h = unwrap_or(params.h, 0)

	params.name = unwrap_or(params.name, "button")
	params.label = unwrap_or(params.label, "unnamed")

	ui.data = ui.data .. "button[" .. params.x .. "," .. params.y .. ";" ..
		params.w .. "," .. params.h .. ";" ..
		params.name .. ";" .. params.label .. "]"

	ui.functions[params.name] = unwrap_or(params.on_click, function() end)
end

function widget(name, ty, add_widgets)
	local ui = { 
		data = "",
		functions = {},
	}

	add_widgets(ui)

	return {
		name = name,
		type = ty,
		hidden = false,

		get_formspec = function(self)
			if self.hidden then
				return ""
			end
			return ui.data
		end,

		handle_buttons = function(self, fields)
			for k, v in pairs(fields) do
				if k then
					if ui.functions[k] then
						ui.functions[k](self)
						return true
					end
				end
			end
			
			return false
		end,

		show = function(self)
			self.hidden = false

			if ui.on_show then
				ui.on_show(self)
			end
		end,

		hide = function(self)
			self.hidden = true
		end
	}
end