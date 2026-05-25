const AssetService = game:GetService("AssetService")
const ServerStorage = game:GetService("ServerStorage")

const ConvertPartToRegion3int16 = require(script.Helper.ConvertPartToRegion3int16)
const LoadInstances = require(script.Instances.LoadInstances)
const SaveInstances = require(script.Instances.SaveInstances)
const LoadLighting = require(script.Lighting.LoadLighting)
const SaveLighting = require(script.Lighting.SaveLighting)
const LoadTerrain = require(script.Terrain.LoadTerrain)
const SaveTerrain = require(script.Terrain.SaveTerrain)
const Map = {}
export type TerrainConfig = {
    slice: (BasePart | Region3int16)?,
}

export type LightingConfig = {}

export type SaveConfig = {
    --- Defines under what the data should be saved as (Folder: Less overhead, Model: Able to be saved via Assets)
    exportType: "Folder" | "Model",
    saveDefaults: boolean?,
    terrain: TerrainConfig?,
    instances: { Instance }?,
    lighting: LightingConfig?,
}

function Map.Save(config: SaveConfig): Folder | Model
    const exportType = config.exportType
    assert(exportType == "Folder" or exportType == "Model", `{exportType} is not a valid export type`)
    const export = Instance.new(exportType)

    const terrainConfig = config.terrain
    if terrainConfig then
        const slice = if typeof(terrainConfig.slice) == "Instance" and terrainConfig.slice:IsA("BasePart")
            then ConvertPartToRegion3int16(terrainConfig.slice)
            else terrainConfig.slice
        const result = SaveTerrain(slice, config.saveDefaults)
        result.Parent = export
    end
    const instances = config.instances
    if instances then
        const result = SaveInstances(instances)
        result.Parent = export
    end
    const lightingConfig = config.lighting
    if lightingConfig then
        const result = SaveLighting(config.saveDefaults)
        result.Parent = export
    end

    return export :: any
end

local function LoadFromInstance(toLoad: Instance, keepDirty: boolean?)
    local terrain = toLoad:FindFirstChild("MapTerrain")
    if terrain and terrain:IsA("TerrainRegion") then
        LoadTerrain(terrain, keepDirty)
    end
    local instances = toLoad:FindFirstChild("Instances")
    if instances and instances:IsA("Folder") then
        LoadInstances(instances)
    end
    local lighting = toLoad:FindFirstChild("Lighting")
    if lighting and lighting:IsA("Folder") then
        LoadLighting(lighting, keepDirty)
    end
    return toLoad
end

local function LoadFromAssetId(toLoad: number, keepDirty: boolean?)
    local asset = AssetService:LoadAssetAsync(toLoad)
    local model = asset:GetChildren()[1]
    return LoadFromInstance(model, keepDirty)
end



function Map.LoadAsync(toLoad: Folder | Model | number, keepDirty: boolean?)
    local type = typeof(toLoad)
    if type == "number" then
        return LoadFromAssetId(toLoad :: number, keepDirty)
    elseif type == "Instance" then
        return LoadFromInstance(toLoad :: Instance, keepDirty)
    else
        error(`Cannot load from {type}`)
    end
end

return Map
