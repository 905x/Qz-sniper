-- ==========================================
-- Qz Pro Sniper System | Category Edition
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
            Rayfield:Notify({Title = "تم التفعيل", Content = "البوت يراقب السوق بالفئات...", Duration = 3})
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
            
            -- تجربة جلب السوق مع تمرير الفئات المستهدفة مباشرة (مثل Basic Stove)
            local categories = {"Basic Stove", "Titanium Fridge", "Carbon Industrial Fridge"}
            local marketItems = nil
            local success = false
            
            for _, cat in ipairs(categories) do
                success, marketItems = pcall(function()
                    return marketRemote:InvokeServer("GetMarket", cat)
                end)
                if success and marketItems and typeof(marketItems) == "table" and next(marketItems) ~= nil then
                    break
                end
                
                -- تجربة بديلة بالاسم فقط
                success, marketItems = pcall(function()
                    return marketRemote:InvokeServer(cat)
                end)
                if success and marketItems and typeof(marketItems) == "table" and next(marketItems) ~= nil then
                    break
                end
            end
            
            if success and typeof(marketItems) == "table" and next(marketItems) ~= nil then
                Rayfield:Notify({
                    Title = "✅ تم العثور على عناصر!",
                    Content = "جاري فحص الشراء...",
                    Duration = 2,
                })
                
                for key, item in pairs(marketItems) do
                    if item then
                        local itemPrice = tonumber(item.Price or item.Cost or item.Value or 0)
                        local itemId = item.Id or item.ID or key
                        
                        if itemPrice > 0 and itemPrice <= TargetMaxPrice then
                            -- تنفيذ الشراء
                            pcall(function()
                                marketRemote:InvokeServer("Buy", itemId)
                                marketRemote:InvokeServer("BuyItem", itemId)
                                marketRemote:InvokeServer("Purchase", itemId)
                            end)
                            
                            Rayfield:Notify({
                                Title = "🎯 تم الشراء!",
                                Content = "تم قنص عنصر بسعر: " .. tostring(itemPrice) .. "💎",
                                Duration = 4,
                            })
                        end
                    end
                end
            else
                -- محاولة أخيرة عامة
                local s2, res2 = pcall(function() return marketRemote:InvokeServer("GetListings") end)
                if s2 and typeof(res2) == "table" then
                    -- تفاعل في حال كانت الدالة اسمها GetListings
                end
            end
        end
        task.wait(1)
    end
end)
