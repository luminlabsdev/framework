local net = require("@lune/net")
local process = require("@lune/process")

local projectRole = "1205321049957339228"

local webhook_url = process.args[1]
local type = process.args[2]
local project = process.args[3]

local projectName = string.split(project, "/")[2]
local formattedProjectName = string.gsub(projectName, "^%a", function(match)
    return string.upper(match)
end)

if type == "announcement" then
	local tag = process.args[4]
    local noPing = process.args[5]
	local response = net.request({
		url = webhook_url,
		method = "POST",
		headers = { ["Content-Type"] = "application/json" },
		body = net.jsonEncode({
			content = if noPing == true then nil else `<@&{projectRole}>`,
			embeds = {
				{
					title = `Release {tag} · {formattedProjectName}`,
					description = `Release notification for the latest version of {formattedProjectName}`,
					url = `https://github.com/luminlabsdev/{projectName}/releases/tag/{tag}`,
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
			embeds = {
				{
					title = title,
					description = `[View issue]({url})`,
					color = 7506646,
				},
			},
			thread_name = `{formattedProjectName} - {title}`,
		}),
	})
	if not response.ok then
		error(`{response.statusCode}:{response.statusMessage}`)
	end
end
