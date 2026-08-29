--[[
    sakura.gg

    FEATURES
    - Premium red/black UI
    - Right Alt opens/closes UI
    - Hold Right Mouse Button (MouseButton2) to lock-on
    - Smooth camera lock-on
    - Torso / UpperTorso targeting
    - Velocity-based prediction
    - FOV-based target selection
    - Line-of-sight check
    - Adjustable aim smoothness
    - Adjustable prediction
    - FOV Circle
    - Respawn support
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local fovCircleEnabled = false
local lockOn = false
local rightMouseHeld = false

local aimSmoothness = 0.15
local prediction = 0.12
local fovRadius = 110

local lockedTarget = nil

-- UI
local uiVisible = true

--==================================================
-- COLORS
--==================================================

local RED = Color3.fromRGB(255, 20, 45)
local BRIGHT_RED = Color3.fromRGB(255, 65, 80)
local DARK_RED = Color3.fromRGB(110, 0, 18)

local BLACK = Color3.fromRGB(5, 5, 7)
local PANEL = Color3.fromRGB(10, 10, 13)
local DARK = Color3.fromRGB(16, 16, 20)
local DARKER = Color3.fromRGB(12, 12, 15)

local WHITE = Color3.fromRGB(245, 245, 248)
local GRAY = Color3.fromRGB(145, 145, 153)
local GREEN = Color3.fromRGB(80, 255, 145)

--==================================================
-- CHARACTER HELPERS
--==================================================

local function getCharacter()
	return player.Character
end

local function getRoot()
	local character = getCharacter()

	return character and character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "sakura.gg"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- MAIN PANEL
--==================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 390, 0, 530)
main.Position = UDim2.new(0.5, -195, 0.5, -265)
main.BackgroundColor3 = PANEL
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 20, 28)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.1
mainStroke.Parent = main

--==================================================
-- SHADOW
--==================================================

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
shadow.Size = UDim2.new(1, 45, 1, 45)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.35
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = 0
shadow.Parent = main

main.ZIndex = 2

--==================================================
-- TOP HEADER
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 82)
header.BackgroundColor3 = BLACK
header.BorderSizePixel = 0
header.ZIndex = 3
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 18)
headerCorner.Parent = header

local headerGlow = Instance.new("Frame")
headerGlow.Position = UDim2.new(0, 0, 1, -2)
headerGlow.Size = UDim2.new(1, 0, 0, 2)
headerGlow.BackgroundColor3 = RED
headerGlow.BorderSizePixel = 0
headerGlow.ZIndex = 4
headerGlow.Parent = header

local logo = Instance.new("TextLabel")
logo.Position = UDim2.new(0, 20, 0, 13)
logo.Size = UDim2.new(0, 200, 0, 30)
logo.BackgroundTransparency = 1
logo.Text = "AK4J4Y"
logo.TextColor3 = WHITE
logo.TextSize = 25
logo.Font = Enum.Font.GothamBlack
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.ZIndex = 5
logo.Parent = header

local logoAccent = Instance.new("TextLabel")
logoAccent.Position = UDim2.new(0, 113, 0, 13)
logoAccent.Size = UDim2.new(0, 80, 0, 30)
logoAccent.BackgroundTransparency = 1
logoAccent.Text = "BY JAYCO"
logoAccent.TextColor3 = RED
logoAccent.TextSize = 10
logoAccent.Font = Enum.Font.GothamBold
logoAccent.TextXAlignment = Enum.TextXAlignment.Left
logoAccent.ZIndex = 5
logoAccent.Parent = header

local version = Instance.new("TextLabel")
version.Position = UDim2.new(0, 21, 0, 43)
version.Size = UDim2.new(0, 200, 0, 18)
version.BackgroundTransparency = 1
version.Text = "PREMIUM CONTROL PANEL"
version.TextColor3 = GRAY
version.TextSize = 9
version.Font = Enum.Font.GothamBold
version.TextXAlignment = Enum.TextXAlignment.Left
version.ZIndex = 5
version.Parent = header

local keyBadge = Instance.new("TextLabel")
keyBadge.AnchorPoint = Vector2.new(1, 0)
keyBadge.Position = UDim2.new(1, -18, 0, 20)
keyBadge.Size = UDim2.new(0, 90, 0, 27)
keyBadge.BackgroundColor3 = DARK
keyBadge.Text = "HOLD RMB"
keyBadge.TextColor3 = RED
keyBadge.TextSize = 9
keyBadge.Font = Enum.Font.GothamBold
keyBadge.ZIndex = 5
keyBadge.Parent = header

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(0, 7)
badgeCorner.Parent = keyBadge

