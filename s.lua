-- Custom Sukuna V2 UI
-- สร้าง UI ที่มีลักษณะเหมือนในรูปภาพโดยตรง

-- Core GUI Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- สร้างตัวแปรที่จำเป็น
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ฟังก์ชันสำหรับสร้าง GUI elements
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

-- ฟังก์ชันสำหรับสร้าง tween
local function CreateTween(instance, tweenInfo, properties)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

-- ฟังก์ชันสร้าง Dropdown
local function CreateDropdown(parent, position, size, text, options, defaultOption)
    local dropdown = CreateInstance("Frame", {
        Name = text .. "Dropdown",
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BorderSizePixel = 0,
        Position = position,
        Size = size
    })
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = dropdown,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local description = CreateInstance("TextLabel", {
        Name = "Description",
        Parent = dropdown,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Choose your position while farming.",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local selectedOption = CreateInstance("TextButton", {
        Name = "SelectedOption",
        Parent = dropdown,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.Gotham,
        Text = "  " .. defaultOption,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local arrow = CreateInstance("TextLabel", {
        Name = "Arrow",
        Parent = selectedOption,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.9, 0, 0, 0),
        Size = UDim2.new(0.1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "▼",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14
    })
    
    -- สร้างเมนูตัวเลือก (ซ่อนไว้)
    local optionMenu = CreateInstance("Frame", {
        Name = "OptionMenu",
        Parent = dropdown,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 75),
        Size = UDim2.new(1, 0, 0, #options * 30),
        Visible = false,
        ZIndex = 5
    })
    
    -- เพิ่มตัวเลือกในเมนู
    for i, option in ipairs(options) do
        local optionButton = CreateInstance("TextButton", {
            Name = option,
            Parent = optionMenu,
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, (i-1) * 30),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = "  " .. option,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6
        })
        
        -- เมื่อคลิกที่ตัวเลือก
        optionButton.MouseButton1Click:Connect(function()
            selectedOption.Text = "  " .. option
            optionMenu.Visible = false
        end)
        
        -- Hover effects
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
    end
    
    -- แสดง/ซ่อนเมนูตัวเลือก
    selectedOption.MouseButton1Click:Connect(function()
        optionMenu.Visible = not optionMenu.Visible
    end)
    
    -- ปิดเมนูเมื่อคลิกที่อื่น
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local inDropdown = false
            
            -- ตรวจสอบว่า mouse อยู่ใน dropdown หรือไม่
            local dropdownPos = dropdown.AbsolutePosition
            local dropdownSize = dropdown.AbsoluteSize
            local menuSize = optionMenu.AbsoluteSize
            
            if optionMenu.Visible then
                if mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                   mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y + menuSize.Y then
                    inDropdown = true
                end
                
                if not inDropdown then
                    optionMenu.Visible = false
                end
            end
        end
    end)
    
    return dropdown
end

-- สร้าง main ScreenGui
local ScreenGui = CreateInstance("ScreenGui", {
    Name = "SukunaV2",
    Parent = Player:WaitForChild("PlayerGui"),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- สร้าง main frame
local MainFrame = CreateInstance("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -250, 0.5, -150),
    Size = UDim2.new(0, 500, 0, 300),
    ClipsDescendants = true
})

-- เพิ่มเส้นขอบและมุมโค้ง
local UICorner = CreateInstance("UICorner", {
    Parent = MainFrame,
    CornerRadius = UDim.new(0, 6)
})

-- สร้าง Title bar
local TitleBar = CreateInstance("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 30)
})

local TitleBarCorner = CreateInstance("UICorner", {
    Parent = TitleBar,
    CornerRadius = UDim.new(0, 6)
})

-- ทำให้ส่วนล่างของ title bar เป็นเหลี่ยม
local TitleBarFix = CreateInstance("Frame", {
    Name = "TitleBarFix",
    Parent = TitleBar,
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 0.5, 0)
})

-- เพิ่มไอคอนที่ title bar
local TitleIcon = CreateInstance("ImageLabel", {
    Name = "TitleIcon",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 5),
    Size = UDim2.new(0, 20, 0, 20),
    Image = "rbxassetid://6031075938", -- Icon ID สามารถเปลี่ยนได้
    ImageColor3 = Color3.fromRGB(255, 215, 0) -- สีทอง
})

local TitleText = CreateInstance("TextLabel", {
    Name = "TitleText",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 35, 0, 0),
    Size = UDim2.new(0, 200, 1, 0),
    Font = Enum.Font.GothamSemibold,
    Text = "🌟 Sukuna V2 Rerun] Verse Piece by Dennycode",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- ปุ่มปิด
local CloseButton = CreateInstance("TextButton", {
    Name = "CloseButton",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -30, 0, 0),
    Size = UDim2.new(0, 30, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14
})

-- ปุ่ม minimize
local MinimizeButton = CreateInstance("TextButton", {
    Name = "MinimizeButton",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -60, 0, 0),
    Size = UDim2.new(0, 30, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "-",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14
})

-- กดปุ่มปิด = ลบ ScreenGui
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ทำให้สามารถลาก UI ด้วย title bar
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- สร้างส่วน Left sidebar
local LeftSidebar = CreateInstance("Frame", {
    Name = "LeftSidebar",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(0, 150, 1, -30)
})

-- สร้าง highlight bar สำหรับแท็บที่เลือก
local SelectedTabHighlight = CreateInstance("Frame", {
    Name = "SelectedTabHighlight",
    Parent = LeftSidebar,
    BackgroundColor3 = Color3.fromRGB(0, 120, 215),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0, 5, 0, 40)
})

