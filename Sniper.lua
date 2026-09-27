-- ==========================================
-- Qz Pro Sniper System | Universal Auto-Scanner
-- ==========================================

local successLib, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successLib or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "🔥 Qz Pro Sniper | Run a Restaurant",
    LoadingTitle = "جاري تشغيل الماسح الشامل...",
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
            Rayfield:Notify({Title = "تم التفعيل", Content = "الماسح الشامل يعمل الآن...", Duration = 3})
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
            -- فحص شامل لكل دالة RemoteFunction داخل مجلد Network لمعرفة أيها يعيد جدول السوق
            for _, remote in pairs(network:GetChildren()) do
                if remote:IsA("RemoteFunction") then
                    -- تجربة استدعاءات مختلفة للحصول على البيانات
                    local tests = {
                        {""},
                        {"GetMarket"},
                        {"GetListings"},
                        {"Market"},
                        {remote.Name},
                        {"Basic Stove"},
                        {1}
                    }
                    
                    for _, args in ipairs(tests) do
                        local success, result = pcall(function()
                            return remote:InvokeServer(unpack(args))
                        end)
                        
                        if success and typeof(result) == "table" and next(result) ~= nil then
                            -- وجدنا الدالة والبيانات الصحيحة!
                            for key, item in pairs(result) do
                                if typeof(item) == "table" then
                                    local itemPrice = tonumber(item.Price or item.Cost or item.Value or 0)
                                    local itemId = item.Id or item.ID or item.UUID or key
                                    
                                    if itemPrice > 0 and itemPrice <= TargetMaxPrice then
                                        -- محاولة الشراء بنفس الدالة الناجحة
                                        pcall(function()
                                            remote:InvokeServer("Buy", itemId)
                                            remote:InvokeServer("BuyItem", itemId)
                                            remote:InvokeServer("Purchase", itemId)
                                            remote:InvokeServer(itemId)
                                        end)
                                        
                                        Rayfield:Notify({
                                            Title = "🎯 تم اكتشاف وقنص عنصر!",
                                            Content = "السعر: " .."💎 " .. tostring(itemPrice),
                                            Duration = 4,
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(1.5)
    end
end)
