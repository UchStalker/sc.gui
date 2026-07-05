# API reference

This page is the complete reference for the released sc.gui surface. It documents the objects that exist in the public build, how they are created, what each option does, what each method does, and the practical quirks that come from the implementation.

> This reference intentionally excludes subwindow-specific features.

## 1. How the library works

sc.gui is built around a single application object that owns a root frame and all child widgets.

The usual lifecycle is:

1. Create an application with `sc.gui.new()`.
2. Initialize it with `app:init(display, opts)`.
3. Create objects with `app:create...()` or `frame:create...()`.
4. Arrange them with `place`, `pack`, or `grid`.
5. Call `app:render()` or let `autoUpdate` handle redraws.
6. Feed touch input through `sc.gui.onUpdate()` and keyboard input through `app:feedKeystroke()`.

The framework uses an incremental renderer. After the first full render, only widgets that changed are repainted when possible.

## 2. Module-level functions

### sc.gui.new()
Creates and returns a new GUI application instance.

```lua
local app = sc.gui.new()
```

What it does:
- Allocates a new application object.
- Assigns it an internal ID.
- Does not initialize it on a display yet.

Quirk:
- You must still call `app:init(display, opts)` before using the app.

### sc.gui.isDisplayInUse(display)
Checks whether a display is already attached to another GUI application.

Returns:
- `true, instance` if the display is already in use.
- `false, nil` if it is not.

Quirk:
- If a display is already claimed, `app:init()` will reclaim it from the previous instance.

### sc.gui.logger.setLevel(level)
Configures logging verbosity.

Valid values:
- `-1`: disable logging
- `0`: log errors and warnings
- `1`: log everything

### sc.gui.onUpdate()
Polls every touchscreen-enabled application and forwards touch events to widgets.

Use this once per update loop, typically from your main loop or from ScrapComputers' `onUpdate` callback.

Quirk:
- This does not render the UI. Rendering is a separate step handled by `app:render()` or `autoUpdate`.

## 3. Runtime options

Pass a table to `app:init(display, opts)`.

### `autoUpdate`
Type: boolean

Whether the app should automatically call `render()` after UI changes.

### `touchscreenEnabled`
Type: boolean

Whether the library should process touch input. If false, touch events are ignored unless you manage them yourself.

### `autoClear`
Type: boolean

Whether the display should be cleared during initialization.

### `backgroundColor`
Type: color

The clear color used when the app renders.

### `touchscreenWhitelist`
Type: table of user names or nil

Restricts touch events to specific users. If nil, all users are allowed.

### `scaleEnabled`
Type: boolean

Enables design-space scaling. When true, the layout is authored at `scaleSizeW x scaleSizeH` and then scaled to the actual display size.

### `scaleSizeW` and `scaleSizeH`
Type: number

The design resolution used when scaling is enabled. They are required if `scaleEnabled` is true.

### `font`
Type: string or nil

The default font name used for text rendering. In scalable mode this should be an installed ASCF font name. In regular mode it may be nil.

### `fontSize`
Type: number

The default font size used by scalable text widgets.

### `colorToggled`
Type: boolean

Whether scalable text is allowed to contain inline color toggles.

### `textMode`
Type: `"regular"` or `"scalable"`

The default text rendering mode for widgets. This can be overridden per widget.

## 4. GUIApplication

A `GUIApplication` is the root of the GUI system. It owns the display, the root frame, focus state, the dirty-render queue, and every widget created from the root.

### Construction

```lua
local app = sc.gui.new()
app:init(display, {
    autoUpdate = true,
    touchscreenEnabled = true,
    textMode = "regular",
})
```

### Core methods

#### `app:init(display, opts)`
Initializes the app on a display.

What it does:
- Validates the display object.
- Claims the display for this app.
- Stores runtime options.
- Builds a render target.
- Creates the root frame.
- Enables touch handling if requested.

Quirks:
- It may reclaim a display from a previous app instance.
- It requires a display-like object that has the methods used by the library.

#### `app:render()`
Renders the current UI to the display.

Quirks:
- The first render is a full redraw.
- Subsequent renders repaint only changed widgets when possible.

#### `app:invalidate()`
Marks the entire UI as dirty and forces a full redraw on the next render.

Use this when you change something that the incremental renderer will not notice automatically.

#### `app:setBackgroundColor(color)`
Changes the clear color used by the app.

#### `app:getScale()`
Returns the current scale factors for the display.

Returns:
- `scaleX`
- `scaleY`

If scaling is disabled, both are `1`.

#### `app:setTouchScreenState(state)`
Enables or disables touch processing.

#### `app:getTouchScreenState()`
Returns the current touch processing state.

#### `app:getTouchScreenWhitelist()`
Returns the current touch whitelist table, or nil.

