# Roxy Menu Plugin for Roxy Engine

A flexible, efficient, and customizable menu plugin for [Roxy Engine](https://github.com/invisiblesloth/roxy-engine). Roxy Menu allows developers to quickly create intuitive, user-friendly menus with minimal overhead, integrating seamlessly with existing Roxy workflows.

---

## Features

- Uses pre-rendered graphics and grid views to minimize runtime drawing operations.
- Built-in navigation with d-pad, crank, and button input support.
- Easily adjust fonts, colors, padding, alignment, and corner radius.
- Add, remove, or update menu items at runtime.
- Supports both modal and non-modal menu configurations with optional dismissal callbacks.

---

## Installation

Add the plugin to your game project using Git submodules:

```bash
git submodule add https://github.com/invisiblesloth/roxy-menu source/libraries/roxy-menu
```

Build your project:

```bash
pdc source GameName.pdx
```

In your game code, import the plugin and use it:

```lua
import "libraries/roxy-menu/menu"

-- Usage
local menu = RoxyMenu({
  {"start", function() print("Game started") end, "Start Game"},
  {"options", function() print("Options selected") end, "Options"},
  {"more", function() print("More") end, "More"}
}, {
  dismissible = true,
  onDismiss = function() print("Menu closed") end
})
menu:activate()
```

---

## Requirements

This plugin is designed to be used **with the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine)**.  
It relies on Roxy’s:

- Sprite subclassing (`RoxySprite`)
- Text and font utilities (`roxy.Text`)
- UI drawing helpers (`roxy.UI`)
- Input handler utilities (`roxy.Input`)
- Configuration access (`roxy.Configuration`)

It will not work in non-Roxy game projects without modification.

---

## API Reference

### Initialization

```lua
RoxyMenu(menuItems, props)
```

- `menuItems`: Array of menu items (`{itemName, callback, displayName}`).
- `props`: Optional configuration table (position, dimensions, styling, behavior).

### Activation and Deactivation

- `menu:activate(pushHandler, handlerOverride, masksPreviousHandlers)`
  - Activates the menu. Optional parameters control input handling.

- `menu:deactivate()`
  - Deactivates the menu and restores previous input handlers.

### Menu Item Manipulation

- `menu:addItem(itemName, callback, displayName, placement)`
- `menu:removeItem(menuItem)`

### Selection Handling

- `menu:select(menuItem)`
- `menu:selectNext()`
- `menu:selectPrevious()`
- `menu:getSelectedItem()`

### Interaction

- `menu:click()`

---

## Customization Options

Customize appearance and behavior extensively through properties:

```lua
local props = {
  x = 200,
  y = 120,
  width = 150,
  height = 200,
  font = yourFont,
  color = Theme.colors.primary,
  background = Theme.colors.background,
  textAlignment = Text.ALIGN_CENTER,
  cornerRadius = 8,
  wrapSelection = true,
  crankThreshold = 20,
  holdDelay = 500,
  dismissible = true,
  modal = false,
  onDismiss = function() end
}
```

---

## License

MIT License.

Roxy Dialogue depends on the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine), also MIT-licensed.

[👉 Details](./LICENSE)

---

**Note:** Roxy and the plugins are currently pre-release software.

Thanks for building with Roxy!
