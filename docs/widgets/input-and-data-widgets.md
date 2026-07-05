# Input and data widgets

## Entry

Entries are focusable text fields. Feed keystrokes into them via `app:feedKeystroke()`.

```lua
local nameVar = sc.gui.newVariable("")
app:createEntry({
    x = 2, y = 2, width = 80, height = 12,
    placeholder = "type here...",
    variable = nameVar,
    onSubmit = function(entry, text)
        print("submitted", text)
    end,
})
```

## Slider

Sliders let users pick numeric values:

```lua
app:createSlider({
    x = 2, y = 20, width = 80, height = 10,
    min = 0, max = 100, value = 40, step = 1,
    onChange = function(_, value)
        print(value)
    end,
})
```

## Progress bar

Progress bars display a value in a visual bar:

```lua
local bar = app:createProgressBar({
    x = 2, y = 36, width = 80, height = 8,
    min = 0, max = 100, value = 40,
})

bar:setValue(75)
```

## List box

List boxes provide a simple selection list:

```lua
local list = app:createListBox({
    x = 2, y = 48, width = 80, height = 30,
    items = { "One", "Two", "Three" },
})
```
