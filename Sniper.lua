-- ==========================================
-- Qz Pro Sniper | Instant Event Listener
-- ==========================================

local successLib, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successLib or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "🔥 Qz Pro Sniper | Run a Restaurant",
    LoadingTitle = "جاري تشغيل القنص اللحظي...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("الرئيسية", 4483362458)
MainTab:CreateSection("إعدادات القنص اللحظي")

local ToggleStatus = false
local TargetMaxPrice = 6

MainTab:CreateToggle({
    Name = "تفعيل القنص الفوري",
    CurrentValue = false,
    Flag = "SniperActive",
    Callback = function(Value)
        ToggleStatus = Value
        if Value then
            Rayfield:Notify({Title = "جاهز!", Content = "البوت يراقب التدفق اللحظي للسوق...", Duration = 3})
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

-- البحث عن أي RemoteEvent يقوم ببث العناصر الجديدة للتحقق الفوري
if network then
    for _, remote in pairs(network:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            remote.OnClientEvent:Connect(function(action, data)
                if ToggleStatus and (action == "NewItem" or action == "MarketUpdate" or typeof(data) == "table") then
                    -- فحص العنصر فور وصوله للبث
                    local items = data or {}
                    if typeof(items) ~= "table" then items = {items} end
                    
                    for _, item in pairs(items) do
                        if item and type(item) == "table" then
                            local price = tonumber(item.Price or item.Cost or 0)
                            local id = item.Id or item.ID or item.UUID
                            
                            if price > 0 and price <= TargetMaxPrice and id then
                                -- إرسال أمر الشراء فوراً قبل أي شخص آخر
                                local marketRemote = network:FindFirstChild("RemoteFunction")
                                if marketRemote then
                                    pcall(function()
                                        marketRemote:InvokeServer("BuyItem", id)
                                    end)
                                    pcall(function()
                                        marketRemote:InvokeServer("Buy", id)
                                    end)
                                    
                                    Rayfield:Notify({
                                        Title = "⚡ تم القنص اللحظي!",
                                        Content = "سعر العنصر: " .. tostring(price) .. "💎",
                                        Duration = 4,
                                    })
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end
