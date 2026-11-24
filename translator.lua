-- Vietnamese UI localization, based on V7.1.
-- Only changes displayed text; does not change game logic or selection values.
return function(dictionary)
    assert(type(dictionary) == "table", "Invalid dictionary")
    local ui = shared.WindUI
    print("[VI7.2] WindUI: " .. type(ui))
    assert(ui and typeof(ui.ScreenGui) == "Instance", "Open Voidware first")
    local function norm(s)
        return (s:gsub("%s+", " "):match("^%s*(.-)%s*$"))
    end
    local normalized = {}
    for k,v in pairs(dictionary) do
        if type(k)=="string" and type(v)=="string" then
            normalized[norm(k)] = v
        end
    end
    local function lookup(s)
        return dictionary[s] or normalized[norm(s)]
    end
    local function escapePattern(s)
        return (s:gsub("([^%w])", "%%%1"))
    end
    local labels = {"Member Count","Online Count","Cultist Attack","Real Day","Time till open","Tracking","Status","Level","Time","Cycle","Weather","Biome","Day","Corruption","Rifts","Exploration"}
    local phrases = {"Day Statistics","Hard Mode Status","Stronghold Statistics","Stronghold not found yet :c","(Translation) Testing Mode","Successfully revealed all places on the map ✅","Automatically teleports to targets when they are out of range (200 Studs).","This is because the 99 Nights devs patched higher range :c"}
    local function translate(s)
        if type(s) ~= "string" or s == "" then return s end
        local exact = lookup(s)
        if type(exact)=="string" then return exact end
        local short = norm(s):match("^(.-)%.%.%.$") or norm(s):match("^(.-)…$")
        if short then
            local items, changed = {}, false
            for item in short:gmatch("[^,]+") do
                item = norm(item)
                local v = lookup(item) or item
                changed = changed or v ~= item
                items[#items+1] = v
            end
            if changed then
                return table.concat(items, ", ") .. (short:sub(-1)=="," and ",..." or "...")
            end
        end
        local out = s:gsub("[^\r\n]+", function(line)
            local hit = lookup(line)
            if hit then return hit end
            local result = line
            for _,key in ipairs(labels) do
                result = result:gsub("%f[%a]"..escapePattern(key).."%s*:", function() return dictionary[key]..":" end)
            end
            for _,key in ipairs(phrases) do
                result = result:gsub(escapePattern(key), function() return dictionary[key] end)
            end
            local status = result:match("Giáo phái tấn công:") or result:match("Chu kỳ:") or result:match("Thời tiết:") or result:match("Quần xã sinh vật:")
            if status then
                for _,key in ipairs({"No","Yes","Day","Night","Clear","Snow"}) do
                    result = result:gsub("%f[%a]"..key.."%f[%A]", function() return dictionary[key] end)
                end
            end
            return result
        end)
        return lookup(out) or out
    end
    if shared.VI_CONNECTION then pcall(function() shared.VI_CONNECTION:Disconnect() end) end
    for _,name in ipairs({"VI6_CONNECTIONS","VI7_CONNECTIONS"}) do
        if type(shared[name]) == "table" then
            for _,c in ipairs(shared[name]) do pcall(function() c:Disconnect() end) end
        end
    end
    if type(shared.VI7_STOP)=="function" then pcall(shared.VI7_STOP) end
    local active = true
    local connections = {}
    local roots, tracked = {}, {}
    local missing = {}
    local count, rootCount = 0,0
    shared.VI7_CONNECTIONS = connections
    shared.VI7_STOP = function()
        active = false
        for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        for _,record in pairs(tracked) do pcall(function() record.connection:Disconnect() end) end
        table.clear(tracked)
    end
    local function watch(obj)
        if not active or tracked[obj] then return end
        local prop
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            prop = "Text"
        elseif obj:IsA("TextBox") then
            prop = "PlaceholderText"
        else return end
        local record = {busy=false}
        local function apply()
            if not active or record.busy or not obj.Parent then return end
            record.busy = true
            local ok, err = pcall(function()
                local original = obj[prop]
                local translated = translate(original)
                if translated ~= original then
                    obj[prop] = translated
                    count = count + 1
                elseif not lookup(original) and original:match("[A-Za-z]") and not original:find("[\128-\255]") and not missing[original] then
                    missing[original] = true
                    print("[VI7 MISSING] "..original)
                end
            end)
            record.busy = false
            if not ok and not record.error then
                record.error = true
                warn("[VI7.2 TEXT ERROR] "..tostring(err))
            end
        end
        record.connection = obj:GetPropertyChangedSignal(prop):Connect(apply)
        tracked[obj] = record
        apply()
    end
    local function unwatch(obj)
        local record=tracked[obj]
        if record then
            record.connection:Disconnect()
            tracked[obj]=nil
        end
    end
    local function addRoot(root)
        if not active or typeof(root)~="Instance" or roots[root] then return end
        roots[root] = true
        rootCount = rootCount+1
        print("[VI7 ROOT] "..root.Name)
        table.insert(connections,root.DescendantAdded:Connect(function(obj) task.defer(watch,obj) end))
        table.insert(connections,root.DescendantRemoving:Connect(unwatch))
        for _,obj in ipairs(root:GetDescendants()) do watch(obj) end
    end
    local function discoverRoots()
        if not active then return end
        for _,key in ipairs({"ScreenGui","DropdownGui","NotificationGui","TooltipGui","PopupGui"}) do
            local found, root = pcall(function() return ui[key] end)
            if found then
                local added, err = pcall(addRoot, root)
                if not added then print("[VI7.2] Root error " .. key .. ": " .. tostring(err)) end
            end
        end
        local parent=ui.ScreenGui.Parent
        if parent then
            for _,obj in ipairs(parent:GetChildren()) do
                local name=obj.Name:lower()
                if obj:IsA("ScreenGui") and (name=="windui" or name:match("^windui/")) then
                    addRoot(obj)
                end
            end
        end
    end
    print("[VI7.2] Discovering UI roots...")
    discoverRoots()
    local parent=ui.ScreenGui.Parent
    if parent then
        table.insert(connections,parent.ChildAdded:Connect(function() task.defer(discoverRoots) end))
    end
    local total=0
    for _ in pairs(dictionary) do total=total+1 end
    print("[VI7.2] Dictionary: "..total)
    print("[VI7.2] Roots: "..rootCount)
    print("[VI7.2] Translated: "..count)
    print("[VI7.2] READY!")
end