#### `app:setTouchScreenWhitelist(whitelist)`
Replaces the current whitelist.

#### `app:getFocused()`
Returns the currently focused widget or nil.

#### `app:clearFocus()`
Removes keyboard focus from the currently focused widget.

#### `app:feedKeystroke(key)`
Sends a keystroke to the focused widget.

The entry widget uses this heavily. The special values recognized by the entry implementation are:
- `"backSpace"` for deletion
- `"\n"`, `"\r"`, or `"enter"` for submit

#### `app:getRoot()`
Returns the root frame, which is the parent for all top-level widgets.

#### `app:removeObject(object)`
Removes an object from its parent frame.

#### `app:clearObjects()`
Removes every object from the root frame.

#### `app:getObjects()`
Returns the root frame's direct children in draw order.

### Factory methods

The application can create objects directly on the root frame:

- `app:createFrame(opts)`
- `app:createLabel(opts)`
- `app:createButton(opts)`
- `app:createCheckbox(opts)`
- `app:createRadioButton(opts)`
- `app:createSlider(opts)`
- `app:createProgressBar(opts)`
- `app:createEntry(opts)`
- `app:createListBox(opts)`

These methods all delegate to the root frame's corresponding `create*` methods.

## 5. GUIObject

`GUIObject` is the common base class for every widget and for frames.

Everything below is inherited by frames and widgets unless a widget overrides it.

### Common properties

- `x`: horizontal position in the parent coordinate space for the place manager.
- `y`: vertical position in the parent coordinate space for the place manager.
- `width`: width in pixels.
- `height`: height in pixels.
- `visible`: whether the object is drawn.
- `enabled`: whether the object responds to input.

### Common methods

#### `setPosition(x, y)`
Sets the object's `x` and `y` values and invalidates layout.

#### `setSize(width, height)`
Sets the object's size and invalidates layout.

#### `setVisible(visible)`
Shows or hides the object and its children.

#### `setEnabled(enabled)`
Enables or disables touch interaction.

Quirk:
- When disabled, the object stops receiving touch events, but its visual state is not changed automatically.

#### `getAbsolutePosition()`
Returns the object's resolved absolute position after layout.

#### `getParent()`
Returns the parent frame or nil.

#### `place(opts)`
Uses absolute placement.

Supported fields:
- `x`
- `y`
- `width`
- `height`

#### `pack(opts)`
Uses the pack layout manager.

Supported fields:
- `side`: `"top"`, `"bottom"`, `"left"`, `"right"`
- `padx`
- `pady`
- `fill`: `"none"`, `"x"`, `"y"`, `"both"`
- `anchor`: compass alignment such as `"center"`, `"n"`, `"ne"`, `"sw"`, and so on

Quirks:
- Packing works by consuming strips of the available space.
- The child is centered inside the allocated strip unless you set an anchor.
- If `fill` is used, the object's size may be overwritten by the layout manager.

#### `grid(opts)`
Uses the grid layout manager.

Supported fields:
- `row`
- `column`
- `rowspan`
- `columnspan`
- `padx`
- `pady`
- `sticky`: compass string such as `"we"`, `"nsew"`, or `""`

Quirks:
- Row and column sizes are computed from the children that actually use the grid.
- `sticky` can expand or anchor the child within its cell.

#### `destroy()`
Removes the object from its parent frame.

## 6. GUIFrame

A `GUIFrame` is a container object. It can host other objects, draw a background, draw a border, and lay out children.

### Frame options

When you create a frame, you may pass:

- `x`
- `y`
- `width`
- `height`
- `padding`
- `backgroundColor`
- `borderColor`
- `visible`

### Methods

#### `setPadding(padding)`
Applies the same padding to all four sides.

#### `setFrameColor(color)`
Sets the frame's fill color.

Use `nil` for transparency.

#### `clearChildren()`
Removes every child from the frame.

#### `getChildren()`
Returns the frame's direct children.

#### `createFrame(opts)`
Creates a child frame inside the frame.

#### `createLabel(opts)`
Creates a label inside the frame.

#### `createButton(opts)`
Creates a button inside the frame.

#### `createCheckbox(opts)`
Creates a checkbox inside the frame.

#### `createRadioButton(opts)`
Creates a radio button inside the frame.

#### `createSlider(opts)`
Creates a slider inside the frame.

#### `createProgressBar(opts)`
Creates a progress bar inside the frame.

#### `createEntry(opts)`
Creates an entry inside the frame.

#### `createListBox(opts)`
Creates a list box inside the frame.

### Frame quirks

- Frames are transparent by default unless `backgroundColor` is set.
- The layout system uses the frame's content area, which excludes padding.
- A frame's `width` and `height` are important for layout; with size `0`, it may not have visible space to contribute.

