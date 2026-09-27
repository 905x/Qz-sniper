-- ==========================================
-- Qz Pro Sniper | Fast Refresh & Buy System
-- ==========================================

local successLib, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successLib or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "🔥 Qz Pro Sniper | Run a Restaurant",
    LoadingTitle = "جاري تشغيل القنص السريع...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("الرئيسية", 4483362458)
MainTab:CreateSection("إعدادات القنص السريع")

local ToggleStatus = false
local TargetMaxPrice = 6
local TargetCategory = "Basic Stove" -- يمكنك تغيير اسم العنصر المستهدف هنا

MainTab:CreateToggle({
    Name = "تفعيل التحديث والقنص السريع",
    CurrentValue = false,
    Flag = "SniperActive",
    Callback = function(Value)
        ToggleStatus = Value
        if Value then
            Rayfield:Notify({Title = "تم التفعيل", Content = "البوت يبدأ التحديث والشراء السريع...", Duration = 3})
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
local marketRemote = network and network:FindFirstChild("RemoteFunction")

task.spawn(function()
    while true do
        if ToggleStatus and marketRemote then
            -- تنفيذ فكرة التحديث السريع بجلب القائمة وتصفحها برمجياً تماماً مثل الـ Refresh اليدوي
            local success, marketItems = pcall(function()
                return marketRemote:InvokeServer("GetListings", TargetCategory)
            end)
            
            if not success or not marketItems then
                success, marketItems = pcall(function()
                    return marketRemote:InvokeServer("GetMarket", TargetCategory)
                end)
            end
            
            if success and typeof(marketItems) == "table" then
                -- البحث عن أرخص عنصر متاح في القائمة مطابقة للشروط
                for key, item in pairs(marketItems) do
                    if item then
                        local itemPrice = tonumber(item.Price or item.Cost or 0)
                        local itemId = item.Id or item.ID or key
                        
                        if itemPrice > 0 and itemPrice <= TargetMaxPrice then
                            -- إرسال أمر الشراء الفوري
                            local buySuccess = pcall(function()
                                return marketRemote:InvokeServer("BuyItem", itemId)
                            end)
                            
                            if not buySuccess then
                                pcall(function()
                                    return marketRemote:InvokeServer("Buy", itemId)
                                end)
                            end
                            
                            Rayfield:Notify({
                                Title = "🎯 تم قنص العنصر بنجاح!",
                                Content = "السعر: " .. tostring(itemPrice) .. "💎",
                                Duration = 4,
                            })
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
        -- سرعة التحديث كل ثانية تماماً مثل ما تفعل يدوياً
        task.wait(1)
    end
end)
