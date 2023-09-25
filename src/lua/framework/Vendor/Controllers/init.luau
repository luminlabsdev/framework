local Controllers = { }
local Vendor = script.Parent.Vendor

-- // Variables

Controllers.SignalController = require(Vendor.SignalController.Init)
Controllers.NetworkController = require(Vendor.NetworkController.Init)

-- // Functions

-- // Actions

return Controllers