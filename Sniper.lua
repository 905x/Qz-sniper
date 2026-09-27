-- ==========================================
-- Qz Pro Sniper System | Inspector Edition
-- ==========================================

local successLib, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successLib or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "🔥 Qz Pro Sniper | Run a Restaurant",
    LoadingTitle = "جاري تشغيل نظام الفحص...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("الرئيسية", 4483362458)
MainTab:CreateSection("إعدادات القنص")

local ToggleStatus = false
local TargetMaxPrice = 6

MainTab:CreateToggle({
    Name = "تفعيل القنص التلقائي",
    CurrentValue = false,
    Flag = "SniperActive",
    Callback = function(Value)
        ToggleStatus = Value
        if Value then
            Rayfield:Notify({Title = "تم التفعيل", Content = "البوت يفحص عناصر السوق الآن...", Duration = 3})
        end
    end,
})

MainTab:CreateSlider({
    Name = "الحد الأقصى للسعر (جواهر)",
    Range = {1, 50},
    Increment = 1,
    Suffix = "💎",
    CurrentValue = 6,
    Callback = function(Value)
        TargetMaxPrice = Value
    end,
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local network = ReplicatedStorage:WaitForChild("Network", 5)

task.spawn(function()
    while true do
        if ToggleStatus and network then
            local marketRemote = network:FindFirstChild("RemoteFunction")
            local success, marketItems = pcall(function()
                return marketRemote:InvokeServer("GetMarket")
            end)
            
            if success and typeof(marketItems) == "table" then
                -- إذا كان الجدول يحتوي على عناصر، سنقوم بفحص أول عنصر واظهار محتوياته فوراً
                for key, item in pairs(marketItems) do
                    if item then
                        -- إظهار تفاصيل العنصر كإشعار لنرى المفتاح الصحيح للسعر والمعرف
                        local infoText = "Key: " .. tostring(key) .. " | Type: " .. typeof(item)
                        if typeof(item) == "table" then
                            for k, v in pairs(item) do
                                infoText = infoText .. " | " .. tostring(k) .. ": " .. tostring(v)
                            end
                        else
                            infoText = infoText .. " | Val: " .. tostring(item)
                        end
                        
                        Rayfield:Notify({
                            Title = "🔍 فحص بيانات السوق",
                            Content = infoText,
                            Duration = 3,
                        })
                        
                        -- محاولة شراء مباشرة باستخدام المفتاح أو الجدول
                        pcall(function()
                            marketRemote:InvokeServer("Buy", key)
                            marketRemote:InvokeServer("BuyItem", key)
                        end)
                        
                        task.wait(2) -- مهلة بسيطة بين الفحص والاختبار
                    end
                end
            else
                Rayfield:Notify({
                    Title = "⚠️ تنبيه",
                    Content = "جدول السوق فارغ أو أن استجابة GetMarket تحتاج لتخصيص.",
                    Duration = 2,
                })
            end
        end
        task.wait(3)
    end
end)
