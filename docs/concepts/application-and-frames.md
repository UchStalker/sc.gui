# Application model and frames

## GUIApplication

A `GUIApplication` is the root object for a GUI session. It owns:

- the display and runtime options,
- the root frame,
- focus state,
- all top-level widgets.

Create one with:

```lua
local app = sc.gui.new()
```

Then initialize it with `app:init(display, opts)`.

## Root frame

Every widget created without an explicit parent lives on the application's root frame. The root frame is created automatically and represents the full drawing surface.

## Frames

Frames are containers used to group widgets. They can have:

- a background color,
- a border color,
- padding,
- child widgets.

```lua
local panel = app:createFrame({
    x = 2, y = 10, width = 60, height = 24,
    backgroundColor = "#181820",
    borderColor = "#333333",
    padding = 2,
})
```

## Rendering flow

The normal render cycle is:

1. process input with `sc.gui.onUpdate()`
2. update widget state if needed
3. call `app:render()`

The framework redraws only changed regions where possible, which keeps the UI responsive when many widgets are present.

## Object lifecycle

Widgets are created by calling a `create*` method on an application or frame. Once created, they are attached to the parent frame and participate in layout and rendering automatically.

If you change a widget's visible state, size, text, or bound variable, the framework schedules a redraw. Some actions, such as changing layout-affecting properties, may require `app:invalidate()` so the layout system can reflow siblings.
