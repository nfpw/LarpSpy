local C = game.GetService(game, "ReplicatedStorage").ClientSync
local F = filtergc("function", {}, false)
local m, s

for _, o in pairs(F) do
    if islclosure(o) then
        local ok, c = pcall(debug.getconstants, o)
        if ok and type(c) == "table" then
            for _, v in pairs(c) do
                if v == "WalkSpeed set to %.0f" then s = o end
                if v == "Script_Unknown" then m = o end
            end
        end
    end
end

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if not checkcaller() and self == C and getnamecallmethod() == "FireServer" then
        local a = table.pack(...)
        local e = rawget(a, 6)
        if type(e) == "table" then
            local v = rawget(e, "env")
            if type(v) == "table" then
                rawset(v, "d", { g = 0, k = 0, n = 0, s = 0, t = 0, ui = 0 })
                rawset(v, "s", {})
                rawset(v, "w", {})
            end
        end
        if s and m then
            local ok, r = pcall(s, a[3], a[4], a[6])
            if ok and r then
                local ok2, h = pcall(m, rawget(a, 1) + r, rawget(a, 2))
                if ok2 and h then a[2] = h end
            end
        end
        return old(self, table.unpack(a, 1, a.n))
    end
    return old(self, ...)
end))
