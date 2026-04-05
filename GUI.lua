local XenonLibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
if not player then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer
end

local parentGui =
	RunService:IsStudio() and player:WaitForChild("PlayerGui")
	or (CoreGui:FindFirstChild("RobloxGui") and CoreGui or player:WaitForChild("PlayerGui"))

--========================================================
-- Effects & Helpers
--========================================================
local function addRippleEffect(button)
	button.ClipsDescendants = true
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local ripple = Instance.new("Frame")
			ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ripple.BackgroundTransparency = 0.7
			ripple.ZIndex = (button.ZIndex or 1) + 1

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = ripple

			local mousePos = UserInputService:GetMouseLocation()
			local relativeX = mousePos.X - button.AbsolutePosition.X
			local relativeY = mousePos.Y - button.AbsolutePosition.Y

			ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.Parent = button

			local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
			TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, maxSize, 0, maxSize),
				BackgroundTransparency = 1,
			}):Play()

			task.delay(0.6, function()
				if ripple then ripple:Destroy() end
			end)
		end
	end)
end

local function makeButtonPremium(button, hoverVal, defaultVal)
	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button

	addRippleEffect(button)

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Scale = 0.95 }):Play()
		end
	end)

	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(scale, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
	end)

	if hoverVal and defaultVal then
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.25), { BackgroundTransparency = hoverVal }):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.25), { BackgroundTransparency = defaultVal }):Play()
			TweenService:Create(scale, TweenInfo.new(0.5), { Scale = 1 }):Play()
		end)
	end
end

local function createParticleContainer(parent)
	local pContainer = Instance.new("Frame")
	pContainer.Size = UDim2.new(1, 0, 1, 0)
	pContainer.BackgroundTransparency = 1
	pContainer.ZIndex = 0
	pContainer.Parent = parent

	task.spawn(function()
		while task.wait(0.4) do
			if not parent.Visible or not pContainer.Parent then
				continue
			end

			local p = Instance.new("Frame")
			local size = math.random(4, 12)
			p.Size = UDim2.new(0, size, 0, size)
			p.Position = UDim2.new(math.random(), 0, 1.1, 0)
			p.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			p.BackgroundTransparency = math.random(85, 98) / 100
			p.ZIndex = 1
			p.Parent = pContainer

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = p

			local goalX = p.Position.X.Scale + (math.random(-15, 15) / 100)
			
			local tw = TweenService:Create(p, TweenInfo.new(math.random(12, 20), Enum.EasingStyle.Linear), {
				Position = UDim2.new(goalX, 0, -0.2, 0),
				BackgroundTransparency = 1,
			})
			tw:Play()
			tw.Completed:Connect(function()
				if p then p:Destroy() end
			end)
		end
	end)
end

local function shakeWindow(obj)
	local origPos = obj.Position
	for i = 1, 6 do
		local offset = (i % 2 == 0) and 10 or -10
		TweenService:Create(obj, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
			Position = origPos + UDim2.new(0, offset, 0, 0),
		}):Play()
		task.wait(0.05)
	end
	TweenService:Create(obj, TweenInfo.new(0.05, Enum.EasingStyle.Linear), { Position = origPos }):Play()
end

local function addGlassRim(parent)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.6
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
end

--========================================================
-- Localization
--========================================================
XenonLibrary._lang = "EN"

XenonLibrary._t = {
	RU = {
		enterKey = "Введите пароль...",
		login = "ВОЙТИ",
		getKey = "ПОЛУЧИТЬ КЛЮЧ",
		copied = "СКОПИРОВАНО!",
		correct = "ВЕРНО!",
		wrong = "ОШИБКА",
		openHub = "ОТКРЫТЬ МЕНЮ",
		closeHub = "ЗАКРЫТЬ МЕНЮ",
		timeLabel = "Время в игре: %02d:%02d:%02d"
	},
	EN = {
		enterKey = "Enter password...",
		login = "LOGIN",
		getKey = "GET KEY",
		copied = "COPIED!",
		correct = "CORRECT!",
		wrong = "ERROR",
		openHub = "OPEN MENU",
		closeHub = "CLOSE MENU",
		timeLabel = "Time in game: %02d:%02d:%02d"
	},
}