local badgeStroke = Instance.new("UIStroke")
badgeStroke.Color = DARK_RED
badgeStroke.Thickness = 1
badgeStroke.Parent = keyBadge

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 0, 0, 82)
content.Size = UDim2.new(1, 0, 1, -82)
content.BackgroundTransparency = 1
content.ZIndex = 3
content.Parent = main

--==================================================
-- STATUS CARD
--==================================================

local statusCard = Instance.new("Frame")
statusCard.Position = UDim2.new(0, 18, 0, 15)
statusCard.Size = UDim2.new(1, -36, 0, 50)
statusCard.BackgroundColor3 = DARK
statusCard.BorderSizePixel = 0
statusCard.ZIndex = 4
statusCard.Parent = content

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = statusCard

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(45, 45, 50)
statusStroke.Thickness = 1
statusStroke.Parent = statusCard

local statusDot = Instance.new("Frame")
statusDot.Position = UDim2.new(0, 13, 0.5, -5)
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.BackgroundColor3 = GRAY
statusDot.ZIndex = 5
statusDot.Parent = statusCard

local statusDotCorner = Instance.new("UICorner")
statusDotCorner.CornerRadius = UDim.new(1, 0)
statusDotCorner.Parent = statusDot

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0, 32, 0, 0)
status.Size = UDim2.new(1, -42, 1, 0)
status.BackgroundTransparency = 1
status.Text = "LOCK-ON  •  OFF"
status.TextColor3 = GRAY
status.TextSize = 11
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.ZIndex = 5
status.Parent = statusCard

--==================================================
-- SECTION CREATOR
--==================================================

local yPosition = 80

local function createSection(text)
	local section = Instance.new("TextLabel")

	section.Position = UDim2.new(0, 20, 0, yPosition)
	section.Size = UDim2.new(1, -40, 0, 18)
	section.BackgroundTransparency = 1
	section.Text = text
	section.TextColor3 = RED
	section.TextSize = 9
	section.Font = Enum.Font.GothamBlack
	section.TextXAlignment = Enum.TextXAlignment.Left
	section.ZIndex = 5
	section.Parent = content

	yPosition += 25
end

--==================================================
-- TOGGLE CREATOR
--==================================================

local function createToggle(text, defaultState, callback)

	local button = Instance.new("TextButton")
	button.Position = UDim2.new(0, 18, 0, yPosition)
	button.Size = UDim2.new(1, -36, 0, 38)
	button.BackgroundColor3 = DARK
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	button.ZIndex = 5
	button.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(35, 35, 40)
	stroke.Thickness = 1
	stroke.Parent = button

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 13, 0, 0)
	label.Size = UDim2.new(1, -75, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = WHITE
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = button

	local indicator = Instance.new("Frame")
	indicator.AnchorPoint = Vector2.new(1, 0.5)
	indicator.Position = UDim2.new(1, -13, 0.5, 0)
	indicator.Size = UDim2.new(0, 39, 0, 21)
	indicator.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
	indicator.ZIndex = 6
	indicator.Parent = button

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.new(0, 10, 0.5, 0)
	dot.Size = UDim2.new(0, 13, 0, 13)
	dot.BackgroundColor3 = GRAY
	dot.ZIndex = 7
	dot.Parent = indicator

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot

	local state = defaultState

	local function update()
		if state then
			indicator.BackgroundColor3 = DARK_RED
			dot.BackgroundColor3 = RED
			dot.Position = UDim2.new(1, -10, 0.5, 0)
			stroke.Color = RED
		else
			indicator.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
			dot.BackgroundColor3 = GRAY
			dot.Position = UDim2.new(0, 10, 0.5, 0)
			stroke.Color = Color3.fromRGB(35, 35, 40)
		end

		callback(state)
	end

	button.MouseEnter:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = Color3.fromRGB(22, 22, 27)
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = DARK
			}
		):Play()
	end)

	button.MouseButton1Click:Connect(function()
		state = not state
		update()
	end)

	yPosition += 45

	update()

	return button
end

--==================================================
-- VALUE BOX
--==================================================

