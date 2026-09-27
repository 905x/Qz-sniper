-- ==========================================
-- Qz Pro Sniper System | On-Screen Debug
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
local TargetMaxPrice = 15

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
    CurrentValue = 15,
    Callback = function(Value)
        TargetMaxPrice = Value
    end,
})

-- نظام المراقبة مع إشعارات الفحص على الشاشة
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local network = ReplicatedStorage:WaitForChild("Network", 5)
local marketRemote = network and network:WaitForChild("RemoteFunction", 5)

task.spawn(function()
    local lastCheckTime = 0
    while true do
        if ToggleStatus and marketRemote then
            local success, marketItems = pcall(function()
                return marketRemote:InvokeServer("GetMarket")
            end)
            
            if not success or not marketItems then
                success, marketItems = pcall(function()
                    return marketRemote:InvokeServer()
                end)
            end
            
            -- تنبيه لتأكيد أن السكربت يفحص السوق حالياً (يظهر مرة كل 5 ثوانٍ لكي لا يزعجك)
            if tick() - lastCheckTime > 5 then
                lastCheckTime = tick()
                if success then
                    Rayfield:Notify({
                        Title = "🔍 حالة الفحص",
                        Content = "تم الاتصال بالسوق بنجاح وجاري المراقبة...",
                        Duration = 2,
                    })
                else
                    Rayfield:Notify({
                        Title = "⚠️ تنبيه",
                        Content = "فشل استجابة دالة السوق من السيرفر.",
                        Duration = 2,
                    })
                end
            end
            
            if success and typeof(marketItems) == "table" then
                for i, item in pairs(marketItems) do
                    if item then
                        local itemName = item.Name or item.Title or item.ItemName or "عنصر مجهول"
                        local itemPrice = tonumber(item.Price or item.Cost or item.Value or 0)
                        local itemId = item.Id or item.ID or item.UUID or i
                        
                        if itemPrice > 0 and itemPrice <= TargetMaxPrice then
                            Rayfield:Notify({
                                title = "🎯 وجدنا هدفاً!",
                                Content = tostring(itemName) .. " بسعر " .. tostring(itemPrice) .. "💎",
                                Duration = 4,
                            })
                            
                            -- محاولة الشراء
                            pcall(function()
                                return marketRemote:InvokeServer("BuyItem", itemId)
                            end)
                        end
                    end
                end
            end
        end
        task.wait(1.5)
    end
end)
