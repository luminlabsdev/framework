local Package = { }

function Package.GeneratePluginMenuFromStructure(Plugin: Plugin, menuName: string, structure: {any}): PluginMenu?
	if not Plugin then
		return nil
	end
	
	local PluginMenu: PluginMenu = Plugin:CreatePluginMenu(tostring(math.random()), menuName)
	PluginMenu.Name = menuName
	
	for index, menuElementInfo in structure do
		if type(menuElementInfo[1]) == "table" then
			local NewPluginMenu: PluginMenu = Plugin:CreatePluginMenu(tostring(math.random()),
				menuElementInfo[1][2],
				menuElementInfo[1][3]
			)

			NewPluginMenu.Name = menuElementInfo[1][1]

			for index, value in menuElementInfo do
				if index == 1 then
					continue
				end

				NewPluginMenu:AddNewAction(value[1], value[2], value[3])
			end

			PluginMenu:AddMenu(NewPluginMenu)

			continue
		end

		if menuElementInfo == "Sep" then
			PluginMenu:AddSeparator()
			continue
		end

		PluginMenu:AddNewAction(menuElementInfo[1], menuElementInfo[2], menuElementInfo[3])
	end
	
	table.clear(structure)
	PluginMenu.Parent = Plugin
	
	return PluginMenu
end

return Package