--!nonstrict
--[[
    "Runtime Package" section: clones the bundled Smapshot ModuleScript into
    ReplicatedStorage so non-Wally games can load snapshots at runtime.
]]
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")

local Colors = require(script.Parent.Parent.Colors)
local Form = require(script.Parent.Parent.Form)

type Status = "info" | "success" | "error"

local function findPackageModule(self: ModuleScript): ModuleScript?
    local packages = self.Parent.Parent.Parent:FindFirstChild("Packages")
    local index = packages and packages:FindFirstChild("_Index")
    if not index then
        return nil
    end
    for _, entry in index:GetChildren() do
        if string.sub(entry.Name, 1, #"gigahd_smapshot") == "gigahd_smapshot" then
            local module = entry:FindFirstChild("smapshot")
            if module and module:IsA("ModuleScript") then
                return module
            end
        end
    end
    return nil
end

return function(deps: { setStatus: (string, Status?) -> () })
    local function doInstall()
        local module = findPackageModule(script)
        if not module then
            deps.setStatus("Could not locate bundled Smapshot package", "error")
            return
        end
        local recording = ChangeHistoryService:TryBeginRecording("Smapshot: Install runtime package")
        local existing = ReplicatedStorage:FindFirstChild("Smapshot")
        if existing then
            existing:Destroy()
        end
        local clone = module:Clone()
        clone.Name = "Smapshot"
        clone.Parent = ReplicatedStorage
        if recording then
            ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
        end
        Selection:Set({ clone })
        deps.setStatus(
            if existing then "Replaced ReplicatedStorage.Smapshot" else "Installed ReplicatedStorage.Smapshot",
            "success"
        )
    end

    local ui = Form.Section({
        title = "Runtime Package",
        layoutOrder = 3,
        accent = Colors.sectionAccents.runtime,
        children = {
            Form.Label({
                text = "Install the Smapshot module into ReplicatedStorage so games can load snapshots at runtime without Wally.",
                muted = true,
                width = UDim2.new(1, 0, 0, 32),
                layoutOrder = 1,
            }),
            Form.Button({
                text = "Install to ReplicatedStorage",
                onClick = doInstall,
                width = UDim2.new(1, 0, 0, 28),
                layoutOrder = 2,
                accent = Colors.sectionAccents.runtime,
                primary = true,
            }),
        },
    })

    return { ui = ui }
end
