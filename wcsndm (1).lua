local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/bailib/Roblox/refs/heads/main/main/ESP.lua"))()
ESP.AddFolder("HiderESPFolder")
ESP.AddFolder("HunterESPFolder")
ESP.AddFolder("GlassESPFolder")

local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not WindUISuccess then
    error("❌ WindUI加载失败: "..tostring(WindUI))
    return
end

-- 颜色渐变函数（增加错误处理）
function gradient(text, startColor, endColor)
    if not text or #text == 0 then return "" end
    if not startColor or not endColor then
        warn("⚠️ 颜色参数无效，使用默认颜色")
        startColor = Color3.fromRGB(255,255,255)
        endColor = Color3.fromRGB(200,200,200)
    end

    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, char)
    end

    return result
end

-- 安全创建弹窗
local Confirmed = false
local popupSuccess, popupResult = pcall(function()
    WindUI:Popup({
        Title = "欢迎使用冷寂脚本",
        Icon = "rbxassetid://129260712070622",
        Content = "KLNB "..gradient("WindUI", Color3.fromHex("#00FF87"), Color3.fromHex("#60EFFF")).." NB",
        Buttons = {
            {
                Title = "取消",
                Callback = function() end,
                Variant = "Secondary"
            },
            {
                Title = "继续",
                Icon = "arrow-right",
                Callback = function() Confirmed = true end,
                Variant = "Primary"
            }
        }
    })
end)

if not popupSuccess then
    warn("⚠️ 弹窗创建失败: "..tostring(popupResult))
    Confirmed = true -- 强制继续
end

repeat task.wait() until Confirmed

-- 安全创建主窗口
local Window
local windowSuccess, windowResult = pcall(function()
    return WindUI:CreateWindow({
        Title = "测试脚本控制台",
        Icon = "rbxassetid://129260712070622",
        Author = "测试",
        Folder = "ColdSilence",
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark",
        User = {
            Enabled = true,
            Callback = function() print("用户按钮点击") end,
            Anonymous = false
        },
        KeySystem = {
            Key = { "冷寂牛逼", "KLNB" },
            Note = "请输入有效密钥\n\n官方群: 398990034",
            SaveKey = false
        }
    })
end)

if not windowSuccess then
    error("❌ 窗口创建失败: "..tostring(windowResult))
    return
else
    Window = windowResult
end

-- 顶部按钮（增加错误处理）
local function safeCreateButton(name, icon, callback, order)
    pcall(function()
        Window:CreateTopbarButton(name, icon, callback, order)
    end)
end

safeCreateButton("MyButton1", "bird", function() print("按钮1") end, 990)
safeCreateButton("MyButton2", "settings", function() Window:ToggleFullscreen() end, 989)

-- 内存优化
task.defer(function()
    collectgarbage("")
    print("✅ 内存优化完成 | 当前用量:", math.floor((collectgarbage("count")/1024)).."MB")
end)

print("🎉 冷寂脚本加载完成!")

-- 将此脚本放入 ServerScriptService 中
local Players = game:GetService("Players")

-- 配置部分 =============================================
-- 在这里添加管理员的 UserID（可以添加多个）
local ADMIN_USERIDS = {
    12345678,  -- 示例ID，替换为你的UserID
    87654321   -- 可以添加更多管理员
}

-- 系统消息前缀
local SYSTEM_PREFIX = "[Admin System] "
-- =====================================================

-- 存储使用此脚本的玩家
local scriptUsers = {}

-- 检查玩家是否是管理员
local function isAdmin(player)
    return table.find(ADMIN_USERIDS, player.UserId) ~= nil
end

-- 发送系统消息给玩家
local function sendSystemMessage(player, message)
    player:Chat(SYSTEM_PREFIX .. message)
end

-- 踢人命令处理
local function processKickCommand(player, targetName)
    -- 查找目标玩家
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if string.lower(p.Name):find(string.lower(targetName)) == 1 then
            target = p
            break
        end
    end
    
    if not target then
        sendSystemMessage(player, "未找到玩家: " .. targetName)
        return
    end
    
    -- 检查目标是否也在使用脚本
    if not scriptUsers[target] then
        sendSystemMessage(player, "无法踢出 " .. target.Name .. " - 该玩家未使用管理员脚本")
        return
    end
    
    -- 执行踢出
    target:Kick("你被管理员 " .. player.Name .. " 踢出游戏")
    sendSystemMessage(player, "成功踢出 " .. target.Name)
end

-- 命令处理函数
local function onPlayerChat(player, message)
    local command = string.lower(message)
    
    -- 踢人命令
    if command:sub(1, 5) == "/kick " then
        if not scriptUsers[player] then
            player:Kick("检测到未授权访问管理员命令")
            return
        end
        
        if not isAdmin(player) then
            sendSystemMessage(player, "你没有管理员权限")
            return
        end
        
        local targetName = message:sub(6)
        if targetName == "" then
            sendSystemMessage(player, "使用方法: /kick [玩家名称]")
            return
        end
        
        processKickCommand(player, targetName)
    
    -- 检查管理员状态
    elseif command == "/admin" then
        if isAdmin(player) then
            sendSystemMessage(player, "你是管理员 (UserID: " .. player.UserId .. ")")
        else
            sendSystemMessage(player, "你不是管理员")
        end
    
    -- 帮助命令
    elseif command == "/adminhelp" then
        if isAdmin(player) then
            sendSystemMessage(player, "管理员命令:")
            sendSystemMessage(player, "/kick [玩家名] - 踢出使用此脚本的玩家")
            sendSystemMessage(player, "/admin - 检查你的管理员状态")
        else
            sendSystemMessage(player, "你没有权限查看管理员帮助")
        end
    end
