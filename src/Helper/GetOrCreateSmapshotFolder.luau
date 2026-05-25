const ServerStorage = game:GetService("ServerStorage")

return function(): Folder
    local folder = ServerStorage:FindFirstChild("Smapshot")
    if folder and folder:IsA("Folder") then
        return folder
    end
    folder = Instance.new("Folder")
    folder.Name = "Smapshot"
    folder.Parent = ServerStorage
    return folder
end