local function L(keyOrTable)
	local lang = XenonLibrary._lang
	if type(keyOrTable) == "table" then
		return keyOrTable[lang] or keyOrTable.EN or keyOrTable.RU or ""
	end
	if type(keyOrTable) == "string" then
		local dict = XenonLibrary._t[lang]
		-- Если ключ не найден в словаре, возвращаем сам текст (позволяет писать свой текст в кнопках)
		return (dict and dict[keyOrTable]) or keyOrTable
	end
	return tostring(keyOrTable)
end

--========================================================
-- Main API: CreateWindow
--========================================================
function XenonLibrary:CreateWindow(Config)
	local Window = {}

	local Title = Config.Name or "Xenon Hub"
	local Subtitle = Config.GameName or "Game"
	local KeySystem = Config.KeySystem or false
	local Key = Config.Key or "1"
	local KeyLink = Config.KeyLink or ""

	local theme = {
		mainColor = Color3.fromRGB(10, 15, 35),
		text = Color3.fromRGB(255, 255, 255),
		dimText = Color3.fromRGB(180, 200, 240),
		glass = 0.1, 
	}

	if parentGui:FindFirstChild("XenonLibraryGUI") then
		parentGui.XenonLibraryGUI:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "XenonLibraryGUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = parentGui

	local localized = {}

	local function register(obj, prop, data)
		table.insert(localized, { obj = obj, prop = prop, data = data })
	end

	local function applyLocalization()
		for _, it in ipairs(localized) do
			if it.obj and it.obj.Parent then
				it.obj[it.prop] = L(it.data)
			end
		end
	end

	-- Language Frame
	local langFrame = Instance.new("Frame")
	langFrame.Size = UDim2.new(0, 350, 0, 200)
	langFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	langFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	langFrame.BackgroundColor3 = theme.mainColor
	langFrame.BackgroundTransparency = theme.glass
	langFrame.ClipsDescendants = true
	langFrame.Parent = gui
	Instance.new("UICorner", langFrame).CornerRadius = UDim.new(0, 15)
	
	addGlassRim(langFrame)
	createParticleContainer(langFrame)

	local lTitle = Instance.new("TextLabel")
	lTitle.Size = UDim2.new(1, 0, 0, 40)
	lTitle.Position = UDim2.new(0, 0, 0, 15)
	lTitle.BackgroundTransparency = 1
	lTitle.Text = Title
	lTitle.TextColor3 = theme.text
	lTitle.Font = Enum.Font.GothamBlack
	lTitle.TextSize = 22
	lTitle.ZIndex = 2
	lTitle.Parent = langFrame

	local ruBtn = Instance.new("TextButton")
	ruBtn.Size = UDim2.new(0, 130, 0, 50)
	ruBtn.Position = UDim2.new(0.25, 0, 0.6, 0)
	ruBtn.AnchorPoint = Vector2.new(0.5, 0)
	ruBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ruBtn.BackgroundTransparency = 0.5
	ruBtn.Text = "🇷🇺 Русский"
	ruBtn.TextColor3 = theme.text
	ruBtn.Font = Enum.Font.GothamMedium
	ruBtn.TextSize = 16
	ruBtn.AutoButtonColor = false
	ruBtn.ZIndex = 2
	ruBtn.Parent = langFrame
	Instance.new("UICorner", ruBtn).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", ruBtn).Color = Color3.fromRGB(255, 255, 255)
	Instance.new("UIStroke", ruBtn).Transparency = 0.5
	makeButtonPremium(ruBtn, 0.3, 0.5)

	local enBtn = Instance.new("TextButton")
	enBtn.Size = UDim2.new(0, 130, 0, 50)
	enBtn.Position = UDim2.new(0.75, 0, 0.6, 0)
	enBtn.AnchorPoint = Vector2.new(0.5, 0)
	enBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	enBtn.BackgroundTransparency = 0.5
	enBtn.Text = "🇬🇧 English"
	enBtn.TextColor3 = theme.text
	enBtn.Font = Enum.Font.GothamMedium
	enBtn.TextSize = 16
	enBtn.AutoButtonColor = false
	enBtn.ZIndex = 2
	enBtn.Parent = langFrame
	Instance.new("UICorner", enBtn).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", enBtn).Color = Color3.fromRGB(255, 255, 255)
	Instance.new("UIStroke", enBtn).Transparency = 0.5
	makeButtonPremium(enBtn, 0.3, 0.5)

	-- Key System Frame
	local keyFrame = Instance.new("Frame")
	keyFrame.Size = UDim2.new(0, 400, 0, 240)
	keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	keyFrame.BackgroundColor3 = theme.mainColor
	keyFrame.BackgroundTransparency = theme.glass
	keyFrame.ClipsDescendants = true
	keyFrame.Visible = false
	keyFrame.Parent = gui
	Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 15)
	
	addGlassRim(keyFrame)
	createParticleContainer(keyFrame)

	local kTitle = Instance.new("TextLabel")
	kTitle.Size = UDim2.new(1, 0, 0, 40)
	kTitle.Position = UDim2.new(0, 0, 0, 20)
	kTitle.BackgroundTransparency = 1
	kTitle.Text = Title
	kTitle.TextColor3 = theme.text
	kTitle.Font = Enum.Font.GothamBlack
	kTitle.TextSize = 24
	kTitle.ZIndex = 2
	kTitle.Parent = keyFrame

	local keyInput = Instance.new("TextBox")
	keyInput.Size = UDim2.new(0, 250, 0, 45)
	keyInput.Position = UDim2.new(0.5, 0, 0.45, 0)
	keyInput.AnchorPoint = Vector2.new(0.5, 0)
	keyInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	keyInput.BackgroundTransparency = 0.5
	keyInput.TextColor3 = theme.text
	keyInput.Font = Enum.Font.GothamMedium
	keyInput.TextSize = 16
	keyInput.Text = ""
	keyInput.ZIndex = 2
	keyInput.Parent = keyFrame
	Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)
	local keyStroke = Instance.new("UIStroke", keyInput)
	keyStroke.Color = Color3.fromRGB(255, 255, 255)
	keyStroke.Transparency = 0.7
	register(keyInput, "PlaceholderText", "enterKey")

	local getKeyBtn = Instance.new("TextButton")
	getKeyBtn.Size = UDim2.new(0, 140, 0, 40)
	getKeyBtn.Position = UDim2.new(0.28, 0, 0.75, 0)
	getKeyBtn.AnchorPoint = Vector2.new(0.5, 0)
	getKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	getKeyBtn.BackgroundTransparency = 0.5
	getKeyBtn.TextColor3 = theme.text
	getKeyBtn.Font = Enum.Font.GothamMedium
	getKeyBtn.TextSize = 13
	getKeyBtn.AutoButtonColor = false
	getKeyBtn.ZIndex = 2
	getKeyBtn.Parent = keyFrame
	Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
	makeButtonPremium(getKeyBtn, 0.3, 0.5)
	register(getKeyBtn, "Text", "getKey")

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 140, 0, 40)
	keyBtn.Position = UDim2.new(0.72, 0, 0.75, 0)
	keyBtn.AnchorPoint = Vector2.new(0.5, 0)
	keyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	keyBtn.BackgroundTransparency = 0.5
	keyBtn.TextColor3 = theme.text
	keyBtn.Font = Enum.Font.GothamMedium
	keyBtn.TextSize = 14
	keyBtn.AutoButtonColor = false
	keyBtn.ZIndex = 2
	keyBtn.Parent = keyFrame
	Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)
	makeButtonPremium(keyBtn, 0.3, 0.5)
	register(keyBtn, "Text", "login")

	-- Open Button
	local openBtn = Instance.new("TextButton")
	openBtn.Size = UDim2.new(0, 160, 0, 45)
	openBtn.AnchorPoint = Vector2.new(0.5, 0)
	openBtn.Position = UDim2.new(0.5, 0, 0, -100)
	openBtn.BackgroundColor3 = theme.mainColor
	openBtn.BackgroundTransparency = theme.glass
	openBtn.TextColor3 = theme.text
	openBtn.Font = Enum.Font.GothamMedium
	openBtn.TextSize = 14
	openBtn.AutoButtonColor = false
	openBtn.Visible = false
	openBtn.Parent = gui
	Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 12)
	local oStroke = Instance.new("UIStroke", openBtn)
	oStroke.Color = Color3.fromRGB(255, 255, 255)
	oStroke.Thickness = 1.5
	makeButtonPremium(openBtn, 0.2, 0.4)

	task.spawn(function()
		while openBtn.Parent do
			task.wait()
			oStroke.Transparency = 0.3 + ((math.sin(tick() * 3) + 1) / 2 * 0.7)
		end
	end)

	-- Main Frame (Hub)
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 650, 0, 420)
	mainFrame.Position = UDim2.new(0.5, 0, 0.15, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0)
	mainFrame.BackgroundColor3 = theme.mainColor
	mainFrame.BackgroundTransparency = theme.glass
	mainFrame.ClipsDescendants = true
	mainFrame.Visible = false
	mainFrame.Parent = gui
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
	
	addGlassRim(mainFrame)
	createParticleContainer(mainFrame)

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 60)
	topBar.BackgroundTransparency = 1
	topBar.ZIndex = 2
	topBar.Parent = mainFrame
	
	local topSeparator = Instance.new("Frame")
	topSeparator.Size = UDim2.new(1, 0, 0, 1)
	topSeparator.Position = UDim2.new(0, 0, 1, 0)
	topSeparator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topSeparator.BackgroundTransparency = 0.8
	topSeparator.Parent = topBar

	local hTitle = Instance.new("TextLabel")
	hTitle.Size = UDim2.new(0.6, 0, 0, 25)
	hTitle.Position = UDim2.new(0, 20, 0, 10)
	hTitle.BackgroundTransparency = 1
	hTitle.Text = Title
	hTitle.TextColor3 = theme.text
	hTitle.Font = Enum.Font.GothamBlack
	hTitle.TextSize = 22
	hTitle.TextXAlignment = Enum.TextXAlignment.Left
	hTitle.Parent = topBar

	local hSub = Instance.new("TextLabel")
	hSub.Size = UDim2.new(0.6, 0, 0, 15)
	hSub.Position = UDim2.new(0, 20, 0, 35)
	hSub.BackgroundTransparency = 1
	hSub.Text = Subtitle
	hSub.TextColor3 = theme.dimText
	hSub.Font = Enum.Font.GothamMedium
	hSub.TextSize = 11
	hSub.TextXAlignment = Enum.TextXAlignment.Left
	hSub.Parent = topBar

	local statsHolder = Instance.new("Frame")
	statsHolder.Size = UDim2.new(0, 160, 0, 40)
	statsHolder.Position = UDim2.new(1, -170, 0, 10)
	statsHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	statsHolder.BackgroundTransparency = 0.5
	statsHolder.Parent = topBar
	Instance.new("UICorner", statsHolder).CornerRadius = UDim.new(0, 8)
	local statsStroke = Instance.new("UIStroke", statsHolder)
	statsStroke.Color = Color3.fromRGB(255, 255, 255)
	statsStroke.Transparency = 0.8

	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Size = UDim2.new(0.5, -8, 1, 0)
	fpsLabel.Position = UDim2.new(0, 8, 0, 0)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Text = "FPS: --"
	fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	fpsLabel.Font = Enum.Font.GothamBold
	fpsLabel.TextSize = 12
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.Parent = statsHolder

	local pingLabel = Instance.new("TextLabel")
	pingLabel.Size = UDim2.new(0.5, -8, 1, 0)
	pingLabel.Position = UDim2.new(0.5, 0, 0, 0)
	pingLabel.BackgroundTransparency = 1
	pingLabel.Text = "Ping: --"
	pingLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	pingLabel.Font = Enum.Font.GothamBold
	pingLabel.TextSize = 12
	pingLabel.TextXAlignment = Enum.TextXAlignment.Left
	pingLabel.Parent = statsHolder

	task.spawn(function()
		local lastTime = tick()
		local frameCount = 0
		RunService.RenderStepped:Connect(function()
			frameCount += 1
		end)

		while statsHolder.Parent do
			task.wait(1)
			local now = tick()
			local fps = math.floor(frameCount / math.max(now - lastTime, 1/60))
			frameCount = 0
			lastTime = now

			fpsLabel.TextColor3 = fps >= 50 and Color3.fromRGB(100, 255, 150) or (fps >= 25 and Color3.fromRGB(255, 220, 50) or Color3.fromRGB(255, 80, 80))
			fpsLabel.Text = ("FPS: %d"):format(fps)

			local ok, ping = pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
			if ok then
				pingLabel.TextColor3 = ping <= 80 and Color3.fromRGB(100, 255, 150) or (ping <= 150 and Color3.fromRGB(255, 220, 50) or Color3.fromRGB(255, 80, 80))
				pingLabel.Text = ("Ping: %d ms"):format(ping)
			else
				pingLabel.Text = "Ping: --"
			end
		end
	end)

	local sideBar = Instance.new("Frame")
	sideBar.Size = UDim2.new(0, 180, 1, -60)
	sideBar.Position = UDim2.new(0, 0, 0, 60)
	sideBar.BackgroundTransparency = 1
	sideBar.ZIndex = 2
	sideBar.Parent = mainFrame
	
	local sideSeparator = Instance.new("Frame")
	sideSeparator.Size = UDim2.new(0, 1, 1, 0)
	sideSeparator.Position = UDim2.new(1, 0, 0, 0)
	sideSeparator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sideSeparator.BackgroundTransparency = 0.8
	sideSeparator.Parent = sideBar

	local tabsContainer = Instance.new("Frame")
	tabsContainer.Size = UDim2.new(1, 0, 1, -60)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.Parent = sideBar

	local tLayout = Instance.new("UIListLayout")
	tLayout.Padding = UDim.new(0, 8)
	tLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tLayout.Parent = tabsContainer

	local tabsPad = Instance.new("UIPadding")
	tabsPad.PaddingTop = UDim.new(0, 10)
	tabsPad.Parent = tabsContainer

	local pagesContainer = Instance.new("Frame")
	pagesContainer.Size = UDim2.new(1, -180, 1, -60)
	pagesContainer.Position = UDim2.new(0, 180, 0, 60)
	pagesContainer.BackgroundTransparency = 1
	pagesContainer.ZIndex = 2
	pagesContainer.Parent = mainFrame

	local profFrame = Instance.new("Frame")
	profFrame.Size = UDim2.new(1, -20, 0, 50)
	profFrame.Position = UDim2.new(0, 10, 1, -55)
	profFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	profFrame.BackgroundTransparency = 0.5
	profFrame.Parent = sideBar
	Instance.new("UICorner", profFrame).CornerRadius = UDim.new(0, 10)

	local av = Instance.new("ImageLabel")
	av.Size = UDim2.new(0, 34, 0, 34)
	av.Position = UDim2.new(0, 8, 0.5, -17)
	av.BackgroundTransparency = 1
	av.Parent = profFrame
	Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
	av.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

	local nLabel = Instance.new("TextLabel")
	nLabel.Size = UDim2.new(1, -55, 1, 0)
	nLabel.Position = UDim2.new(0, 50, 0, 0)
	nLabel.BackgroundTransparency = 1
	nLabel.Text = player.DisplayName
	nLabel.TextColor3 = theme.text
	nLabel.Font = Enum.Font.GothamBold
	nLabel.TextSize = 13
	nLabel.TextXAlignment = Enum.TextXAlignment.Left
	nLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nLabel.Parent = profFrame

	local isPExp = false
	local profBtn = Instance.new("TextButton", profFrame)
	profBtn.Size = UDim2.new(1, 0, 1, 0)
	profBtn.BackgroundTransparency = 1
	profBtn.Text = ""
	profBtn.MouseButton1Click:Connect(function()
		isPExp = not isPExp
		if isPExp then
			nLabel.TextTruncate = Enum.TextTruncate.None
			profFrame.ZIndex = 15; nLabel.ZIndex = 16; av.ZIndex = 16
			TweenService:Create(profFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 100, 0, 50), BackgroundTransparency = 0.2
			}):Play()
		else
			TweenService:Create(profFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.new(1, -20, 0, 50), BackgroundTransparency = 0.5
			}):Play()
			task.delay(0.3, function()
				if not isPExp then
					nLabel.TextTruncate = Enum.TextTruncate.AtEnd
					profFrame.ZIndex = 5; nLabel.ZIndex = 6; av.ZIndex = 6
				end
			end)
		end
	end)

	local isOpen = false

	local function showOpenBtn()
		openBtn.Visible = true
		register(openBtn, "Text", "openHub")
		applyLocalization()
		TweenService:Create(openBtn, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 15) }):Play()
	end

	local function showKeyFrame()
		keyFrame.Visible = true
		keyFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(keyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 400, 0, 240) }):Play()
	end

	local function hideLangFrame()
		TweenService:Create(langFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) }):Play()
		task.wait(0.5)
		langFrame.Visible = false
	end

	local function afterLanguageChosen()
		applyLocalization()
		hideLangFrame()
		if not KeySystem then showOpenBtn() else showKeyFrame() end
	end

	ruBtn.MouseButton1Click:Connect(function() XenonLibrary._lang = "RU"; afterLanguageChosen() end)
	enBtn.MouseButton1Click:Connect(function() XenonLibrary._lang = "EN"; afterLanguageChosen() end)

	getKeyBtn.MouseButton1Click:Connect(function()
		if setclipboard then setclipboard(KeyLink) end
		getKeyBtn.Text = L("copied")
		task.wait(1.2)
		getKeyBtn.Text = L("getKey")
	end)

	keyBtn.MouseButton1Click:Connect(function()
		if keyInput.Text == Key then
			keyInput.Text = L("correct")
			keyInput.TextColor3 = Color3.fromRGB(50, 255, 50)
			TweenService:Create(keyStroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(50, 255, 50), Transparency = 0 }):Play()
			task.wait(0.5)
			TweenService:Create(keyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) }):Play()
			task.wait(0.5)
			keyFrame.Visible = false
			showOpenBtn()
		else
			keyInput.Text = L("wrong")
			keyInput.TextColor3 = Color3.fromRGB(255, 50, 50)
			TweenService:Create(keyStroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(255, 50, 50), Transparency = 0 }):Play()
			shakeWindow(keyFrame)
			task.wait(0.5)
			keyInput.Text = ""
			keyInput.TextColor3 = theme.text
			TweenService:Create(keyStroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.7 }):Play()
		end
	end)

	openBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			mainFrame.Visible = true
			register(openBtn, "Text", "closeHub")
			applyLocalization()
			mainFrame.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 650, 0, 420) }):Play()
		else
			register(openBtn, "Text", "openHub")
			applyLocalization()
			local tw = TweenService:Create(mainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
			tw:Play()
			tw.Completed:Wait()
			mainFrame.Visible = false
		end
	end)

	-- Drag Logic
	local dragToggle, dragInput, dragStart, startPos = false, nil, nil, nil
	local targetPos = nil

	topBar.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragToggle = true; dragStart = input.Position; startPos = mainFrame.Position; targetPos = startPos
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
		end
	end)
	topBar.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if (input == dragInput and dragToggle) then
			local delta = input.Position - dragStart
			targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	RunService.RenderStepped:Connect(function()
		if targetPos then mainFrame.Position = mainFrame.Position:Lerp(targetPos, 0.15) end
	end)

	-- API For Tabs
	local firstTab = true
	local allTabs, allPages = {}, {}

	function Window:CreateTab(tabName)
		local Tab = {}

		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, -20, 0, 40)
		tabBtn.BackgroundTransparency = 1
		tabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		tabBtn.Text = "  " .. L(tabName)
		tabBtn.TextColor3 = theme.dimText
		tabBtn.Font = Enum.Font.GothamSemibold
		tabBtn.TextSize = 14
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.AutoButtonColor = false
		tabBtn.Parent = tabsContainer
		Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)
		makeButtonPremium(tabBtn, nil, nil)
		
		-- Если ключа нет в словаре, он просто отобразит текст, что передал пользователь
		register(tabBtn, "Text", { RU = "  " .. L(tabName), EN = "  " .. L(tabName) })

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.ScrollBarThickness = 0
		page.BorderSizePixel = 0
		page.Parent = pagesContainer
		local pLayout = Instance.new("UIListLayout")
		pLayout.Padding = UDim.new(0, 10)
		pLayout.Parent = page
		local pPad = Instance.new("UIPadding")
		pPad.PaddingTop = UDim.new(0, 20); pPad.PaddingLeft = UDim.new(0, 20)
		pPad.Parent = page

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -40, 0, 40)
		title.BackgroundTransparency = 1
		title.TextColor3 = theme.text
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 32
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = page
		register(title, "Text", tabName)

		table.insert(allTabs, tabBtn)
		table.insert(allPages, page)

		local idx = #allTabs
		tabBtn.MouseButton1Click:Connect(function()
			for i, v in ipairs(allPages) do
				v.Visible = false
				TweenService:Create(allTabs[i], TweenInfo.new(0.3), { BackgroundTransparency = 1, TextColor3 = theme.dimText }):Play()
			end
			page.Visible = true
			TweenService:Create(tabBtn, TweenInfo.new(0.3), { BackgroundTransparency = 0.5, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end)

		if firstTab then
			firstTab = false
			page.Visible = true
			tabBtn.BackgroundTransparency = 0.5
			tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		-- API For Elements inside Tab
		function Tab:CreateLabel(textValue)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0, 400, 0, 40)
			lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			lbl.BackgroundTransparency = 0.8
			lbl.TextColor3 = theme.text
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextSize = 14
			lbl.Parent = page
			Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)
			local lStroke = Instance.new("UIStroke", lbl)
			lStroke.Color = Color3.fromRGB(255, 255, 255)
			lStroke.Transparency = 0.8
			register(lbl, "Text", textValue)
			return lbl
		end

		function Tab:CreateButton(textValue, callback, customColor)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 400, 0, 45)
			btn.BackgroundColor3 = customColor or Color3.fromRGB(0, 0, 0)
			btn.BackgroundTransparency = customColor and 0.2 or 0.6
			btn.TextColor3 = theme.text
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 16
			btn.AutoButtonColor = false
			btn.Parent = page
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
			local bStroke = Instance.new("UIStroke", btn)
			bStroke.Color = Color3.fromRGB(255, 255, 255)
			bStroke.Transparency = 0.7
			makeButtonPremium(btn, customColor and 0.1 or 0.4, customColor and 0.2 or 0.6)
			register(btn, "Text", textValue)
			
			btn.MouseButton1Click:Connect(function()
				if callback then pcall(callback, btn) end
			end)
			return btn
		end

		function Tab:CreateTimerLabel()
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0, 400, 0, 40)
			lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			lbl.BackgroundTransparency = 0.8
			lbl.Text = "..."
			lbl.TextColor3 = theme.text
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextSize = 14
			lbl.Parent = page
			Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)
			local lStroke = Instance.new("UIStroke", lbl)
			lStroke.Color = Color3.fromRGB(255, 255, 255)
			lStroke.Transparency = 0.8

			local startTime = os.time()
			task.spawn(function()
				while lbl.Parent do
					task.wait(1)
					local elapsed = os.time() - startTime
					local h = math.floor(elapsed / 3600)
					local m = math.floor((elapsed % 3600) / 60)
					local s = elapsed % 60
					lbl.Text = (XenonLibrary._t[XenonLibrary._lang].timeLabel):format(h, m, s)
				end
			end)
			return lbl
		end

		return Tab
	end

	applyLocalization()
	return Window
end

-- ВОЗВРАЩАЕМ САМУ БИБЛИОТЕКУ!
return XenonLibrary