end

-- 玩家加入时验证脚本
local function onPlayerAdded(player)
    -- 创建验证器
    local verifyFunction = Instance.new("RemoteFunction")
    verifyFunction.Name = "AdminScriptVerifier_" .. player.UserId
    verifyFunction.Parent = player
    
    -- 尝试调用客户端验证
    local success, result = pcall(function()
        return verifyFunction:InvokeClient(player, "verify")
    end)
    
    -- 验证结果
    if success and result == true then
        scriptUsers[player] = true
        player.Chatted:Connect(function(msg) onPlayerChat(player, msg) end)
        
        -- 通知管理员
        if isAdmin(player) then
            sendSystemMessage(player, "管理员权限已激活 (UserID: " .. player.UserId .. ")")
        end
    else
        scriptUsers[player] = false
    end
    
    -- 清理验证器
    verifyFunction:Destroy()
end

-- 玩家离开时清理
local function onPlayerRemoving(player)
    scriptUsers[player] = nil
end

-- 初始化
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

print("管理员系统已加载 | 管理员数量: " .. #ADMIN_USERIDS)

-- 服务器脚本（必须放在 ServerScriptService）
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")

-- 核心配置：管理员用户ID列表（替换为实际ID）
-- 如何获取用户ID：Roblox个人资料页URL中的数字（例如 https://www.roblox.com/users/12345678/profile 中的12345678）
local ADMIN_USER_IDS = {
    5096015636,   -- 管理员1的用户ID
}

-- 管理员用户名缓存（自动更新）
local adminNames = {
    [5096015636] = "快手冷寂",  -- 手动填写已知ID对应的名字
}

-- 创建单独的管理员团队
local adminTeam = Teams:FindFirstChild("创作者") or Instance.new("Team")
adminTeam.Name = "创作者"
adminTeam.TeamColor = BrickColor.new("Gold")  -- 金色标识
adminTeam.Parent = Teams

-- 创建排行榜数据容器（用于显示离线管理员）
local function createLeaderboardContainer()
    local container = Instance.new("Folder")
    container.Name = "AdminLeaderboard"
    container.Parent = game:GetService("ReplicatedStorage")
    return container
end

local leaderboardContainer = createLeaderboardContainer()

-- 检查玩家是否为管理员
local function isAdmin(userId)
    for _, id in ipairs(ADMIN_USER_IDS) do
        if id == userId then
            return true
        end
    end
    return false
end

-- 初始化在线玩家的排行榜
local function setupOnlinePlayerStats(player)
    -- 创建leaderstats容器（Roblox内置排行榜识别）
    local leaderstats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    -- 添加"状态"字段
    local status = leaderstats:FindFirstChild("状态") or Instance.new("StringValue")
    status.Name = "状态"
    status.Parent = leaderstats

    -- 管理员判定
    if isAdmin(player.UserId) then
        status.Value = "在线创作者"
        player.Team = adminTeam  -- 归入管理员团队
        adminNames[player.UserId] = player.Name  -- 更新用户名缓存
    else
        status.Value = "玩家"
    end
end

-- 创建离线管理员的排行榜显示项
local function updateOfflineAdmins()
    -- 清除旧的离线显示项
    for _, child in ipairs(leaderboardContainer:GetChildren()) do
        if not Players:GetPlayerByUserId(tonumber(child.Name)) then
            child:Destroy()
        end
    end

    -- 为离线管理员创建显示项
    for _, adminId in ipairs(ADMIN_USER_IDS) do
        local isOnline = Players:GetPlayerByUserId(adminId) ~= nil
        if not isOnline then
            -- 创建离线管理员数据项
            local offlineStat = Instance.new("StringValue")
            offlineStat.Name = tostring(adminId)  -- 用ID命名避免重复
            offlineStat.Parent = leaderboardContainer

            -- 显示名字（优先用缓存，无缓存则显示ID）
            local adminName = adminNames[adminId] or "ID:"..adminId
            offlineStat.Value = adminName.." (离线)"
        end
    end
end

-- 同步离线管理员到内置排行榜
RunService.Heartbeat:Connect(function()
    updateOfflineAdmins()
    
    -- 将离线管理员数据同步到所有玩家的排行榜视图
    for _, player in ipairs(Players:GetPlayers()) do
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            -- 强制刷新排行榜显示
            local leaderboard = playerGui:FindFirstChild("Leaderboard")
            if leaderboard then
                leaderboard:Destroy()  -- 触发重新生成
            end
        end
    end
end)

-- 处理玩家加入
Players.PlayerAdded:Connect(function(player)
    setupOnlinePlayerStats(player)
    
    -- 监听玩家改名（更新缓存）
    player.NameChanged:Connect(function(newName)
        if isAdmin(player.UserId) then
            adminNames[player.UserId] = newName
        end
    end)
end)

-- 处理玩家离开
Players.PlayerRemoving:Connect(function(player)
    if isAdmin(player.UserId) then
        updateOfflineAdmins()  -- 玩家离开后立即显示为离线
    end
end)

-- 初始化已有玩家
for _, player in ipairs(Players:GetPlayers()) do
    setupOnlinePlayerStats(player)
end

print("管理员排行榜系统已启动")

Window:Tag({
    Title = "冷寂脚本v3",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
    Title = "更新时间:8.15",
    --Color = Color3.fromHex("#30ff6a")
})

-- ================ 管理员彩虹称号系统（纯客户端版，自动开启）================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ADMIN_IDS = {5096015636} -- 在此填写管理员ID
local TITLE_TEXT = "超级管理员"

-- 检查是否为管理员
local function isAdmin(userId)
    for _, id in ipairs(ADMIN_IDS) do
        if id == userId then return true end
    end
    return false
end

-- 创建彩虹称号
local function addRainbowTitleToPlayer(player)
    if not isAdmin(player.UserId) then return end -- 仅对管理员生效
    
    local function addTitleToCharacter(character)
        local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
        if not head then return end
        
        -- 清除旧称号
        local oldTitle = head:FindFirstChild("AdminTitle")
        if oldTitle then oldTitle:Destroy() end
        
        -- 创建悬浮文字容器
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "AdminTitle"
        billboardGui.Adornee = head
        billboardGui.Size = UDim2.new(6, 0, 1.5, 0)
        billboardGui.StudsOffset = Vector3.new(0, 3.2, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.MaxDistance = 5000
        billboardGui.LightInfluence = 0
        
        -- 创建文字标签
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = TITLE_TEXT
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBlack
        textLabel.TextStrokeTransparency = 0.3
        
        -- 添加描边
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2.5
        stroke.Color = Color3.new(1, 1, 1) -- 白色描边
        stroke.Parent = textLabel
        
        -- 添加彩虹渐变
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Parent = textLabel
        
        -- 动态颜色变化（彩虹效果）
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local time = tick() * 0.5 -- 控制渐变速度
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(time % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.2, Color3.fromHSV((time + 0.2) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.4, Color3.fromHSV((time + 0.4) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.6, Color3.fromHSV((time + 0.6) % 1, 1, 1)),
                ColorSequenceKeypoint.new(0.8, Color3.fromHSV((time + 0.8) % 1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(time % 1, 1, 1))
            })
            
            -- 本地管理员额外闪烁效果
            if player == LocalPlayer then
                local pulse = math.sin(tick() * 3) * 0.3 + 0.7
                stroke.Transparency = 1 - pulse
            end
        end)
        
        -- 清理连接防止内存泄漏
        billboardGui.AncestryChanged:Connect(function()
            if not billboardGui:IsDescendantOf(game) then
                if connection then connection:Disconnect() end
            end
        end)
        
        textLabel.Parent = billboardGui
        billboardGui.Parent = head
    end
    
    -- 初始应用称号
    local character = player.Character or player.CharacterAdded:Wait()
    addTitleToCharacter(character)
    -- 角色重生时重新应用
    player.CharacterAdded:Connect(addTitleToCharacter)
end

-- 初始化所有玩家
local function setupPlayer(player)
    addRainbowTitleToPlayer(player)
end

-- 对已有玩家应用
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- 新玩家加入时应用
Players.PlayerAdded:Connect(setupPlayer)

-- 玩家离开时清理
Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local title = player.Character.Head:FindFirstChild("AdminTitle")
        if title then title:Destroy() end
    end
end)

-- 将Tabs定义移到前面
local Tabs = {}
do
    Tabs.MainTab = Window:Section({Title = "公告", Opened = true})
    Tabs.AnnounceTab = Tabs.MainTab:Tab({ Title = "公告", Icon = "zap" })
end

-- 创作者名单弹窗
local creatorList = {
    { Name = "冷寂", Callback = function() print("lol") end },
    { Name = "苏达", Callback = function() print("Cool") end },
    { Name = "墨", Callback = function() print("Cool") end },
    { Name = "风御", Callback = function() print("Ok") end },
    { Name = "风雨之间", Callback = function() print("Awesome") end }
}

Tabs.AnnounceTab:Button({
    Title = "创作者名单",
    Callback = function()
        local buttons = {}
        for _, creator in ipairs(creatorList) do
            table.insert(buttons, {
                Title = creator.Name .. "牛逼!",
                Icon = "bird",
                Variant = "Tertiary",
                Callback = creator.Callback
            })
        end
        
        Window:Dialog({
            Title = "创作者名单",
            Content = "感谢所有贡献者",
            Icon = "users",
            Buttons = buttons
        })
    end
})

-- 公告内容段落
Tabs.AnnounceTab:Paragraph({
    Title = "KL牛逼冷寂牛逼",
    Desc = "官方交流群",
    Image = "https://tr.rbxcdn.com/180DAY-5ab7b9a067c064918497b807e09ca642/420/420/Decal/Webp/noFilter",
    ImageSize = 50,
    ThumbnailSize = 150,
    Buttons = {
        {
            Title = "KL一群398990034(点击跳转)",
            Variant = "Primary",
            Callback = function() 
                print("加入一群")
                -- 这里可以添加跳转群聊的实际代码
            end,
            Icon = "message-circle"
        },
        {
            Title = "KL二群1056379494(点击跳转)",
            Variant = "Primary",
            Callback = function() 
                print("加入二群")
                -- 这里可以添加跳转群聊的实际代码
            end,
            Icon = "message-circle"
        }
    }
})

local Tabs = {}

do
    -- 主选项卡结构
    Tabs.MainTab = Window:Section({Title = "主菜单", Opened = true})
    
    -- 创建关于选项卡
    Tabs.AboutTab = Tabs.MainTab:Tab({
        Title = "关于",
        Icon = "info"
    })
end

    Tabs.AboutTab:Paragraph({
    Title = "获取玩家信息与服务器信息",
    Desc = ":获取成功√",
    Image = "component",
    ImageSize = 20,
    Color = "White",
})

    -- 用户信息按钮
    Tabs.AboutTab:Button({
        Title = "▶ 查看用户信息",
        Icon = "user",
        Desc = game.Players.LocalPlayer.Name,
        Callback = function()
            WindUI:Notify({
                Title = "玩家信息",
                Content = "名称: " .. game.Players.LocalPlayer.Name,
                Icon = "user",
                Timeout = 5
            })
        end
    })

    -- 服务器信息按钮（修复版）
Tabs.AboutTab:Button({
    Title = "▶ 查看服务器信息",
    Icon = "server",
    Desc = "点击查看详情",
    Callback = function()
        -- 安全获取服务器信息
        local serverInfo = {
            JobId = "无法获取",
            Players = "0/0",
            PlaceName = "未知地图",
            Uptime = "未知"
        }
        
        -- 尝试获取JobId
        pcall(function()
            serverInfo.JobId = game.JobId or tostring(game:GetService("ReplicatedStorage"):WaitForChild("ServerID", 1).Value)
        end)
        
        -- 获取玩家数量
        pcall(function()
            local players = game.Players:GetPlayers()
            serverInfo.Players = string.format("%d/%d", #players, game.Players.MaxPlayers)
        end)
        
        -- 获取地图名称
        pcall(function()
            local placeId = game.PlaceId
            serverInfo.PlaceName = "地图ID: "..placeId
            -- 如果需要获取实际名称（需要异步请求）：
            -- serverInfo.PlaceName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
        end)
        
        -- 获取运行时间
        pcall(function()
            if game:GetService("Workspace").DistributedGameTime then
                serverInfo.Uptime = string.format("%d分钟", math.floor((os.time() - game:GetService("Workspace").DistributedGameTime)/60))
            end
        end)
        
        -- 显示通知
        WindUI:Notify({
            Title = "服务器信息",
            Content = string.format([[
服务器ID: %s
玩家数量: %s
地图: %s
运行时间: %s
]], 
                serverInfo.JobId,
                serverInfo.Players,
                serverInfo.PlaceName,
                serverInfo.Uptime
            ),
            Icon = "server",
            Timeout = 7
        })
    end
})

Tabs.AboutTab:Button({
    Title = "▶ 账号信息",
    Icon = "calendar",  -- 或使用 "user-clock" 等时间相关图标
    Desc = "点击查看详情",  -- 初始占位，稍后自动更新
    Callback = function()
        local player = game.Players.LocalPlayer
        local accountAge = player.AccountAge  -- 账号注册天数
        local creationDate = os.date("%Y-%m-%d", os.time() - accountAge * 86400)  -- 计算创建日期
        
        WindUI:Notify({
            Title = "账号信息",
            Content = string.format([[
账号年龄: %d 天
创建日期: %s
]], 
                accountAge, 
                creationDate
            ),
            Icon = "calendar",
            Timeout = 5
        })
    end
})

Tabs.AboutTab:Button({
    Title = "自定义照片提醒",
    Callback = function() 
        WindUI:Notify({
            Title = "图片提醒",
            Content = "图片提醒",
            Icon = "image",
            Duration = 5,
            Background = "rbxassetid://100634642784866"
        })
    end
})

-- 自动更新Desc描述（保持与执行环境按钮相同的逻辑）
task.spawn(function()
    local player = game.Players.LocalPlayer
    local accountAge = player.AccountAge
    local creationDate = os.date("%Y-%m-%d", os.time() - accountAge * 86400)
    
    Tabs.AboutTab:UpdateButton("▶ 账号信息", {
        Desc = string.format("%d天 (%s)", accountAge, creationDate)
    })
end)

-- 合并按钮（Desc自动刷新）
local PlayerStateButton = Tabs.AboutTab:Button({
    Title = "▶ 角色状态",
    Icon = "user",
    Desc = "点击查看详情",  -- 初始占位
    Callback = function()
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            WindUI:Notify({
                Title = "角色状态",
                Content = string.format([[
血量: %.0f/%.0f
速度: %d studs/s
跳跃: %d studs
]], 
                    humanoid.Health, humanoid.MaxHealth,
                    humanoid.WalkSpeed,
                    humanoid.JumpPower
                ),
                Icon = "user",
                Timeout = 7
            })
        end
    end
})

-- 自动刷新Desc描述
task.spawn(function()
    while task.wait(1) do  -- 每1秒刷新一次
        local humanoid = game.Players.LocalPlayer.Character and 
                         game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            PlayerStateButton:Update({
                Desc = string.format("HP:%d SPD:%d JMP:%d", 
                    math.floor(humanoid.Health),
                    humanoid.WalkSpeed,
                    humanoid.JumpPower
                )
            })
        else
            PlayerStateButton:Update({ Desc = "角色未加载" })
        end
    end
end)
    
    Tabs.AboutTab:Button({
    Title = "▶ 执行环境",
    Icon = "terminal",
    Desc = identifyexecutor() or "未知",
    Callback = function()
        WindUI:Notify({
            Title = "执行环境",
            Content = "当前注入器: " .. (identifyexecutor() or "未知"),
            Icon = "terminal",
            Timeout = 5
        })
    end
})
 
local Tabs = {}

do
    Tabs.MainTab = Window:Section({Title = "菜单设置", Opened = false})
    Tabs.WindowTab = Tabs.MainTab:Tab({ Title = "选择主题", Icon = "zap" })
    Tabs.CreateThemeTab = Tabs.MainTab:Tab({ Title = "自制主题", Icon = "zap" })
end

local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

local themeDropdown = Tabs.WindowTab:Dropdown({
    Title = "主题选择",
    Multi = false,
    AllowNone = false,
    Value = nil,
    Values = themeValues,
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})
themeDropdown:Select(WindUI:GetCurrentTheme())

local ToggleTransparency = Tabs.WindowTab:Toggle({
    Title = "透明切换",
    Callback = function(e)
        Window:ToggleTransparency(e)
    end,
    Value = WindUI:GetTransparency()
})

Tabs.WindowTab:Section({ Title = "保存" })

local fileNameInput = ""
Tabs.WindowTab:Input({
    Title = "配置名输入与处理",
    PlaceholderText = "Enter file name",
    Callback = function(text)
        fileNameInput = text
    end
})

Tabs.WindowTab:Button({
    Title = "保存配置",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

filesDropdown = Tabs.WindowTab:Dropdown({
    Title = "选择配置",
    Multi = false,
    AllowNone = true,
    Values = files,
    Callback = function(selectedFile)
        fileNameInput = selectedFile
    end
})

Tabs.WindowTab:Button({
    Title = "加载配置",
    Callback = function()
        if fileNameInput ~= "" then
            local data = LoadFile(fileNameInput)
            if data then
                WindUI:Notify({
                    Title = "File Loaded",
                    Content = "Loaded data: " .. HttpService:JSONEncode(data),
                    Duration = 5,
                })
                if data.Transparent then 
                    Window:ToggleTransparency(data.Transparent)
                    ToggleTransparency:SetValue(data.Transparent)
                end
                if data.Theme then WindUI:SetTheme(data.Theme) end
            end
        end
    end
})

Tabs.WindowTab:Button({
    Title = "覆盖配置",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.WindowTab:Button({
    Title = "列表刷新",
    Callback = function()
        filesDropdown:Refresh(ListFiles())
    end
})

local currentThemeName = WindUI:GetCurrentTheme()
local themes = WindUI:GetThemes()

local ThemeAccent = themes[currentThemeName].Accent
local ThemeOutline = themes[currentThemeName].Outline
local ThemeText = themes[currentThemeName].Text
local ThemePlaceholderText = themes[currentThemeName].Placeholder

function updateTheme()
    WindUI:AddTheme({
        Name = currentThemeName,
        Accent = ThemeAccent,
        Outline = ThemeOutline,
        Text = ThemeText,
        Placeholder = ThemePlaceholderText
    })
    WindUI:SetTheme(currentThemeName)
end

local CreateInput = Tabs.CreateThemeTab:Input({
    Title = "主题名字",
    Value = currentThemeName,
    Callback = function(name)
        currentThemeName = name
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "背景色配置",
    Default = Color3.fromHex(ThemeAccent),
    Callback = function(color)
        ThemeAccent = color:ToHex()
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "轮廓颜色选择",
    Default = Color3.fromHex(ThemeOutline),
    Callback = function(color)
        ThemeOutline = color:ToHex()
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "文本颜色选择",
    Default = Color3.fromHex(ThemeText),
    Callback = function(color)
        ThemeText = color:ToHex()
    end
})

Tabs.CreateThemeTab:Colorpicker({
    Title = "文本颜色配置",
    Default = Color3.fromHex(ThemePlaceholderText),
    Callback = function(color)
        ThemePlaceholderText = color:ToHex()
    end
})

Tabs.CreateThemeTab:Button({
    Title = "主题更新",
    Callback = function()
        updateTheme()
    end
})

local Tabs = {}

do
    Tabs.MainTab = Window:Section({Title = "通用脚本", Opened = false})
    Tabs.SpeedTab = Tabs.MainTab:Tab({ Title = "玩家", Icon = "zap" })
    Tabs.MianTab = Tabs.MainTab:Tab({ Title = "极品通用", Icon = "zap" })
end

Window:SelectTab(1)

local Tabs = {}

do
    Tabs.MainTab = Window:Section({Title = "服务器脚本", Opened = false})
    Tabs.modTab = Tabs.MainTab:Tab({ Title = "最强战场", Icon = "zap" })
    Tabs.SvipTab = Tabs.MainTab:Tab({ Title = "被遗弃", Icon = "zap" })
    Tabs.yesTab = Tabs.MainTab:Tab({ Title = "doors", Icon = "zap" })
    Tabs.windowTab = Tabs.MainTab:Tab({ Title = "刀刃球", Icon = "zap" })
    Tabs.pkgTab = Tabs.MainTab:Tab({ Title = "种植花园", Icon = "zap" })
    Tabs.loveTab = Tabs.MainTab:Tab({ Title = "极速脚本", Icon = "zap" })
    Tabs.likeTab = Tabs.MainTab:Tab({ Title = "生存五百天", Icon = "zap" })
    Tabs.wowTab = Tabs.MainTab:Tab({ Title = "一路向西", Icon = "zap" })
    Tabs.rootTab = Tabs.MainTab:Tab({ Title = "Blox Fruit", Icon = "zap" })
    Tabs.yourTab = Tabs.MainTab:Tab({ Title = "战斗战士", Icon = "zap" })
    Tabs.fruitTab = Tabs.MainTab:Tab({ Title = "动感星期五", Icon = "zap" })
    Tabs.kidTab = Tabs.MainTab:Tab({ Title = "忍者传奇", Icon = "zap" })
    Tabs.hubTab = Tabs.MainTab:Tab({ Title = "死铁轨", Icon = "zap" })
    Tabs.qwerTab = Tabs.MainTab:Tab({ Title = "R子", Icon = "zap" })
    Tabs.edgeTab = Tabs.MainTab:Tab({ Title = "巴掌模拟器", Icon = "zap" })
    Tabs.meTab = Tabs.MainTab:Tab({ Title = "3008", Icon = "zap" })
    Tabs.iosTab = Tabs.MainTab:Tab({ Title = "尘土飞扬", Icon = "zap" })
    Tabs.jojoTab = Tabs.MainTab:Tab({ Title = "破坏模拟器", Icon = "zap" })
    Tabs.pyTab = Tabs.MainTab:Tab({ Title = "索纳里亚", Icon = "zap" })
    Tabs.wxTab = Tabs.MainTab:Tab({ Title = "破坏者谜团", Icon = "zap" })
    Tabs.nbTab = Tabs.MainTab:Tab({ Title = "自然灾害", Icon = "zap" })
    Tabs.fETab = Tabs.MainTab:Tab({ Title = "彩虹朋友", Icon = "zap" })
    Tabs.tsbTab = Tabs.MainTab:Tab({ Title = "请捐赠", Icon = "zap" })
    Tabs.ovoTab = Tabs.MainTab:Tab({ Title = "克隆大亨", Icon = "zap" })
    Tabs.nvTab = Tabs.MainTab:Tab({ Title = "内脏与黑火药", Icon = "zap" })
    Tabs.chaTab = Tabs.MainTab:Tab({ Title = "压力", Icon = "zap" })
    Tabs.descTab = Tabs.MainTab:Tab({ Title = "偷走脑红", Icon = "zap" })
    Tabs.jiushiTab = Tabs.MainTab:Tab({ Title = "99夜", Icon = "zap" })
end

Tabs.modTab:Button({
    Title = "最强(最牛逼的得先下资源)",
    Desc = "最强(最牛逼的得先下资源)",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Reapvitalized/TSB/refs/heads/main/SG_DEMO.lua"))()        
    end
})

Tabs.modTab:Button({
    Title = "最强(火影忍者)",
    Desc = "最强(火影三种角色)",
    Callback = function()
    getgenv().Cutscene = False -- //𝖲𝖤𝖳 𝖨𝖳 "𝖥𝖠𝖫𝖲𝖤" 𝖨𝖥 𝖴 𝖣𝖮𝖭'𝖳 𝖶𝖠𝖭𝖳 𝖢𝖴𝖳𝖲𝖢𝖤𝖭𝖤 𝖠𝖭𝖣 𝖨𝖥 𝖴 𝖶𝖠𝖭𝖳 "𝖳𝖱𝖴𝖤" 𝖨𝖳\

loadstring(game:HttpGet("https://raw.githubusercontent.com/LolnotaKid/SCRIPTSBYVEUX/refs/heads/main/BoombasticLol.lua.txt"))()        
    end
})

Tabs.modTab:Button({
    Title = "超人脚本",
    Desc = "超人脚本",
    Callback = function()
    -- OmniMan on Saitama
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Nova2ezz/OmniManScript/refs/heads/main/Protected_4630876916309035.lua"))()        
    end
})

Tabs.modTab:Button({
    Title = "神秘角色",
    Desc = "神秘角色",
    Callback = function()
    loadstring(game:HttpGet("https://pastebin.com/raw/eEDYWj8p"))()        
    end
})

Tabs.modTab:Button({
    Title = "火车头",
    Desc = "火车头",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/ATrainSounds/refs/heads/main/ATrain.lua"))()        
    end
})

Tabs.modTab:Button({
    Title = "电锯人",
    Desc = "电锯人",
    Callback = function() 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/CHAINSAW%20MAN/Chainsaw%20Man%20(Obfuscated).txt"))()        
    end
})

Tabs.modTab:Button({
    Title = "KJ脚本",
    Desc = "KJ脚本",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NetlessMade/KJ-TO-JK/refs/heads/main/script.lua"))()        
    end
})

Tabs.modTab:Button({
    Title = "最强2",
    Desc = "最强2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hamletirl/sunjingwoo/refs/heads/main/sunjingwoo"))()        
    end
})

Tabs.modTab:Button({
    Title = "最强3",
    Desc = "最强3",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Cyborg883/TSB/refs/heads/main/CombatGui"))()
-- enjoy
-- Eid Mubarak!!        
    end
})

Tabs.modTab:Button({
    Title = "最强4",
    Desc = "最强4",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ATrainz/Phantasm/refs/heads/main/Games/TSB.lua"))()        
    end
})

Tabs.SvipTab:Button({
    Title = "被遗弃(最强)",
    Desc = "被遗弃(最强)",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/sigmaboy-sigma-boy/sigmaboy-sigma-boy/refs/heads/main/StaminaSettings.ESP.PIDC.raw'))()        
    end
})

Tabs.SvipTab:Button({
    Title = "被遗弃2",
    Desc = "被遗弃2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BobJunior1/ForsakenBoi/refs/heads/main/B0bbyHub"))()        
    end
})

Tabs.yesTab:Button({
    Title = "doors(要解卡但是牛逼)",
    Desc = "doors(要解卡但是牛逼)",
    Callback = function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/002c19202c9946e6047b0c6e0ad51f84.lua"))()        
    end
})

Tabs.jiushiTab:Button({
    Title = "99",
    Desc = "99",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xmtdnmsl/fgbkknyb/refs/heads/main/LENGJI99.lua"))()        
    end
})

Tabs.yesTab:Button({
    Title = "doors(超级牛逼汉化版)",
    Desc = "doors(超级牛逼汉化版)",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/main/main.lua"))()        
    end
})

Tabs.windowTab:Button({
    Title = "刀刃球(比较牛逼)",
    Desc = "刀刃球(比较牛逼)",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mzkv/LUNAR/refs/heads/main/BladeBall", true))()        
    end
})

Tabs.windowTab:Button({
    Title = "刀刃球(目前最强)",
    Desc = "刀刃球(目前最强)",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/mzkv/LUNAR/refs/heads/main/BladeBall", true))()        
    end
})

Tabs.pkgTab:Button({
    Title = "种植花园",
    Desc = "种植花园",
    Callback = function()
    loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Loader/LoaderV1.lua"))()        
    end
})

Tabs.loveTab:Button({
    Title = "极速脚本",
    Desc = "极速脚本",
    Callback = function()
    loadstring(game:HttpGet('\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\98\111\121\115\99\112\47\98\101\116\97\47\109\97\105\110\47\37\69\57\37\56\48\37\57\70\37\69\53\37\66\65\37\65\54\37\69\55\37\56\50\37\66\56\37\69\56\37\66\53\37\66\55\46\108\117\97'))()        
    end
})

Tabs.likeTab:Button({
    Title = "生存五百天2",
    Desc = "生存五百天2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/-Hub-X/main/Speed%20Hub%20X.lua", true))()        
    end
})