local function createValueBox(
	labelText,
	defaultValue,
	minValue,
	maxValue,
	callback
)

	local label = Instance.new("TextLabel")
	label.Position = UDim2.new(0, 20, 0, yPosition)
	label.Size = UDim2.new(0, 150, 0, 34)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = WHITE
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 5
	label.Parent = content

	local box = Instance.new("TextBox")
	box.Position = UDim2.new(1, -173, 0, yPosition)
	box.Size = UDim2.new(0, 153, 0, 34)
	box.BackgroundColor3 = DARK
	box.BorderSizePixel = 0
	box.Text = tostring(defaultValue)
	box.TextColor3 = RED
	box.TextSize = 11
	box.Font = Enum.Font.GothamBold
	box.ClearTextOnFocus = false
	box.ZIndex = 5
	box.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = box

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(38, 38, 44)
	stroke.Thickness = 1
	stroke.Parent = box

	box.Focused:Connect(function()
		TweenService:Create(
			stroke,
			TweenInfo.new(0.15),
			{
				Color = RED
			}
		):Play()
	end)

	box.FocusLost:Connect(function()
		TweenService:Create(
			stroke,
			TweenInfo.new(0.15),
			{
				Color = Color3.fromRGB(38, 38, 44)
			}
		):Play()

		local value = tonumber(box.Text)

		if value then
			value = math.clamp(value, minValue, maxValue)

			box.Text = tostring(value)

			callback(value)
		else
			box.Text = tostring(defaultValue)
		end
	end)

	yPosition += 42

	return box
end

--==================================================
-- FOV CIRCLE
--==================================================

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Size = UDim2.new(
	0,
	fovRadius * 2,
	0,
	fovRadius * 2
)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.ZIndex = 1
fovCircle.Parent = gui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = fovCircle

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = RED
circleStroke.Thickness = 2
circleStroke.Transparency = 0.15
circleStroke.Parent = fovCircle

--==================================================
-- SETTINGS
--==================================================

createSection("MAIN")

createToggle("FOV Circle", false, function(enabled)

	fovCircleEnabled = enabled
	fovCircle.Visible = enabled

end)

createSection("LOCK-ON")

createValueBox(
	"Smoothness",
	aimSmoothness,
	0.01,
	1,
	function(value)

		aimSmoothness = value

	end
)

createValueBox(
	"Prediction",
	prediction,
	0,
	1,
	function(value)

		prediction = value

	end
)

createValueBox(
	"FOV Radius",
	fovRadius,
	25,
	500,
	function(value)

		fovRadius = value

		fovCircle.Size = UDim2.new(
			0,
			fovRadius * 2,
			0,
			fovRadius * 2
		)

	end
)

--==================================================
-- TARGET LABEL
--==================================================

local targetLabel = Instance.new("TextLabel")
targetLabel.Position = UDim2.new(0, 20, 1, -34)
targetLabel.Size = UDim2.new(1, -40, 0, 20)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "TARGET  /  NONE"
targetLabel.TextColor3 = GRAY
targetLabel.TextSize = 9
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.ZIndex = 5
targetLabel.Parent = content

--==================================================
-- TARGET PART
--==================================================

local function getAimPart(character)

	if not character then
		return nil
	end

	-- R15
	local upperTorso = character:FindFirstChild("UpperTorso")

	if upperTorso then
		return upperTorso
	end

	-- R6
	local torso = character:FindFirstChild("Torso")

	if torso then
		return torso
	end

	-- Fallback
	return character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- LINE OF SIGHT
--==================================================

local function hasLineOfSight(targetCharacter, targetPart)

	local character = getCharacter()

	if not character or not targetCharacter or not targetPart then
		return false
	end

	local origin = camera.CFrame.Position
	local direction = targetPart.Position - origin

	local params = RaycastParams.new()

	params.FilterType = Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		character
	}

	params.IgnoreWater = true

	local result = workspace:Raycast(
		origin,
		direction,
		params
	)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(targetCharacter)
end

--==================================================
-- TARGET SELECTION
--==================================================

local function getNearestPlayer()

	local character = getCharacter()

	if not character then
		return nil
	end

	local nearest = nil
	local nearestDistance = math.huge

	local viewportSize = camera.ViewportSize

	local screenCenter = Vector2.new(
		viewportSize.X / 2,
		viewportSize.Y / 2
	)

	for _, otherPlayer in ipairs(Players:GetPlayers()) do

		if otherPlayer ~= player then

			local otherCharacter = otherPlayer.Character

			local humanoid =
				otherCharacter
				and otherCharacter:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then

				local aimPart = getAimPart(otherCharacter)

				if aimPart then

					local screenPosition, visible =
						camera:WorldToViewportPoint(
							aimPart.Position
						)

					if visible and screenPosition.Z > 0 then

						local screenPoint = Vector2.new(
							screenPosition.X,
							screenPosition.Y
						)

						local screenDistance =
							(screenPoint - screenCenter).Magnitude

						if screenDistance <= fovRadius
							and screenDistance < nearestDistance
							and hasLineOfSight(
								otherCharacter,
								aimPart
							) then

							nearestDistance = screenDistance
							nearest = otherPlayer

						end
					end
				end
			end
		end
	end

	return nearest
end

--==================================================
-- STATUS
--==================================================

