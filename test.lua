-- โหลด Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- สร้างหน้าต่าง UI
local Window = Rayfield:CreateWindow({
   Name = "ระบบวาร์ปและเก็บไอเทม",
   LoadingTitle = "กำลังโหลด...",
   LoadingSubtitle = "โดย YourName",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TeleportConfig",
      FileName = "TeleportSystem"
   },
   KeySystem = false
})

-- สร้าง Tab
local TeleportTab = Window:CreateTab("📍 ระบบวาร์ป", 4483362458)
local AutoCollectTab = Window:CreateTab("🔄 ระบบเก็บอัตโนมัติ", 4483362458)

-- ตัวแปรสำหรับเก็บสถานะ
local autoCollectEnabled = false
local autoCollectConnection = nil
local holdKeyE = false
local promptObjects = {}

-- ฟังก์ชันสำหรับการวาร์ปไปยังวัตถุ
local function teleportToObject(objectName)
    -- ฟังก์ชันค้นหาวัตถุจาก Workspace
    local function findObjectInWorkspace(name)
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name == name then
                return obj
            end
        end
        return nil
    end
    
    -- ค้นหาวัตถุ
    local object = findObjectInWorkspace(objectName)
    
    if object then
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        
        -- ตรวจสอบว่าวัตถุมี PrimaryPart หรือไม่
        if object:IsA("Model") and object.PrimaryPart then
            humanoidRootPart.CFrame = object.PrimaryPart.CFrame
        -- หากเป็น BasePart
        elseif object:IsA("BasePart") then
            humanoidRootPart.CFrame = object.CFrame
        -- หากเป็น ProximityPrompt หรือมี ProximityPrompt เป็นลูก
        elseif object:IsA("ProximityPrompt") or object:FindFirstChildOfClass("ProximityPrompt") then
            local promptPart
            if object:IsA("ProximityPrompt") then
                promptPart = object.Parent
            else
                promptPart = object
            end
            
            if promptPart and promptPart:IsA("BasePart") then
                humanoidRootPart.CFrame = promptPart.CFrame
            elseif promptPart and promptPart:IsA("Model") and promptPart.PrimaryPart then
                humanoidRootPart.CFrame = promptPart.PrimaryPart.CFrame
            else
                -- หาพาเรนต์ที่เป็น BasePart หรือ Model
                local parent = object.Parent
                while parent do
                    if parent:IsA("BasePart") then
                        humanoidRootPart.CFrame = parent.CFrame
                        break
                    elseif parent:IsA("Model") and parent.PrimaryPart then
                        humanoidRootPart.CFrame = parent.PrimaryPart.CFrame
                        break
                    end
                    parent = parent.Parent
                end
            end
        -- หากเป็นประเภทอื่นที่มี Position
        elseif object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
            -- หาพาเรนต์ที่เป็น BasePart หรือ Model
            local parent = object.Parent
            while parent do
                if parent:IsA("BasePart") then
                    humanoidRootPart.CFrame = parent.CFrame
                    break
                elseif parent:IsA("Model") and parent.PrimaryPart then
                    humanoidRootPart.CFrame = parent.PrimaryPart.CFrame
                    break
                end
                parent = parent.Parent
            end
            
            -- หากไม่พบพาเรนต์ที่เหมาะสม
            if not parent then
                Rayfield:Notify({
                    Title = "ไม่สามารถวาร์ปได้",
                    Content = "ไม่พบตำแหน่งที่วาร์ปได้สำหรับ " .. objectName,
                    Duration = 3.5,
                    Image = 4483362458
                })
                return
            end
        else
            Rayfield:Notify({
                Title = "ไม่สามารถวาร์ปได้",
                Content = "ประเภทของวัตถุไม่รองรับการวาร์ป: " .. object.ClassName,
                Duration = 3.5,
                Image = 4483362458
            })
            return
        end
        
        Rayfield:Notify({
            Title = "วาร์ปสำเร็จ",
            Content = "คุณได้วาร์ปไปยัง " .. objectName .. " แล้ว",
            Duration = 3.5,
            Image = 4483362458
        })
    else
        Rayfield:Notify({
            Title = "ไม่พบวัตถุ",
            Content = "ไม่พบวัตถุชื่อ " .. objectName .. " ในเกม",
            Duration = 3.5,
            Image = 4483362458
        })
    end
end

-- ฟังก์ชันหา ProximityPrompt ในพื้นที่ใกล้เคียง
local function findNearbyPrompts()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return {} end
    
    local nearbyPrompts = {}
    local searchRadius = 20 -- รัศมีในการค้นหา (หน่วย studs)
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local distance = (parent.Position - humanoidRootPart.Position).Magnitude
                if distance <= searchRadius then
                    table.insert(nearbyPrompts, obj)
                end
            end
        end
    end
    
    return nearbyPrompts