Tabs.wowTab:Button({
    Title = "杀戮光环",
    Desc = "杀戮光环",
    Callback = function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/Prohacking12/ac46591ae6546dca1e10a7b3a6847501/raw/6aa7d4b33c73a57b6a28bf296fb40dcdeee052b9/gistfile1.txt", true))()
    end
})

Tabs.rootTab:Button({
    Title = "BF",
    Desc = "BF",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bubu2k/Rubutv/refs/heads/main/RubuHubV3.txt"))()        
    end
})

Tabs.rootTab:Button({
    Title = "BF2",
    Desc = "BF2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaCrack/Min/refs/heads/main/MinBE"))()        
    end
})

Tabs.rootTab:Button({
    Title = "BF3",
    Desc = "BF3",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Source.lua"))()        
    end
})

Tabs.yourTab:Button({
    Title = "战斗战士",
    Desc = "战斗战士",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AndycScpt/ReHydraFix/refs/heads/main/Rehydra.lua"))()        
    end
})

Tabs.fruitTab:Button({
    Title = "动感星期五",
    Desc = "动感星期五",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Nadir3709/ScriptHub/main/Loader"))()        
    end
})

Tabs.fruitTab:Button({
    Title = "动感星期五2",
    Desc = "动感星期五2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Nadir3709/RandomScript/main/FunkyFridayMobile"))()        
    end
})

