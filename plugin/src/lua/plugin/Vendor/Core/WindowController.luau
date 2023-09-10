local AlreadyRan = false
local WindowController = { }

if AlreadyRan then
    return function (WindowList)
        AlreadyRan = true
        local Vendor = script.Parent.Parent
        local PluginGuiContents = require(Vendor.Settings.PluginGuiContents)
    
        function WindowController.SetConfirmWindow(text: string, func: () -> ())
            PluginGuiContents.Confirm.MessageText = text
            PluginGuiContents.Confirm.ConfirmFunction = func
        
            WindowController.SetWindow("ConfirmWindow", true)
        end
        
        function WindowController.SetMessageWindow(text: string, color: Color3?)
            PluginGuiContents.Message.MessageText = text
            PluginGuiContents.Message.TextColor = color or Color3.fromRGB(255, 209, 94)
        
            WindowController.SetWindow("MessageWindow", true)
        end
        
        function WindowController.SetWindow(windowName: string, isOpened: boolean?)
            local RequestedWindow = WindowList[windowName]
        
            if type(RequestedWindow) ~= "function" then
                if not RequestedWindow then
                    error(`No window for {windowName}`)
                end
        
                if isOpened == nil then
                    RequestedWindow.state.isOpened:set(not RequestedWindow.isOpened:get())
                else
                    RequestedWindow.state.isOpened:set(isOpened)
                end
            end
        end

        return WindowController
    end
else
    return WindowController
end