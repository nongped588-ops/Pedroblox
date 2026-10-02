local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()



local state = {
	Fly = false,
	Noclip = false,
	FlySpeed = 50,
}

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "DevTestPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 200, 0, 200)
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main)

local function makeButton(text, y, parent, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(0.9, 0, 0, 30)
	b.Position = pos or UDim2.new(0.05, 0, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Text = text
	b.Parent = parent or main
	Instance.new("UICorner", b)
	return b
end

local function setToggleLook(btn, label, on)
	btn.Text = label .. (on and " : ON" or " : OFF")
	btn.BackgroundColor3 = on and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(40, 40, 40)
end

local flyBtn = makeButton("FLY : OFF", 40)
local noclipBtn = makeButton("NOCLIP : OFF", 80)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.9, 0, 0, 30)
speedBox.Position = UDim2.new(0.05, 0, 0, 120)
speedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.PlaceholderText = "ความเร็วบิน (เช่น 100)"
speedBox.Text = ""
speedBox.Font = Enum.Font.GothamSemibold
speedBox.TextSize = 12
speedBox.Parent = main
Instance.new("UICorner", speedBox)

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(0.9, 0, 0, 30)
hint.Position = UDim2.new(0.05, 0, 0, 160)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(160, 160, 160)
hint.Font = Enum.Font.Gotham
hint.TextSize = 11
hint.Text = "Ctrl + คลิก = เทเลพอร์ต"
hint.Parent = main

local openBtn = makeButton("OPEN", 0, gui, UDim2.new(0, 80, 0, 30), UDim2.new(0, 10, 0, 10))
openBtn.Visible = false

local miniBtn = makeButton("-", 0, main, UDim2.new(0, 25, 0, 25), UDim2.new(1, -60, 0, 5))
local closeBtn = makeButton("X", 0, main, UDim2.new(0, 25, 0, 25), UDim2.new(1, -30, 0, 5))
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

miniBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	openBtn.Visible = false
end)

-- Fly
local flyConn

local function stopFly()
	if flyConn then
		flyConn:Disconnect()
		flyConn = nil
	end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
	end
end

local function startFly()
	stopFly()
	flyConn = RunService.RenderStepped:Connect(function()
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not (root and hum) then
			return
		end

		hum.PlatformStand = true

		local dir = Vector3.zero
		local cf = camera.CFrame
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end

		root.AssemblyLinearVelocity = dir * state.FlySpeed
		root.CFrame = CFrame.new(root.Position, root.Position + cf.LookVector)
	end)
end

flyBtn.MouseButton1Click:Connect(function()
	state.Fly = not state.Fly
	setToggleLook(flyBtn, "FLY", state.Fly)
	if state.Fly then startFly() else stopFly() end
end)

speedBox:GetPropertyChangedSignal("Text"):Connect(function()
	state.FlySpeed = tonumber(speedBox.Text) or 50
end)

-- Noclip
local noclipConn = RunService.Stepped:Connect(function()
	if not state.Noclip then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	state.Noclip = not state.Noclip
	setToggleLook(noclipBtn, "NOCLIP", state.Noclip)
end)

-- Ctrl + Click teleport
local tpConn = UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1
		and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	state.Fly = false
	state.Noclip = false
	stopFly()
	noclipConn:Disconnect()
	tpConn:Disconnect()
	gui:Destroy()
end)