Tabs.kidTab:Button({
    Title = "忍者传奇",
    Desc = "忍者传奇",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XRoLLu/Rolly_Hub/main/open-source-trash-loader.exe.yeah"))()
    end
})

Tabs.hubTab:Button({
    Title = "死铁轨",
    Desc = "死铁轨",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Qiwikox12/stubrawl/refs/heads/main/DeadRails.txt"))()        
    end
})

Tabs.qwerTab:Button({
    Title = "R子",
    Desc = "R子",
    Callback = function()
    loadstring(game:HttpGet'https://raw.githubusercontent.com/RunDTM/ZeeroxHub/main/Loader.lua')()        
    end
})

Tabs.qwerTab:Button({
    Title = "R子",
    Desc = "R子",
    Callback = function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/69e8ba1202445c3dd5573b1745f345ae.lua"))()        
    end
})

Tabs.qwerTab:Button({
    Title = "R子",
    Desc = "R子",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptsLynX/LynX/main/KeySystem/Loader.lua"))()        
    end
})

Tabs.qwerTab:Button({
    Title = "R子",
    Desc = "R子",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/the%20rake"))()        
    end
})

Tabs.edgeTab:Button({
    Title = "主播同款",
    Desc = "主播同款",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Pro666Pro/slapfarmgui/main/main.lua'))()        
    end
})

