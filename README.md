# Roxy Menu Plugin for Roxy Engine

Roxy Dialogue is a plugin for [Roxy Engine](https://github.com/invisiblesloth/roxy-engine) that

---

## Features

- 

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
local menu = RoxyMenu()
```

---

## Requirements

This plugin is designed to be used **with the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine)**.  
It relies on Roxy’s:

- 

It will not work in non-Roxy game projects without modification.

---

## License

MIT License.

Roxy Dialogue depends on the [Roxy Engine](https://github.com/invisiblesloth/roxy-engine), also MIT-licensed.

[👉 Details](./LICENSE)

---

**Note:** Roxy and the plugins are currently pre-release software.

Thanks for building with Roxy!
