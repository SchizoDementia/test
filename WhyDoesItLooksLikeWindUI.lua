-- Credits to https://scriptblox.com/u/blud_wtf (blud_wtf in discord) and me 
-- noobs, they used Claude AI
-- Modified by @lightgray2, and thanks for the comments to guide.
-- I removed comments, and it's EASY TO MODIFY
-- OG; https://raw.githubusercontent.com/ilovechubbyorangecat/script/refs/heads/main/notification.lua
local library = {}

local TweenService = game:GetService("TweenService")
local Players = game.Players

local CONFIG = {
	NotificationWidth = 350,
	NotificationHeight = 80,  -- Base height, might grow with content
	Padding = 10,             -- Space between notifications
	InternalPadding = 10,     -- Padding inside the notification frame
	IconSize = 40,
	DisplayTime = 5,          -- How long notifications stay visible

	BackgroundColor = Color3.fromRGB(45, 45, 45),
	BackgroundTransparency = 0.1,
	StrokeColor = Color3.fromRGB(80, 80, 80),
	StrokeThickness = 1,
	TextColor = Color3.fromRGB(240, 240, 240),

	TitleFont = Enum.Font.SourceSansSemibold,
	TitleSize = 18,
	ContentFont = Enum.Font.SourceSans,
	ContentSize = 15,

	EntryEasingStyle = Enum.EasingStyle.Back,
	EntryEasingDirection = Enum.EasingDirection.Out,
	EntryTime = 0.5,

	ExitEasingStyle = Enum.EasingStyle.Quad,
	ExitEasingDirection = Enum.EasingDirection.In,
	ExitTime = 0.4,

	Icons = {
		Info = "rbxassetid://112082878863231",
		Warn = "rbxassetid://117107314745025",
		Error = "rbxassetid://77067602950967",
		hi = "rbxassetid://0", -- vrey god iocon
	}
}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = nil
local notificationList = {}
local isInitialized = false

local function initializeUI()
	if isInitialized then return end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EnhancedNotifUI"
	screenGui.Parent = playerGui
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999 -- High display order
	screenGui.ResetOnSpawn = false -- Keep UI persistent across respawns

	isInitialized = true
end

local function updateNotificationPositions()
	if not screenGui then return end

	local currentY = -CONFIG.Padding
	local itemsToRemove = {}

	for i = 1, #notificationList do
		local notifFrame = notificationList[i]
		if not notifFrame or not notifFrame.Parent then
			table.insert(itemsToRemove, i)
		end

		local targetPos = UDim2.new(
			1, -CONFIG.Padding,          -- X: Right side with padding
			1, currentY                  -- Y: Calculated stacked position
		)

		notifFrame:TweenPosition(
			targetPos,
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			0.3,
			true
		)
		currentY = currentY - (notifFrame.AbsoluteSize.Y + CONFIG.Padding)
	end

	for i = #itemsToRemove, 1, -1 do
		table.remove(notificationList, itemsToRemove[i])
	end
end