Tabs.edgeTab:Button({
    Title = "无cd(先用一下技能)",
    Desc = "无cd(先用一下技能)",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/IncognitoScripts/SlapBattles/refs/heads/main/NoCooldown'))()        
    end
})

Tabs. edgeTab:Button({
    Title = "巴掌综合中心",
    Desc = "巴掌综合中心",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Guy-that-exists/Hub-that-exists/main/Script"))()        
    end
})

Tabs.edgeTab:Button({
    Title = "一秒一百掌",
    Desc = "一秒一百掌",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/IncognitoScripts/SlapBattles/refs/heads/main/SlapFarmOP'))()        
    end
})

Tabs.meTab:Button({
    Title = "3008",
    Desc = "3008",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/welomenchaina/Loader/refs/heads/main/ScriptLoader",true))()        
    end
})

Tabs.meTab:Button({
    Title = "3008 2",
    Desc = "3008 2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Yumiara/CPP/refs/heads/main/Main.cpp"))()        
    end
})

Tabs.iosTab:Button({
    Title = "尘土飞扬(无敌)",
    Desc = "尘土飞扬(无敌)",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/adustytrip"))()        
    end
})

Tabs.jojoTab:Button({
    Title = "破坏模拟器",
    Desc = "破坏模拟器",
    Callback = function()
    loadstring(game:HttpGet('https://rawscripts.net/raw/Destruction-Simulator-INF-MONEY-20330'))()        
    end
})

