-- Get the game's workspace
local workspace = game.Workspace

-- Create a new LocalScript and add it to the workspace
local antiCheatBypass = Instance.new("Script")
antiCheatBypass.Parent = workspace

-- Define the hookfunction to replace the anticheat function
local originalFunc, overrideFunc
do
    local success, err = pcall(function()
        -- Find the anticheat script and get its function name
        for _, v in pairs(game:GetService("Workspace"):GetDescendants()) do
            if v:IsA("Script") then
                if string.find(v.Source, "AntiCheat") or string.find(v.Source, "Roblox.Jailbreak.AntiCheat") then
                    originalFunc = loadstring(v.Source)
                    break
                end
            end
        end

        -- Define the override function to disable anticheat checks
        if originalFunc ~= nil then
            overrideFunc = function(...)
                return nil
            end
            setfenv(overrideFunc, setfenv(originalFunc, {}))
            for k, v in pairs(getfenv(originalFunc)) do
                setfenv(overrideFunc)[k] = v
            end
        else
            error("Could not find anticheat script!")
        end
    end)
    if not success then
        error(err)
    end
end

-- Replace the original anticheat function with our override function
setmetatable(game, {
    __index = function(self, key)
        if key == originalFunc and type(originalFunc) == "function" then
            return overrideFunc
        else
            return rawget(self, key)
        end
    end
})

-- Disable the anticheat script for this user only
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.UserId ~= game.Players.LocalPlayer.UserId then
        antiCheatBypass:Destroy()
        break
    end
end

print("Anticheat bypass activated!")