end

-- ฟังก์ชันบันทึก ProximityPrompt
local function savePrompt(prompt)
    -- ตรวจสอบว่ามีใน promptObjects แล้วหรือยัง
    for i, savedPrompt in ipairs(promptObjects) do
        if savedPrompt == prompt then
            return false -- มีอยู่แล้ว ไม่ต้องบันทึกซ้ำ
        end
    end
    
    -- บันทึก ProximityPrompt ใหม่
    table.insert(promptObjects, prompt)
    return true
end

-- ฟังก์ชันลบ ProximityPrompt ที่บันทึกไว้
local function removePrompt(index)
    if promptObjects[index] then
        table.remove(promptObjects, index)
        return true
    end
    return false
end

-- ฟังก์ชันทำงานกับ ProximityPrompt (กด E)
local function firePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt)
        return true
    end
    return false
end

-- ฟังก์ชันสำหรับเก็บไอเทมอัตโนมัติ
local function autoCollect()
    -- ยกเลิกการเชื่อมต่อเดิม (ถ้ามี)
    if autoCollectConnection then
        autoCollectConnection:Disconnect()
        autoCollectConnection = nil
    end
    
    if not autoCollectEnabled then
        Rayfield:Notify({
            Title = "ปิดระบบเก็บอัตโนมัติ",
            Content = "ระบบเก็บไอเทมอัตโนมัติถูกปิดแล้ว",
            Duration = 3.5,
            Image = 4483362458
        })
        return
    end
    
    Rayfield:Notify({
        Title = "เปิดระบบเก็บอัตโนมัติ",
        Content = "ระบบเก็บไอเทมอัตโนมัติกำลังทำงาน",
        Duration = 3.5,
        Image = 4483362458
    })
    
    -- สร้างการเชื่อมต่อสำหรับลูปทำงาน
    autoCollectConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not autoCollectEnabled then 
            autoCollectConnection:Disconnect()
            return 
        end
        
        -- ถ้ากด E ค้าง ให้หา Prompts ใหม่และบันทึก
        if holdKeyE then
            local nearbyPrompts = findNearbyPrompts()
            for _, prompt in ipairs(nearbyPrompts) do
                if savePrompt(prompt) then
                    local parentName = prompt.Parent and prompt.Parent.Name or "Unknown"
                    Rayfield:Notify({
                        Title = "บันทึก Prompt",
                        Content = "บันทึก ProximityPrompt จาก " .. parentName .. " แล้ว",
                        Duration = 2,
                        Image = 4483362458
                    })
                end
            end
        end
        
        -- ทำงานกับ Prompts ที่บันทึกไว้
        for i, prompt in ipairs(promptObjects) do
            -- ตรวจสอบว่า prompt ยังมีอยู่หรือไม่
            if prompt and prompt.Parent then
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    local parent = prompt.Parent
                    if parent and parent:IsA("BasePart") then
                        -- คำนวณระยะห่าง
                        local distance = (parent.Position - humanoidRootPart.Position).Magnitude
                        
                        -- ถ้าอยู่ในระยะทำงาน ให้กด E
                        if distance <= prompt.MaxActivationDistance then
                            firePrompt(prompt)
                        end
                    end
                end
            else
                -- ลบ prompt ที่ไม่มีอยู่แล้วออกจากรายการ
                removePrompt(i)
            end
        end
    end)
end

-- แท็บวาร์ป
TeleportTab:CreateSection("วาร์ปไปยังวัตถุจาก Explorer")

TeleportTab:CreateButton({
   Name = "Chest1",
   Callback = function()
       teleportToObject("Chest1")
   end,
})

TeleportTab:CreateButton({
   Name = "InitialPoses",
   Callback = function()
       teleportToObject("InitialPoses")
   end,
})

TeleportTab:CreateButton({
   Name = "AnimSaves",
   Callback = function()
       teleportToObject("AnimSaves")
   end,
})

TeleportTab:CreateButton({
   Name = "ProximityPrompt",
   Callback = function()
       teleportToObject("ProximityPrompt")
   end,
})

TeleportTab:CreateButton({
   Name = "Model",
   Callback = function()
       teleportToObject("Model")
   end,
})

TeleportTab:CreateButton({
   Name = "ChestViewTitle",
   Callback = function()
       teleportToObject("ChestViewTitle")
   end,
})