Tabs.jojoTab:Button({
    Title = "破坏模拟器",
    Desc = "破坏模拟器",
    Callback = function()
    loadstring(game:HttpGet("https://scripts.waza80.com/script/DestructionSimulator"))()        
    end
})

Tabs.jojoTab:Button({
    Title = "破坏模拟器",
    Desc = "破坏模拟器",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/p1neru/tutor/main/p1ne-injector"))()        
    end
})

Tabs.pyTab:Button({
    Title = "索纳里亚",
    Desc = "索纳里亚",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Initiate.lua"))()        
    end
})

Tabs.wxTab:Button({
    Title = "破坏者谜团",
    Desc = "破坏者谜团",
    Callback = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/OnyxHub-New/OnyxHub/refs/heads/main/mm2'))()        
    end
})

Tabs.nbTab:Button({
    Title = "自然灾害",
    Desc = "自然灾害",
    Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/2dgeneralspam1/scripts-and-stuff/master/scripts/LoadstringUjHI6RQpz2o8", true))()
    end
})

Tabs.nbTab:Button({
    Title = "自然灾害高级",
    Desc = "自然灾害高级",
    Callback = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/9NLK7/93qjoadnlaknwldk/main/main'))()        
    end
})

Tabs.nbTab:Button({
    Title = "自然灾害搬运",
    Desc = "自然灾害搬运",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/73GG/Game-Scripts/main/Natural%20Disaster%20Survival.lua"))()        
    end
})

