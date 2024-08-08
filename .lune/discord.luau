local net = require("@lune/net")
local process = require("@lune/process")

local roleIds = {
	Aegis = "1219124088249782322",
	LuminFramework = "1205321049957339228",
    LuminNet = "1270253679626162197",
	Snacky = "1205321076905869332",
	LuminPluginSuite = "1262079690785558640",
}

local maintainerRoleIds = {
	Aegis = "1265887260046397563",
	LuminFramework = "1265887191922511953",
    LuminNet = "1270141341665333359",
	Snacky = "1265887289976950814",
	LuminPluginSuite = "1265887316858114098",
}

local webhook_url = process.args[1]
local type = process.args[2]
local project = process.args[3]

local projectName = string.split(project, "/")[2]

if type == "announcement" then
	local tag = process.args[4]
    local noPing = process.args[5]
	local response = net.request({
		url = webhook_url,
		method = "POST",
		headers = { ["Content-Type"] = "application/json" },
		body = net.jsonEncode({
			content = if noPing then nil else `<@&{roleIds[projectName]}>`,
			embeds = {
				{
					title = `Release {tag} · lumin-dev/{projectName}`,
					description = `Release notification for the latest version of {projectName}`,
					url = `https://github.com/lumin-dev/{projectName}/releases/tag/{tag}`,
					color = 7506646,
					author = {
						name = "GitHub",
					},
				},
			},
		}),
	})
	if not response.ok then
		error(`{response.statusCode}:{response.statusMessage}`)
	end
elseif type == "event" then
	local title = process.args[4]
	local url = process.args[5]
	local response = net.request({
		url = webhook_url,
		method = "POST",
		headers = { ["Content-Type"] = "application/json" },
		body = net.jsonEncode({
			content = `<@&{maintainerRoleIds[projectName]}>`,
			embeds = {
				{
					title = title,
					description = `[View issue/pull request]({url})`,
					color = 7506646,
				},
			},
			thread_name = `{projectName} - {title}`,
		}),
	})
	if not response.ok then
		error(`{response.statusCode}:{response.statusMessage}`)
	end
end