local function updateStatus()

	if lockOn and lockedTarget then

		status.Text =
			"LOCK-ON  •  "
			.. string.upper(lockedTarget.Name)

		status.TextColor3 = RED
		statusDot.BackgroundColor3 = RED

		targetLabel.Text =
			"TARGET  /  "
			.. string.upper(lockedTarget.Name)

		targetLabel.TextColor3 = RED

	else

		status.Text = "LOCK-ON  •  OFF"
		status.TextColor3 = GRAY
		statusDot.BackgroundColor3 = GRAY

		targetLabel.Text = "TARGET  /  NONE"
		targetLabel.TextColor3 = GRAY

	end
end

--==================================================
-- RIGHT MOUSE BUTTON LOCK-ON
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then

		rightMouseHeld = true
		lockOn = true

		lockedTarget = getNearestPlayer()

		updateStatus()

	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton2 then

		rightMouseHeld = false
		lockOn = false
		lockedTarget = nil

		updateStatus()

	end
end)

--==================================================
-- RIGHT ALT UI TOGGLE
--==================================================

local function setUIVisible(visible)

	uiVisible = visible

	if visible then

		main.Visible = true

		main.Size = UDim2.new(
			0,
			370,
			0,
			510
		)

		TweenService:Create(
			main,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			),
			{
				Size = UDim2.new(
					0,
					390,
					0,
					530
				)
			}
		):Play()

	else

		TweenService:Create(
			main,
			TweenInfo.new(
				0.15,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.In
			),
			{
				Size = UDim2.new(
					0,
					370,
					0,
					510
				)
			}
		):Play()

		task.delay(0.15, function()

			if not uiVisible then
				main.Visible = false
			end

		end)
	end
end

UserInputService.InputBegan:Connect(function(input)

	if input.KeyCode == Enum.KeyCode.RightAlt then

		setUIVisible(not uiVisible)

	end
end)

--==================================================
-- SMOOTH CAMERA
--==================================================

local function smoothLookAt(targetPosition, deltaTime)

	local currentPosition = camera.CFrame.Position

	local desiredCFrame =
		CFrame.lookAt(
			currentPosition,
			targetPosition
		)

	-- Frame-rate independent smoothing.
	-- Higher smoothness value = faster tracking.
	local alpha =
		1 - math.exp(
			-math.clamp(aimSmoothness, 0.01, 1)
			* 12
			* deltaTime
		)

	camera.CFrame =
		camera.CFrame:Lerp(
			desiredCFrame,
			alpha
		)
end

--==================================================
-- PREDICTION
--==================================================

local function getPredictedPosition(targetPart)

	if not targetPart then
		return nil
	end

	local velocity = targetPart.AssemblyLinearVelocity

	-- Basic velocity prediction.
	local predictedPosition =
		targetPart.Position
		+
		(
			velocity
			* prediction
		)

	return predictedPosition
end

--==================================================
-- MAIN LOOP
--==================================================

RunService.RenderStepped:Connect(function(deltaTime)

	-- Make absolutely sure lock-on only works
	-- while RMB is physically held.
	if not rightMouseHeld then

		if lockOn or lockedTarget then

			lockOn = false
			lockedTarget = nil

			updateStatus()

		end

		return
	end

	--==================================================
	-- LOCK-ON
	--==================================================

	lockOn = true

	-- Acquire a target if we don't have one.
	if not lockedTarget then

		lockedTarget = getNearestPlayer()

		updateStatus()

	end

	local targetCharacter =
		lockedTarget
		and lockedTarget.Character

	local targetHumanoid =
		targetCharacter
		and targetCharacter:FindFirstChildOfClass("Humanoid")

	local aimPart =
		targetCharacter
		and getAimPart(targetCharacter)

	-- Target is valid.
	if targetHumanoid
		and targetHumanoid.Health > 0
		and aimPart then

		-- Keep checking visibility.
		if hasLineOfSight(
			targetCharacter,
			aimPart
		) then

			local predictedPosition =
				getPredictedPosition(aimPart)

			if predictedPosition then

				smoothLookAt(
					predictedPosition,
					deltaTime
				)

			end

		else

			-- If target goes behind an object,
			-- look for another valid target.
			lockedTarget =
				getNearestPlayer()

			updateStatus()

		end

	else

		-- Target died/despawned.
		lockedTarget =
			getNearestPlayer()

		updateStatus()

	end
end)

--==================================================
-- RESPAWN
--==================================================

player.CharacterAdded:Connect(function()

	lockedTarget = nil
	lockOn = false

	updateStatus()

end)

--==================================================
-- INITIAL STATUS
--==================================================

updateStatus()
