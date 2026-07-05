# Quick start

The smallest useful example creates an application, adds a label and button, and renders it.

```lua
require("sc.gui")

local display = sc.getDisplays()[1]
local app = sc.gui.new()

app:init(display, {
    autoUpdate = false,
    touchscreenEnabled = true,
    autoClear = true,
    backgroundColor = "#000000",
    font = nil,
    fontSize = 7,
    textMode = "regular",
})

app:createLabel({ x = 2, y = 2, text = "Hello sc.gui" })

app:createButton({
    x = 2, y = 12, width = 40, height = 10,
    text = "Click me",
    onClick = function()
        print("clicked")
    end,
})

function onUpdate()
    sc.gui.onUpdate()
    app:render()
end
```

## What this does

- Initializes a GUI application on the first display.
- Creates a label and a button.
- Hooks the button click to a callback.
- Renders the UI once per update loop.
- Uses the regular text path via `textMode = "regular"`, which draws with the built-in display text renderer.
