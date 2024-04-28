-- Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Parent.Parent.promise)
local Types = require(script.Parent.Parent.Types)

local Reliable = ReplicatedStorage:WaitForChild("FrameworkReliable")

local NextShared = 0
local NextUnique = 0

-- Functions

local function UInt(int: number)
	return string.pack(`I{math.ceil(math.log(int + 1, 2) / 8)}`, int)
end

local function Shared(name: string): Types.Promise<any>
	return Promise.new(function(resolve)
		if RunService:IsServer() then
			if Reliable:GetAttribute(name) then
				resolve(Reliable:GetAttribute(name))
			else
				NextShared += 1
				local Id = UInt(NextShared)
				Reliable:SetAttribute(name, Id)
				resolve(Id)
			end
		else
			local delayReject = task.delay(5, function()
				warn(`[Lumin] Infinite yield possible on identifier '{name}'`)
			end)

			while not Reliable:GetAttribute(name) do
				Reliable.AttributeChanged:Wait()
			end

			task.cancel(delayReject)
			resolve(Reliable:GetAttribute(name))
		end
	end)
end

local function Exists(name: string)
	return RunService:IsServer() and Reliable:GetAttribute(name) ~= nil
end

local function Unique()
	NextUnique += 1
	if NextUnique == 0xFFFF then
		NextUnique = 0
	end
	return UInt(NextUnique)
end

return {
	Shared = Shared,
	Exists = Exists,
	Unique = Unique,
}