## 7. GUIVariable

A `GUIVariable` is an observable value container. Widgets can bind to it and react when it changes.

### Creation

```lua
local value = sc.gui.newVariable("hello")
```

### Methods

#### `get()`
Returns the current stored value.

#### `set(value)`
Updates the value.

If the value changed, all registered traces are called.

Quirk:
- It uses Lua's normal equality check. If the new value is considered equal by `==`, it will not notify traces.

#### `trace(callback)`
Registers a callback that runs whenever the value changes.

Returns a numeric handle that can later be passed to `untrace()`.

#### `untrace(handle)`
Removes a previously registered trace callback.

### Why this is useful

A variable can bind several widgets to the same state. For example, a checkbox and an entry can both react to the same variable.

## 8. Widget reference

### GUILabel

A static text label.

#### What it does

- Displays text.
- Does not respond to touch input.
- Automatically measures its own size from the current text.

#### Constructor options

- `x`, `y`
- `text` (required)
- `font`
- `fontSize`
- `textColor`
- `colorToggled`
- `visible`

#### Methods

- `setText(text)`: replaces the label text.

#### Quirks

- A label's `width` and `height` are updated during drawing based on the current text.
- If you use pack/grid layout and the size changes, the layout may need reflow.

### GUIButton

A clickable button.

#### What it does

- Draws a rectangle with optional border.
- Centers the label inside it.
- Reports press, release, and click events.

#### Constructor options

- `x`, `y`
- `width` (default `40`)
- `height` (default `16`)
- `text`
- `font`
- `fontSize`
- `colorToggled`
- `textColor`
- `backgroundColor`
- `pressedColor`
- `borderColor`
- `visible`
- `enabled`
- `onClick`
- `onPress`
- `onRelease`

#### Methods

- `setText(text)`: changes the label text.

#### Event behavior

- `onPress` fires when the button is first pressed inside it.
- `onRelease` fires when the press is released, even if the pointer leaves the button.
- `onClick` fires only when a press started inside the button and ended inside the button.

#### Quirks

- The button is opaque by default, so it redraws its own background.
- Its visual state changes while held down through `pressedColor`.

### GUICheckbox

A toggleable checkbox.

#### What it does

- Renders a square box with an optional tick.
- Toggles between checked and unchecked when tapped.
- Can be bound to a `GUIVariable`.

#### Constructor options

- `x`, `y`
- `size` (default `12`)
- `width` (default equals `size`)
- `text`
- `font`
- `fontSize`
- `colorToggled`
- `checked`
- `variable`
- `spacing`
- `textColor`
- `backgroundColor`
- `borderColor`
- `checkColor`
- `visible`
- `enabled`
- `onChange`

#### Methods

- `setChecked(checked)`: sets the state and updates the bound variable if present.
- `isChecked()`: returns the current state.

#### Quirks

- The visible box uses `size`; the overall clickable area uses `width`.
- The checkmark is drawn as a filled rectangle, not a traditional checkmark glyph.
- If a variable is provided, the checkbox automatically traces it and keeps its checked state in sync.

### GUIRadioButton

A radio button that participates in a shared group.

#### What it does

- Draws a circular outline.
- Fills the center when selected.
- Shares state with other radio buttons through a `GUIVariable`.

#### Constructor options

- `x`, `y`
- `size` (default `12`)
- `width` (default equals `size`)
- `variable` (required)
- `value` (required)
- `innerPadding`
- `text`
- `font`
- `fontSize`
- `colorToggled`
- `spacing`
- `textColor`
- `borderColor`
- `selectColor`
- `visible`
- `enabled`
- `onSelect`

#### Methods

- `select()`: selects this option by writing its `value` into the shared variable.
- `isSelected()`: returns whether the shared variable currently equals this radio button's value.

#### Quirks

- Radio buttons are only useful when multiple buttons share the same variable.
- The constructor asserts that the variable is a `GUIVariable` created with `sc.gui.newVariable()`.

### GUISlider

A draggable numeric slider.

#### What it does

- Renders a track and a knob.
- Lets the user drag the knob to set a numeric value.
- Optionally snaps values to a step.

#### Constructor options

- `x`, `y`
- `width` (default `60`)
- `height` (default `12`)
- `min` (default `0`)
- `max` (default `1`)
- `value`
- `step`
- `trackThickness`
- `knobRadius`
- `trackColor`
- `fillColor`
- `knobColor`
- `visible`
- `enabled`
- `onChange`

#### Methods

- `setValue(value)`: sets the current value and clamps it to the allowed range.
- `getValue()`: returns the current value.

#### Event behavior

- `onChange` is called when the value changes because of user input.
- The value is clamped to `[min, max]`.
- If `step > 0`, the value snaps to the nearest multiple of that step.

#### Quirks

