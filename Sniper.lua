-- ==========================================
-- Qz Pro Sniper System | GitHub & Rayfield Edition
-- ==========================================

local successLib, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successLib or not Rayfield then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Qz Sniper",
        Text = "❌ خطأ: فشل تحميل واجهة Rayfield!",
        Duration = 5
    })
    return
end

-- إنشاء واجهة التحكم الاحترافية
local Window = Rayfield:CreateWindow({
    Name = "🔥 Qz Pro Sniper | Run a Restaurant",
    LoadingTitle = "جاري تشغيل نظام القنص الذكي...",
    LoadingSubtitle = "by Qz",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "QzSniperConfig",
        FileName = "Config"
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("الرئيسية", 4483362458)

MainTab:CreateSection("إعدادات القنص")

local ToggleStatus = false
local TargetMaxPrice = 15 -- السعر الافتراضي

-- زر التفعيل والتعطيل
MainTab:CreateToggle({
    Name = "تفعيل القنص التلقائي",
    CurrentValue = false,
    Flag = "SniperActive",
    Callback = function(Value)
        ToggleStatus = Value
        if Value then
            Rayfield:Notify({
                Title = "تم التفعيل",
                Content = "نظام القنص يعمل الآن في الخلفية!",
                Duration = 4,
            })
        else
            Rayfield:Notify({
                Title = "تم الإيقاف",
                Content = "توقف نظام القنص مؤقتاً.",
                Duration = 4,
            })
        end
    end,
})

-- شريط تحديد السعر الأقصى
MainTab:CreateSlider({
    Name = "الحد الأقصى للسعر (جواهر)",
    Range = {1, 50},
    Increment = 1,
    Suffix = "💎",
    CurrentValue = 15,
    Flag = "MaxPriceFlag",
    Callback = function(Value)
        TargetMaxPrice = Value
    end,
})

MainTab:CreateSection("معلومات العناصر")
MainTab:CreateParagraph({
    Title = "العناصر المستهدفة:", 
    Content = "• Basic Stove\n• Titanium Fridge\n• Carbon Industrial Fridge\n• جميع الطاولات والكراسي"
})

-- نظام المراقبة والشراء التلقائي في الخلفية
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local network = ReplicatedStorage:WaitForChild("Network", 5)
local marketRemote = network and network:WaitForChild("RemoteFunction", 5)

task.spawn(function()
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
            
            if success and typeof(marketItems) == "table" then
                for _, item in pairs(marketItems) do
                    if item and (item.Name or item.Title) then
                        local itemName = item.Name or item.Title
                        local itemPrice = tonumber(item.Price or item.Cost or 0)
                        local itemCurr = tostring(item.Currency or "Diamonds")
                        local itemId = tostring(item.Id or item.ID or "")
                        
                        -- الشروط: السعر أقل من أو يساوي المحدّد في الواجهة والعملة جواهر
                        if itemId ~= "" and itemCurr == "Diamonds" and itemPrice <= TargetMaxPrice then
                            local purchaseArgs = {
                                itemId,
                                itemPrice,
                                "Diamonds"
                            }
                            
                            local buySuccess = pcall(function()
                                return marketRemote:InvokeServer(unpack(purchaseArgs))
                            end)
                            
                            if buySuccess then
                                Rayfield:Notify({
                                    Title = "🔥 تم صيد العنصر بنجاح!",
                                    Content = tostring(itemName) .. " | السعر: " .. tostring(itemPrice) .. " 💎",
                                    Duration = 6,
                                })
                                task.wait(1)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