-- สร้างพื้นที่เนื้อหา (Content area)
local ContentArea = CreateInstance("Frame", {
    Name = "ContentArea",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 150, 0, 30),
    Size = UDim2.new(1, -150, 1, -30)
})

-- สร้างหน้าแท็บต่างๆ
local Tab = {}
local TabButtons = {}
local CurrentTab = "FarmSettings"

-- ฟังก์ชันสร้างแท็บ
local function CreateTab(name, icon, order)
    -- สร้างปุ่มแท็บ
    local tabButton = CreateInstance("TextButton", {
        Name = name .. "Button",
        Parent = LeftSidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40 * (order - 1)),
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14
    })
    
    -- เพิ่มไอคอนให้กับปุ่ม
    local tabIcon = CreateInstance("TextLabel", {
        Name = "Icon",
        Parent = tabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Font = Enum.Font.Gotham,
        Text = icon,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14
    })
    
    -- เพิ่มข้อความให้กับปุ่ม
    local tabText = CreateInstance("TextLabel", {
        Name = "Text",
        Parent = tabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- สร้าง content frame สำหรับแท็บนี้
    local contentFrame = CreateInstance("Frame", {
        Name = name .. "Tab",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    
    -- เพิ่ม title สำหรับแท็บ
    local tabTitle = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = contentFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 10),
        Size = UDim2.new(1, -40, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- บันทึกแท็บและปุ่ม
    Tab[name] = contentFrame
    TabButtons[name] = tabButton
    
    -- ฟังก์ชันเมื่อคลิกที่ปุ่มแท็บ
    tabButton.MouseButton1Click:Connect(function()
        -- ซ่อนแท็บปัจจุบัน
        if Tab[CurrentTab] then
            Tab[CurrentTab].Visible = false
        end
        
        -- แสดงแท็บที่เลือก
        Tab[name].Visible = true
        CurrentTab = name
        
        -- เลื่อน highlight ไปยังแท็บที่เลือก
        local highlightTween = CreateTween(SelectedTabHighlight, TweenInfo.new(0.3), {
            Position = UDim2.new(0, 0, 0, 40 * (order - 1))
        })
        highlightTween:Play()
    end)
    
    return contentFrame
end

-- สร้างแท็บต่างๆ ตามที่เห็นในรูปภาพ
local FarmSettingsTab = CreateTab("Farm Settings", "📋", 1)
local GeneralTab = CreateTab("General", "👑", 2)
local QuestTab = CreateTab("Quest", "📜", 3)
local BossTab = CreateTab("Boss", "👹", 4)
local DungeonTab = CreateTab("Dungeon", "🏯", 5)
local StatsTab = CreateTab("Stats / Teleport", "📊", 6)
local SettingsTab = CreateTab("Settings", "⚙️", 7)

-- แสดงแท็บ Farm Settings เป็นค่าเริ่มต้น
Tab["Farm Settings"].Visible = true

-- เพิ่มเนื้อหาใน Farm Settings Tab ตามในรูปภาพ
local FarmingPositionDropdown = CreateDropdown(
    FarmSettingsTab,
    UDim2.new(0, 20, 0, 60),
    UDim2.new(1, -40, 0, 80),
    "Select Farming Position",
    {"Above", "Below", "Behind", "Front"},
    "Above"
)

local AttackTypeDropdown = CreateDropdown(
    FarmSettingsTab,
    UDim2.new(0, 20, 0, 160),
    UDim2.new(1, -40, 0, 80),
    "Select M1 Attack Type",
    {"Combat", "Sword", "Fruit", "Gun"},
    "Combat"
)

-- ปรับข้อความคำอธิบาย
FarmingPositionDropdown.Description.Text = "Choose your position while farming."
AttackTypeDropdown.Description.Text = "Choose the type of M1 attack for Auto Attack."

-- เพิ่ม dropdown สำหรับเลือกอาวุธ (เพิ่มจากในรูปภาพ)
local WeaponDropdown = CreateDropdown(
    FarmSettingsTab,
    UDim2.new(0, 20, 0, 260),
    UDim2.new(1, -40, 0, 80),
    "Select M1 Attack Weapon",
    {"Uraume", "Tekkai", "Shank's Blade", "Kiribachi", "Saber"},
    "Uraume"
)

WeaponDropdown.Description.Text = "Choose the Weapon of M1 attack for Auto Attack."