- The slider uses the full width as the draggable track, even though the knob may visually extend outside it.
- `setValue()` does not call `onChange`; it only updates state and redraws.

### GUIProgressBar

A non-interactive progress bar.

#### What it does

- Displays a value as a filled bar.
- Can be horizontal or vertical.
- Uses pixel-step snapping to reduce redraws when values change rapidly.

#### Constructor options

- `x`, `y`
- `width` (default `60`)
- `height` (default `10`)
- `min` (default `0`)
- `max` (default `1`)
- `value`
- `orientation` (`"horizontal"` or `"vertical"`)
- `backgroundColor`
- `fillColor`
- `borderColor`
- `pixelStep` (default `4`)
- `visible`

#### Methods

- `setValue(value)`: updates the value and redraws only if the snapped fill changed.
- `getValue()`: returns the current value.
- `setRange(min, max)`: changes the range and clamps the current value into it.
- `setPixelStep(step)`: changes how aggressively the fill snaps to pixel steps.

#### Quirks

- The fill is not rendered smoothly when `pixelStep > 1`; it jumps in larger steps.
- `setValue()` and `setRange()` are intentionally conservative about repainting.

### GUIEntry

A single-line text field.

#### What it does

- Displays editable text.
- Receives keyboard input only when focused.
- Supports placeholder text and optional variable binding.

#### Constructor options

- `x`, `y`
- `width` (default `80`)
- `height` (default `16`)
- `text`
- `placeholder`
- `variable`
- `maxLength`
- `padding`
- `font`
- `fontSize`
- `colorToggled`
- `textColor`
- `placeholderColor`
- `backgroundColor`
- `borderColor`
- `focusBorderColor`
- `cursorColor`
- `visible`
- `enabled`
- `onChange`
- `onSubmit`

#### Methods

- `focus()`: gives the entry keyboard focus.
- `getText()`: returns the current text.
- `setText(text)`: replaces the text and updates the bound variable if present.
- `clear()`: clears the text.

#### Input behavior

- Touching the entry gives it focus.
- Keystrokes are delivered through `app:feedKeystroke()`.
- `backSpace` deletes the last character.
- Enter-like keys trigger `onSubmit` instead of appending text.

#### Quirks

- The entry is single-line only.
- It does not support cursor movement, selection, or editing history.
- If a variable is provided, the entry watches it and mirrors its value as text.

### GUIListBox

A simple single-selection list of strings.

#### What it does

- Renders a vertical list of rows.
- Lets the user select one item by tapping it.
- Does not scroll; it simply draws whatever fits in the box.

#### Constructor options

- `x`, `y`
- `width` (default `80`)
- `height` (default `60`)
- `items`
- `selectedIndex`
- `itemHeight`
- `padding`
- `font`
- `fontSize`
- `colorToggled`
- `itemColor`
- `selectedColor`
- `backgroundColor`
- `selectedBackgroundColor`
- `borderColor`
- `visible`
- `enabled`
- `onSelect`

#### Methods

- `setItems(items)`: replaces the item list and clears the selection.
- `getItems()`: returns the current item list.
- `addItem(item)`: appends one string to the list.
- `setSelected(index)`: selects an item by 1-based index, or `0` to clear it.
- `getSelected()`: returns `(index, value)`.
- `clearSelection()`: clears the selection.

#### Quirks

- `selectedIndex` uses 1-based indexing.
- The list box is scrollless, so only the rows that fit in the `height` will be visible.
- Touch selection uses the row height and does not support dragging or keyboard selection.

## 9. Text rendering modes

Widgets use the application's default text mode unless a widget overrides it.

### `textMode = "regular"`
Uses the built-in display text renderer.

This is the simplest path and is usually the best default for ordinary UI text.

### `textMode = "scalable"`
Uses the ASCF text path.

This is the path that uses the scalable font system. It is more flexible for larger text and custom fonts, but it depends on the font being available.

### Practical notes

- Labels, buttons, checkboxes, radio buttons, entries, and list boxes all use this mode.
- In scalable mode, `font` and `fontSize` matter more than in regular mode.
- In regular mode, the text renderer does not use the same ASCF sizing path.

## 10. Common gotchas

These are the most important implementation quirks to keep in mind:

- `app:init()` must be called before most other operations.
- `sc.gui.onUpdate()` is only for touch dispatch; it does not render.
- Layout changes are invalidated automatically, but calling `app:invalidate()` is still useful if you change something outside the normal dirty path.
- `GUIVariable:set()` does not notify when the value is unchanged according to Lua equality.
- `GUIEntry` is keyboard-driven and does not implement full text editing features.
- `GUIListBox` is intentionally simple and scrollless.
- `GUIProgressBar` and `GUISlider` are value controls, not full data-entry widgets.
