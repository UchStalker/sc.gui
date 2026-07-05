# Installation and setup

sc.gui is distributed as a single Lua module file. Place the file with a name, preferrably "sc.gui" (WITHOUT the .lua extension) in the Computer root directory.

Then, import it via:

```lua
require("sc.gui")
```
You do not need to capture output of `require()`. This defines the library globally as `sc.gui`.

## Creating an application

```lua
local display = sc.getDisplays()[1]
local keyboard = sc.getKeyboards()[1]

local app = sc.gui.new()
app:init(display, {
    autoUpdate = false,
    touchscreenEnabled = true,
    autoClear = true,
    backgroundColor = "#101018",
    scaleEnabled = true,
    scaleSizeW = 128,
    scaleSizeH = 128,
    font = "CALIBRI",
    fontSize = 7,
})
```

## Rendering loop

Call the update and render functions from your ScrapComputers `onUpdate` handler:

```lua
function onUpdate()
    if keyboard and keyboard.isPressed() then
        app:feedKeystroke(keyboard.getLatestKeystroke())
    end

    sc.gui.onUpdate()
    app:render()
end
```

## Notes

- `autoUpdate = false` is useful if you want to render manually.
- `scaleEnabled` makes the UI author at a design size and scale to the actual display. NOTE that this feature is not perfect, and there may be issues.
- The library uses the first available display and keyboard by default when present.
