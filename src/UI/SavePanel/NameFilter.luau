--!nonstrict
--[[
    Builds the whitelist/blacklist + pinned-list UI used by Lighting, Workspace,
    Music, and Material's by-name filter. Returns ONE Frame so callers don't
    have to fight `table.unpack` truncation when composing children.
]]
local Form = require(script.Parent.Parent.Form)
local LiveSelection = require(script.Parent.Parent.Parent.Helper.LiveSelection)
local PinList = require(script.Parent.PinList)
local StringSetOps = require(script.Parent.StringSetOps)
local Vide = require(script.Parent.Parent.Parent.Packages.Vide)
local create = Vide.create

type FilterMode = "Whitelist" | "Blacklist"
type Status = "info" | "success" | "error"

return function(props: {
    enabled: () -> boolean,
    mode: any,
    items: any,
    accent: Color3,
    layoutOrder: number,
    setStatus: (string, Status?) -> (),
}): Frame
    local function addFromSelection()
        local selected = LiveSelection.current()
        if #selected == 0 then
            props.setStatus("Select instances in Explorer first", "error")
            return
        end
        local toAdd: { string } = {}
        for _, inst in selected do
            table.insert(toAdd, inst.Name)
        end
        local added = StringSetOps.addMany(props.items, toAdd)
        local total = #props.items()
        if added == 0 then
            props.setStatus(`All {#selected} name(s) were already pinned`, "info")
        else
            props.setStatus(`Added {added} name(s); {total} total`, "info")
        end
    end

    return create("Frame")({
        Name = "NameFilter",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = props.layoutOrder,
        Visible = props.enabled,
        create("UIListLayout")({
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
        }),
        Form.SegmentedToggle({
            value = props.mode,
            options = { "Whitelist", "Blacklist" },
            onSelect = function(option)
                props.mode(option :: FilterMode)
            end,
            layoutOrder = 1,
            accent = props.accent,
        }),
        Form.Row({
            layoutOrder = 2,
            height = 26,
            children = {
                Form.Button({
                    text = "Add from Selection",
                    onClick = addFromSelection,
                    width = UDim2.new(0.5, -3, 1, 0),
                    layoutOrder = 1,
                }),
                Form.Button({
                    text = "Clear all",
                    onClick = function()
                        StringSetOps.clear(props.items)
                    end,
                    width = UDim2.new(0.5, -3, 1, 0),
                    layoutOrder = 2,
                }),
            },
        }),
        Form.Label({
            text = function()
                local n = #props.items()
                if n == 0 then
                    return "No names pinned - no filter applied"
                end
                return `Pinned: {n} name(s)`
            end,
            muted = true,
            width = UDim2.new(1, 0, 0, 16),
            layoutOrder = 3,
        }),
        PinList({
            items = props.items,
            onRemove = function(target)
                StringSetOps.remove(props.items, target)
            end,
            layoutOrder = 4,
        }),
    })
end