TeleportTab:CreateButton({
   Name = "AnimationController",
   Callback = function()
       teleportToObject("AnimationController")
   end,
})

-- เพิ่มช่องค้นหาเพื่อวาร์ปไปยังวัตถุอื่นๆ
TeleportTab:CreateSection("ค้นหาและวาร์ปไปยังวัตถุอื่นๆ")

local searchInput = ""

TeleportTab:CreateInput({
   Name = "ค้นหาวัตถุ",
   PlaceholderText = "ป้อนชื่อวัตถุ...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       searchInput = Text
   end,
})

TeleportTab:CreateButton({
   Name = "วาร์ปไปยังวัตถุที่ค้นหา",
   Callback = function()
       if searchInput ~= "" then
           teleportToObject(searchInput)
       else
           Rayfield:Notify({
               Title = "ข้อผิดพลาด",
               Content = "กรุณาป้อนชื่อวัตถุก่อน",
               Duration = 3.5,
               Image = 4483362458
           })
       end
   end,
})

-- แท็บเก็บไอเทมอัตโนมัติ
AutoCollectTab:CreateSection("การตั้งค่าเก็บไอเทมอัตโนมัติ")

AutoCollectTab:CreateToggle({
   Name = "เปิด/ปิดระบบเก็บอัตโนมัติ",
   CurrentValue = false,
   Flag = "AutoCollectToggle",
   Callback = function(Value)
       autoCollectEnabled = Value
       autoCollect()
   end,
})

AutoCollectTab:CreateToggle({
   Name = "กด E ค้างเพื่อบันทึก ProximityPrompt",
   CurrentValue = false,
   Flag = "HoldEToggle",
   Callback = function(Value)
       holdKeyE = Value
       if Value then
           Rayfield:Notify({
               Title = "เปิดโหมดบันทึก",
               Content = "กด E ค้างเพื่อบันทึก ProximityPrompt ในระยะใกล้เคียง",
               Duration = 3.5,
               Image = 4483362458
           })
       else
           Rayfield:Notify({
               Title = "ปิดโหมดบันทึก",
               Content = "ปิดโหมดบันทึก ProximityPrompt แล้ว",
               Duration = 3.5,
               Image = 4483362458
           })
       end
   end,
})

AutoCollectTab:CreateButton({
   Name = "บันทึก ProximityPrompt ในระยะใกล้เคียง",
   Callback = function()
       local nearbyPrompts = findNearbyPrompts()
       local count = 0
       
       for _, prompt in ipairs(nearbyPrompts) do
           if savePrompt(prompt) then
               count = count + 1
           end
       end
       
       if count > 0 then
           Rayfield:Notify({
               Title = "บันทึกสำเร็จ",
               Content = "บันทึก " .. count .. " ProximityPrompt ในระยะใกล้เคียง",
               Duration = 3.5,
               Image = 4483362458
           })
       else
           Rayfield:Notify({
               Title = "ไม่พบ ProximityPrompt",
               Content = "ไม่พบ ProximityPrompt ใหม่ในระยะใกล้เคียง",
               Duration = 3.5,
               Image = 4483362458
           })
       end
   end,
})

-- สร้างฟังก์ชันอัปเดตรายการ ProximityPrompt
local function updatePromptList(dropdownElement)
    local options = {}
    
    for i, prompt in ipairs(promptObjects) do
        if prompt and prompt.Parent then
            local parentName = prompt.Parent.Name or "Unknown"
            table.insert(options, i .. ": " .. parentName)
        end
    end
    
    if #options == 0 then
        table.insert(options, "ไม่มี ProximityPrompt ที่บันทึกไว้")
    end
    
    dropdownElement:Refresh(options, true)
end

-- สร้างดรอปดาวน์สำหรับแสดงรายการ ProximityPrompt ที่บันทึกไว้
local promptListDropdown = AutoCollectTab:CreateDropdown({
   Name = "รายการ ProximityPrompt ที่บันทึกไว้",
   Options = {"ไม่มี ProximityPrompt ที่บันทึกไว้"},
   CurrentOption = "ไม่มี ProximityPrompt ที่บันทึกไว้",
   Flag = "PromptListDropdown",
   Callback = function(Option)
       -- ไม่ต้องทำอะไรเมื่อเลือก เป็นแค่การแสดงรายการ
   end,
})

