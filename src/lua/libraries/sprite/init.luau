local Sprite = { }
local RobloxMaxImageSize = 1024

function Sprite.Animate(image: ImageLabel, imageSize: Vector2, frames: Vector2, fps: number?, imageId: string?)
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
    local TotalFrames = frames.X * frames.Y

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

function Sprite.StopAnimation(image: ImageLabel)
    if image:GetAttribute("IsAnimationActive") then
        image:SetAttribute("IsAnimationActive", false)
    end
end

return Sprite