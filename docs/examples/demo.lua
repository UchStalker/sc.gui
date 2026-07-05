-- sc.gui feature demo for a 128x128 display.

require("sc.gui")

local display = sc.getDisplays()[1]
local keyboard = sc.getKeyboards()[1]

local app = sc.gui.new()
app:init(display, {
    -- Configure the app for a small 128x128 display.
    autoUpdate         = false,
    touchscreenEnabled = true,
    autoClear          = true,
    backgroundColor    = "#101018",
    touchscreenWhitelist = nil,
    scaleEnabled = true,
    scaleSizeW   = 128,
    scaleSizeH   = 128,

    font     = nil,
    fontSize = 7,
    textMode = "scaleable",
})

local clicks = 0
local tick = 0

local lightsOn = sc.gui.newVariable(true)
local colorSel = sc.gui.newVariable("R")

lightsOn:trace(function(on)
    -- Toggle the background color when the checkbox state changes.
    app:setBackgroundColor(on and "#101018" or "#000000")
end)

app:createLabel({ x = 2, y = 2, text = "sc.gui demo", textColor = "#7fd0ff" })

local buttonBar = app:createFrame({
    x = 2, y = 11, width = 124, height = 15,
    backgroundColor = "#181820", borderColor = "#333333", padding = 2,
})

local helloBtn = buttonBar:createButton({ width = 34, height = 11, text = "Hello" })
helloBtn:pack({ side = "left", padx = 1 })
helloBtn.onPress = function() print("Hello pressed") end
helloBtn.onRelease = function() print("Hello released") end
helloBtn.onClick = function() print("Hello clicked!") end

local countBtn = buttonBar:createButton({ width = 40, height = 11, text = "Count: 0" })
countBtn:pack({ side = "left", padx = 1 })
countBtn.onClick = function(btn)
    clicks = clicks + 1
    btn:setText("Count: " .. clicks)
end

local killBtn = buttonBar:createButton({ width = 34, height = 11, text = "Del", backgroundColor = "#5a2020" })
killBtn:pack({ side = "left", padx = 1 })

local optsFrame = app:createFrame({
    x = 2, y = 28, width = 124, height = 26,
    backgroundColor = "#181820", borderColor = "#333333", padding = 2,
})

local lightsChk = optsFrame:createCheckbox({
    -- Bind the checkbox to a shared variable.
    width = 56, size = 10, text = "Lights", variable = lightsOn,
    onChange = function(_, checked) print("lights ->", checked) end,
})
lightsChk:grid({ row = 0, column = 0, padx = 1, pady = 1 })

local redRadio = optsFrame:createRadioButton({
    width = 56, size = 10, variable = colorSel, value = "R", text = "Red",
    selectColor = "#e05050",
    onSelect = function(_, value) print("color ->", value) end,
})
redRadio:grid({ row = 0, column = 1, padx = 1, pady = 1 })

local grnRadio = optsFrame:createRadioButton({
    width = 56, size = 10, variable = colorSel, value = "G", text = "Green",
    selectColor = "#50e050",
    onSelect = function(_, value) print("color ->", value) end,
})
grnRadio:grid({ row = 1, column = 0, padx = 1, pady = 1 })

local bluRadio = optsFrame:createRadioButton({
    width = 56, size = 10, variable = colorSel, value = "B", text = "Blue",
    selectColor = "#5080e0",
    onSelect = function(_, value) print("color ->", value) end,
})
bluRadio:grid({ row = 1, column = 1, padx = 1, pady = 1 })

local volLabel = app:createLabel({ x = 2, y = 56, text = "Vol: 50" })

local volBar = app:createProgressBar({
    x = 86, y = 64, width = 40, height = 10, min = 0, max = 100, value = 50,
    fillColor = "#4caf50",
})

app:createSlider({
    -- The slider updates the label and the progress bar together.
    x = 2, y = 64, width = 80, height = 10, min = 0, max = 100, value = 50, step = 1,
    onChange = function(_, value)
        volLabel:setText("Vol: " .. value)
        volBar:setValue(value)
    end,
})

local animBar = app:createProgressBar({
    x = 2, y = 77, width = 124, height = 5,
    backgroundColor = "#181820", fillColor = "#e0a030", borderColor = "#333333",
})

local echoLabel = app:createLabel({ x = 2, y = 84, text = "type -> " })

local nameVar = sc.gui.newVariable("")
app:createEntry({
    -- Text entry with focus, keyboard input, and submit handling.
    x = 2, y = 92, width = 124, height = 12,
    placeholder = "click me & type...", variable = nameVar, maxLength = 24,
    onChange = function(_, text) echoLabel:setText("type -> " .. text) end,
    onSubmit = function(_, text) print("submitted:", text) end,
})

local list = app:createListBox({
    x = 2, y = 106, width = 124, height = 21, itemHeight = 9,
    items = { "Apple", "Banana", "Cherry" },
    onSelect = function(_, index, value) print("picked ##" .. index, value) end,
})
list:addItem("Durian")

---@type GUILabel|nil
local removable = app:createLabel({ x = 96, y = 56, text = "[del me]", textColor = "#888888" })
killBtn.onClick = function(btn)
    if removable then
        removable:destroy()
        removable = nil
        btn:setEnabled(false)
    end
end

function onUpdate()
    tick = tick + 1

    -- Animate the progress bar with a simple sine wave.
    animBar:setValue((math.sin(tick / 15) * 0.5 + 0.5) * 100)

    -- Send keyboard input to the focused widget.
    if keyboard and keyboard.isPressed() then
        app:feedKeystroke(keyboard.getLatestKeystroke())
    end

    sc.gui.onUpdate()
    app:render()
end
