--[=[
	The parent of all classes.

	@class Sprite
]=]
local Sprite = { }
local RobloxMaxImageSize = 1024

--[=[
	Animates the given sprite to play like a GIF.

	@param image ImageLabel -- The image label that the sprite should be animated on
	@param imageSize Vector2 -- The size of the image
	@param frames Vector2 -- The amount of frames on both the X and Y axis
	@param frameNumber number -- The amount of frames in the sprite
	@param fps number? -- The amount of frames per second that the sprite should be played at. Defaults to 30
	@param imageId string? -- The image id that the image label should be set to, defaults to the initial image of the image label
]=]
function Sprite.Animate(image: ImageLabel, imageSize: Vector2, frames: Vector2, frameNumber: number, fps: number?, imageId: string?)
	fps = fps or 30
	imageId = imageId or image.Image

    image:SetAttribute("IsAnimationActive", true)

    if imageId then
        image.Image = imageId
    end
	
	local RealWidth, RealHeight
    local ImageWidth, ImageHeight = imageSize.X, imageSize.Y

	if math.max(ImageWidth, ImageHeight) > RobloxMaxImageSize then -- Compensate roblox size
		local Longest = ImageWidth > ImageHeight and "Width" or "Height"

		if Longest == "Width" then
			RealWidth = RobloxMaxImageSize
			RealHeight = (RealWidth / ImageWidth) * ImageHeight
		elseif Longest == "Height" then
			RealHeight = RobloxMaxImageSize
			RealWidth = (RealHeight / ImageHeight) * ImageWidth
		end
	else
		RealWidth, RealHeight = ImageWidth, ImageHeight
	end
	
	local SingleFrameSize = Vector2.new(RealWidth/frames.Y, RealWidth/frames.X)
    local TotalFrames = frameNumber

	image.ImageRectSize = SingleFrameSize
	
	local CurrentRow, CurrentColumn = 0, 0
	local Offsets = { }
	
	for _ = 1, TotalFrames do
		local CurrentXPosition = CurrentColumn * SingleFrameSize.X
		local CurrentYPosition = CurrentRow * SingleFrameSize.Y
		
		table.insert(Offsets, Vector2.new(CurrentXPosition, CurrentYPosition))
		
		CurrentColumn += 1
		
		if CurrentColumn >= frames.Y then
			CurrentColumn = 0
			CurrentRow += 1
		end
	end
	
	local SpritePlayTime = fps and 1/fps or 0.1
	local CurrentIndex = 0
	
	while image:IsDescendantOf(game) and image:GetAttribute("IsAnimationActive") do
        task.wait(SpritePlayTime)

		CurrentIndex += 1
		image.ImageRectOffset = Offsets[CurrentIndex]
		
		if CurrentIndex >= TotalFrames then
			CurrentIndex = 0
		end
	end
end

--[=[
	Stops the currently playing animation, if any.

	@param image ImageLabel -- The image label that should stop being animated
]=]
function Sprite.StopAnimation(image: ImageLabel)
    if image:GetAttribute("IsAnimationActive") then
        image:SetAttribute("IsAnimationActive", false)
    end
end

return Sprite