-- ปุ่มลบ ProximityPrompt ที่เลือก
AutoCollectTab:CreateButton({
   Name = "ลบ ProximityPrompt ที่เลือก",
   Callback = function()
       local selectedOption = Rayfield.Flags.PromptListDropdown
       if selectedOption and selectedOption ~= "ไม่มี ProximityPrompt ที่บันทึกไว้" then
           -- ดึงเลขลำดับจากตัวเลือกที่เลือก
           local index = tonumber(string.match(selectedOption, "^(%d+):"))
           if index and promptObjects[index] then
               local parentName = promptObjects[index].Parent and promptObjects[index].Parent.Name or "Unknown"
               if removePrompt(index) then
                   Rayfield:Notify({
                       Title = "ลบสำเร็จ",
                       Content = "ลบ ProximityPrompt จาก " .. parentName .. " แล้ว",
                       Duration = 3.5,
                       Image = 4483362458
                   })
                   updatePromptList(promptListDropdown)
               end
           end
       else
           Rayfield:Notify({
               Title = "ไม่สามารถลบได้",
               Content = "กรุณาเลือก ProximityPrompt ที่ต้องการลบก่อน",
               Duration = 3.5,
               Image = 4483362458
           })
       end
   end,
})

-- ปุ่มอัปเดตรายการ ProximityPrompt
AutoCollectTab:CreateButton({
   Name = "อัปเดตรายการ ProximityPrompt",
   Callback = function()
       updatePromptList(promptListDropdown)
       Rayfield:Notify({
           Title = "อัปเดตสำเร็จ",
           Content = "อัปเดตรายการ ProximityPrompt แล้ว",
           Duration = 3.5,
           Image = 4483362458
       })
   end,
})

-- ปุ่มเคลียร์รายการ ProximityPrompt ทั้งหมด
AutoCollectTab:CreateButton({
   Name = "เคลียร์รายการ ProximityPrompt ทั้งหมด",
   Callback = function()
       promptObjects = {}
       updatePromptList(promptListDropdown)
       Rayfield:Notify({
           Title = "เคลียร์สำเร็จ",
           Content = "เคลียร์รายการ ProximityPrompt ทั้งหมดแล้ว",
           Duration = 3.5,
           Image = 4483362458
       })
   end,
})

-- คำแนะนำการใช้งาน
AutoCollectTab:CreateSection("คำแนะนำการใช้งาน")

local collectGuideText = [[
วิธีใช้งานระบบเก็บไอเทมอัตโนมัติ:
1. เปิดใช้งาน "เปิด/ปิดระบบเก็บอัตโนมัติ"
2. เลือกวิธีบันทึก ProximityPrompt:
   - กดปุ่ม "บันทึก ProximityPrompt ในระยะใกล้เคียง" เพื่อบันทึกทั้งหมดในระยะ
   - หรือเปิด "กด E ค้างเพื่อบันทึก ProximityPrompt" และเดินไปใกล้ๆ ไอเทมที่ต้องการบันทึก
3. ระบบจะทำการกด E อัตโนมัติเมื่อคุณเข้าใกล้ไอเทมที่บันทึกไว้
4. คุณสามารถดูรายการที่บันทึกไว้ในดรอปดาวน์ด้านล่าง
5. สามารถลบรายการที่ไม่ต้องการโดยเลือกจากดรอปดาวน์และกด "ลบ ProximityPrompt ที่เลือก"

หมายเหตุ: การเก็บอัตโนมัติอาจถูกตรวจจับโดยระบบป้องกันของเกม ใช้ด้วยความระมัดระวัง
]]

AutoCollectTab:CreateParagraph({
   Title = "คำแนะนำ",
   Content = collectGuideText
})

-- ฟังก์ชันคีย์บอร์ดสำหรับจัดการการกด E ค้าง
local UserInputService = game:GetService("UserInputService")

-- สร้าง Connection สำหรับการกด E
local eKeyDownConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- ถ้าเกมประมวลผลอินพุตแล้ว ให้ออกจากฟังก์ชัน
    
    if input.KeyCode == Enum.KeyCode.E and holdKeyE then
        -- เริ่มต้นการบันทึก ProximityPrompt เมื่อกด E
        local nearbyPrompts = findNearbyPrompts()
        local count = 0
        
        for _, prompt in ipairs(nearbyPrompts) do
            if savePrompt(prompt) then
                count = count + 1
            end
        end
        
        if count > 0 then
            updatePromptList(promptListDropdown)
        end
    end
end)

-- เคลียร์ connections เมื่อสคริปต์ถูกยกเลิก
local destroyFunction = Rayfield.Destroy
Rayfield.Destroy = function()
    if eKeyDownConnection then
        eKeyDownConnection:Disconnect()
    end
    if autoCollectConnection then
        autoCollectConnection:Disconnect()
    end
    destroyFunction()
end