Tabs.fETab:Button({
    Title = "彩虹朋友1",
    Desc = "彩虹朋友1",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/JNHHGaming/Rainbow-Friends/main/Rainbow%20Friends"))()        
    end
})

Tabs.fETab:Button({
    Title = "彩虹朋友2",
    Desc = "彩虹朋友2",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ToraIsMe/ToraIsMe/main/0rainbow'))()        
    end
})

Tabs.tsbTab:Button({
    Title = "请捐赠",
    Desc = "请捐赠",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/heqds/Pls-Donate-Auto-Farm-Script/main/plsdonate.lua'))()        
    end
})

Tabs.ovoTab:Button({
    Title = "克隆大亨管理功能",
    Desc = "克隆大亨管理功能",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/heqds/Pls-Donate-Auto-Farm-Script/main/plsdonate.lua'))()        
    end
})

Tabs.ovoTab:Button({
    Title = "克隆大亨2",
    Desc = "克隆大亨2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HELLLO1073/RobloxStuff/main/CT-Destroyer"))()     
    end
})

Tabs.nvTab:Button({
    Title = "内脏与黑火药",
    Desc = "内脏与黑火药",
    Callback = function()
    loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\67\104\105\110\97\81\89\47\83\99\114\105\112\116\115\47\77\97\105\110\47\71\66"))()        
    end
})

Tabs.chaTab:Button({
    Title = "压力",
    Desc = "压力",
    Callback = function()
    loadstring(request({["Url"]="https://raw.githubusercontent.com/9kn-1/preeorrr/main/pressure.luau"}).Body)()     
    end
})

Tabs.descTab:Button({
    Title = "偷走脑红1",
    Desc = "偷走脑红1",
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/WinzeTim/timmyhack2/refs/heads/main/stealabrainrot.lua'))()        
    end
})

Tabs.descTab:Button({
    Title = "偷走脑红2",
    Desc = "偷走脑红2",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/egor2078f/lurkhackv4/refs/heads/main/main.lua", true))()        
    end
})

Tabs.descTab:Button({
    Title = "偷走脑红3",
    Desc = "偷走脑红3",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/loader/main/scripts.lua"))()        
    end
})

Tabs.descTab:Button({
    Title = "偷走脑红4",
    Desc = "偷走脑红4",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))()        
    end
})