const Lighting = game:GetService("Lighting")

const CopyPropertiesIntoAttributes = require(script.Parent.Parent.Helper.CopyPropertiesIntoAttributes)

return function(saveDefaults: boolean?)
    const LightingPropertiesHolder = Instance.new("Folder")
    LightingPropertiesHolder.Name = "Lighting"
    CopyPropertiesIntoAttributes(LightingPropertiesHolder, Lighting, saveDefaults)
    for _, child in Lighting:GetChildren() do
        child:Clone().Parent = LightingPropertiesHolder
    end
    return LightingPropertiesHolder
end
