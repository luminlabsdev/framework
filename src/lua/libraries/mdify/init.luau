-- // Package

--[=[
	The parent of all classes.

	@class MDify
]=]
local MDify = { }

-- // Variables

local MarkdownPatterns = {
	"*%*%*[%w%p%s]-*%*%*",
	"*%*[%w%p%s]-*%*",
	"%*[%w%p%s]-%*",
	"~~[%w%p%s]-~~",
	"`[%w%p%s]-`",
	"__[%w%p%s]-__",
	"==[%w%p%s]-==",
	":[%w%p]+:"
}

local MarkdownSyntax = {
	"***",
	"**",
	"*",
	"~~",
	"`",
	"__",
	"==",
	":"
}

local RichTextSyntax = {
	{"<b><i>", "</i></b>"},
	{"<b>", "</b>"},
	{"<i>", "</i>"},
	{"<s>", "</s>"},
	{"<font family='rbxasset://fonts/families/RobotoMono.json'>", "</font>"},
	{"<u>", "</u>"},
	{"<font color='rgb(255,231,96)'>", "</font>"},
}

local LuaEmoji = require(script.Parent.Vendor["lua-emoji"])

-- // Functions

--[=[
	Converts the provided markdown text to Roblox RichText.

	@param text string -- The markdown text to convert to RichText
	@param emojiColor ("d" | "md" | "m" | "ml" | "l")? -- The skin color of any emojis, such as face or hands.

	@return string
]=]
function MDify.MarkdownToRichText(text: string, emojiColor: ("d" | "md" | "m" | "ml" | "l")?): string
	for patternIndex, markdownPattern in MarkdownPatterns do
		if patternIndex == 8 then
			text = text:gsub(
				markdownPattern,
				LuaEmoji.GetEmoji(emojiColor or "")
			)
			continue
		end
		
		text = text:gsub(
			markdownPattern,
			function(result)
				return `{RichTextSyntax[patternIndex][1]}{result:gsub(MarkdownSyntax[patternIndex], "")}{RichTextSyntax[patternIndex][2]}`
			end
		)
	end
	
	return text
end

-- // Connections

-- // Actions

return MDify