local function createNotification(contentText, titleText, notifType)
	initializeUI() -- Ensure the ScreenGui exists

	local frame = Instance.new("Frame")
	frame.Name = "NotificationFrame"
	frame.Position = UDim2.new(1, CONFIG.NotificationWidth + 50, 1, 0)
	frame.Size = UDim2.new(0, CONFIG.NotificationWidth, 0, CONFIG.NotificationHeight) -- Initial height
	frame.AnchorPoint = Vector2.new(1, 1) -- Anchor to BottomRight
	frame.BackgroundColor3 = CONFIG.BackgroundColor
	frame.BackgroundTransparency = CONFIG.BackgroundTransparency
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.LayoutOrder = -#notificationList -- [14 yrs old]: they literally want to sort the notification.
	frame.Parent = screenGui
	frame.AutomaticSize = Enum.AutomaticSize.Y -- spacing ofc

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = CONFIG.StrokeColor
	uiStroke.Thickness = CONFIG.StrokeThickness
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = frame

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, CONFIG.InternalPadding)
	uiPadding.PaddingBottom = UDim.new(0, CONFIG.InternalPadding)
	uiPadding.PaddingLeft = UDim.new(0, CONFIG.InternalPadding)
	uiPadding.PaddingRight = UDim.new(0, CONFIG.InternalPadding)
	uiPadding.Parent = frame

	local iconImage = Instance.new("ImageLabel")
	iconImage.Name = "Icon"
	iconImage.Size = UDim2.new(0, CONFIG.IconSize, 0, CONFIG.IconSize)
	iconImage.BackgroundTransparency = 1
	iconImage.Image = CONFIG.Icons[notifType] or CONFIG.Icons.Info
	iconImage.ScaleType = Enum.ScaleType.Fit
	iconImage.AnchorPoint = Vector2.new(0, 0.5) -- Anchor to vertical center-left
	iconImage.Position = UDim2.new(0, 0, 0.5, 0) -- Position left, vertical center (relative to padding)
	iconImage.Parent = frame

	local iconAspectRatio = Instance.new("UIAspectRatioConstraint")
	iconAspectRatio.AspectRatio = 1.0
	iconAspectRatio.DominantAxis = Enum.DominantAxis.Height
	iconAspectRatio.Parent = iconImage

	local textFrame = Instance.new("Frame")
	textFrame.Name = "TextContainer"
	textFrame.BackgroundTransparency = 1
	textFrame.Size = UDim2.new(1, -(CONFIG.IconSize + CONFIG.InternalPadding + 5), 1, 0) -- Fill width minus icon and some spacing
	textFrame.Position = UDim2.new(0, CONFIG.IconSize + 5, 0, 0) -- Position next to icon
	textFrame.Parent = frame
	textFrame.AutomaticSize = Enum.AutomaticSize.Y -- Let this frame adjust height based on text

	local textListLayout = Instance.new("UIListLayout")
	textListLayout.FillDirection = Enum.FillDirection.Vertical
	textListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	textListLayout.Padding = UDim.new(0, 2) -- Small padding between title and content
	textListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	textListLayout.Parent = textFrame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = titleText or "Notification"
	title.Font = CONFIG.TitleFont
	title.TextSize = CONFIG.TitleSize
	title.TextColor3 = CONFIG.TextColor
	title.TextWrapped = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.BackgroundTransparency = 1
	title.AutomaticSize = Enum.AutomaticSize.Y -- Let height adjust based on text
	title.Size = UDim2.new(1, 0, 0, CONFIG.TitleSize) -- Width = 100%, initial height based on font size
	title.LayoutOrder = 1
	title.Parent = textFrame

	local content = Instance.new("TextLabel")
	content.Name = "Content"
	content.Text = contentText or "Notification Content"
	content.Font = CONFIG.ContentFont
	content.TextSize = CONFIG.ContentSize
	content.TextColor3 = CONFIG.TextColor
	content.TextWrapped = true
	content.TextXAlignment = Enum.TextXAlignment.Left
	content.TextYAlignment = Enum.TextYAlignment.Top
	content.BackgroundTransparency = 1
	content.AutomaticSize = Enum.AutomaticSize.Y -- Let height adjust based on text
	content.Size = UDim2.new(1, 0, 0, CONFIG.ContentSize) -- Width = 100%, initial height based on font size
	content.LayoutOrder = 2
	content.Parent = textFrame

	table.insert(notificationList, 1, frame)
	updateNotificationPositions() -- Shift existing notifications down first
	-- its garbage because, it cant even knows in other executor override.

	local initialTargetY = -CONFIG.Padding
	local initialTargetPos = UDim2.new(1, -CONFIG.Padding, 1, initialTargetY)

	frame:TweenPosition(
		initialTargetPos,
		CONFIG.EntryEasingDirection,
		CONFIG.EntryEasingStyle,
		CONFIG.EntryTime,
		true
	)

	task.delay(CONFIG.DisplayTime, function()
		if frame and frame.Parent then
			local exitPos = UDim2.new(1, CONFIG.NotificationWidth + 50, frame.Position.Y.Scale, frame.Position.Y.Offset)

			local tweenInfo = TweenInfo.new(CONFIG.ExitTime, CONFIG.ExitEasingStyle, CONFIG.ExitEasingDirection)
			local goal = { Position = exitPos, BackgroundTransparency = 1 }
			local tween = TweenService:Create(frame, tweenInfo, goal)

			-- fade out children aswell :skull:
			local childrenTweens = {}
			for _, child in ipairs(frame:GetChildren()) do
				if child:IsA("GuiObject") then
					if child:IsA("UIStroke") then -- Fade Stroke transparency
						table.insert(childrenTweens, TweenService:Create(child, tweenInfo, { Transparency = 1 }))
					elseif child.Name == "Icon" and child:IsA("ImageLabel") then -- Fade Icon image transparency
						table.insert(childrenTweens, TweenService:Create(child, tweenInfo, { ImageTransparency = 1 }))
					elseif child.Name == "TextContainer" then -- Fade TextLabels inside TextContainer
						for _, textChild in ipairs(child:GetChildren()) do
							if textChild:IsA("TextLabel") then
								table.insert(childrenTweens, TweenService:Create(textChild, tweenInfo, { TextTransparency = 1 }))
							end
						end
					end
				end
			end

			tween:Play()
			for _, childTween in ipairs(childrenTweens) do
				childTween:Play()
			end

			tween.Completed:Wait()
			local foundIndex = table.find(notificationList, frame)
			if foundIndex then
				table.remove(notificationList, foundIndex)
			end

			frame:Destroy()

			updateNotificationPositions()
		end
	end)
	
	return frame
end
-- Im sure this is where they stored and index the icon
function library.Info(content, title)
	return createNotification(content or "Information", title or "Info", "Info")
end

function library.Warn(content, title)
	return createNotification(content or "Warning occurred", title or "Warning", "Warn")
end

function library.Error(content, title)
	return createNotification(content or "An error occurred", title or "Error", "Error")
end

function library.hi(content, title)
	return createNotification(content or "Index success failed", title or "hi", "hi") -- i fix and replace parsed
end

return library
