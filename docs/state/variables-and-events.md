# Variables and events

## Observable variables

Use `sc.gui.newVariable()` to create state that can be shared across widgets.

```lua
local enabled = sc.gui.newVariable(true)
local box = app:createCheckbox({ x = 2, y = 2, text = "Enabled", variable = enabled })
```

## Variable API

- `get()` returns the current value.
- `set(value)` updates the value and notifies traces.
- `trace(callback)` registers a callback for future updates.
- `untrace(handle)` removes a previous callback.

## Widget callbacks

Common callbacks include:

- `onClick` for buttons
- `onChange` for sliders, checkboxes, and entries
- `onSubmit` for entries
- `onSelect` for list boxes and radio buttons

## Event flow

Widgets respond to input and state changes through callbacks and through direct methods such as `setText()` or `setValue()`. Variables are especially useful when multiple widgets need to stay in sync, because changing one bound variable can update all dependent widgets through their traces and refresh logic.
