# Layout systems

sc.gui provides three geometry systems for positioning widgets.

## Place layout

Place layout is the default. Widgets are positioned directly by `x` and `y` values.

```lua
app:createButton({ x = 2, y = 10, width = 30, height = 10, text = "A" })
```

## Pack layout

Pack layout stacks children against a side of a container.

```lua
local bar = app:createFrame({ x = 2, y = 24, width = 100, height = 16, padding = 2 })
local a = bar:createButton({ width = 28, height = 10, text = "A" })
a:pack({ side = "left", padx = 1 })
```

## Grid layout

Grid layout places widgets into rows and columns.

```lua
local grid = app:createFrame({ x = 2, y = 44, width = 100, height = 30, padding = 2 })
local a = grid:createButton({ width = 40, height = 10, text = "A" })
a:grid({ row = 0, column = 0 })
```

## Invalidation and reflow

If a widget changes size or layout state, call `app:invalidate()` to reflow managed layouts.

## Layout behavior summary

- `place` is best when you want explicit coordinates.
- `pack` is best for simple stacked rows or columns.
- `grid` is best for tabular arrangements with rows and columns.

When a child is added, removed, or resized, the parent frame recalculates layout on the next render pass.
