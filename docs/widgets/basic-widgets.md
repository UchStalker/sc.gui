# Basic widgets

sc.gui includes several interactive and non-interactive controls. Widgets use the active text mode from `app:init(...)`; set `textMode = "regular"` for built-in regular text, or leave the default scalable mode for ASCF text.

## Label

Use labels for static text:

```lua
app:createLabel({ x = 2, y = 2, text = "Title" })
```

## Button

Buttons support press, release, and click callbacks:

```lua
app:createButton({
    x = 2, y = 12, width = 40, height = 10,
    text = "Press me",
    onClick = function(button)
        print("clicked", button.text)
    end,
})
```

## Checkbox

Checkboxes are toggleable controls and can be bound to a variable:

```lua
local checked = sc.gui.newVariable(false)
app:createCheckbox({ x = 2, y = 26, text = "Enabled", variable = checked })
```

## Radio button

Radio buttons share a variable and form a mutually exclusive group:

```lua
local color = sc.gui.newVariable("R")
app:createRadioButton({ x = 2, y = 40, variable = color, value = "R", text = "Red" })
app:createRadioButton({ x = 2, y = 50, variable = color, value = "G", text = "Green" })
```
