-- ==========================================
-- Qz Pro Sniper System | Final Ultimate Fix
-- ==========================================

local successLib, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successLib or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "🔥 Qz Pro Sniper | Run a Restaurant",
    LoadingTitle = "جاري تشغيل نظام القنص...",
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
            Rayfield:Notify({Title = "تم التفعيل", Content = "البوت يراقب السوق الآن...", Duration = 3})
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

-- البحث عن جميع قنوات الاتصال المتاحة في اللعبة لضمان العثور على دالة الشراء
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local network = ReplicatedStorage:WaitForChild("Network", 5)

task.spawn(function()
    while true do
        if ToggleStatus and network then
            -- جلب السوق
            local marketRemote = network:FindFirstChild("RemoteFunction")
            local success, marketItems = pcall(function()
                return marketRemote:InvokeServer("GetMarket")
            end)
            
            if success and typeof(marketItems) == "table" then
                for i, item in pairs(marketItems) do
                    if item then
                        local itemPrice = tonumber(item.Price or item.Cost or 0)
                        local itemId = item.Id or item.ID or item.UUID or i
                        
                        -- إذا كان السعر ضمن الحد المسموح
                        if itemPrice > 0 and itemPrice <= TargetMaxPrice then
                            -- تجربة إرسال طلب الشراء عبر كل الـ Remotes المتاحة في الشبكة
                            for _, remote in pairs(network:GetChildren()) do
                                pcall(function()
                                    if remote:IsA("RemoteFunction") then
                                        remote:InvokeServer("Buy", itemId)
                                        remote:InvokeServer("BuyItem", itemId)
                                        remote:InvokeServer("Purchase", itemId)
                                    elseif remote:IsA("RemoteEvent") then
                                        remote:FireServer("Buy", itemId)
                                        remote:FireServer("BuyItem", itemId)
                                        remote:FireServer("Purchase", itemId)
                                    end
                                end)
                            end
                            
                            Rayfield:Notify({
                                Title = "⚡ محاولة قنص!",
                                Content = "تم إرسال أمر شراء لعنصر بسعر: " .. tostring(itemPrice) .. "💎",
                                Duration = 2,
                            })
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)
