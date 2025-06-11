# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [0.2.0] - 2025-06-11
### Added ✨
- Added support for new priority-based input system via `roxy.Input.addHandler()` and `removeHandler()`
- Integrated `roxy.Input.makeModalHandler()` for modal input masking in `RoxyMenu`

### Changed 🔧
- Updated `RoxyMenu` to use explicit input ownership with `addHandler` and `removeHandler`
- Replaced deprecated input stack calls with new API to align with `roxy-engine`'s input model

### Removed ❌
- Removed usage of legacy `saveAndSetHandler()` and `restoreHandler()` in input setup

### Breaking Changes ⚠️
- `RoxyMenu` now requires `roxy.Input.addHandler()` and `removeHandler()` for input management  
- **Migration:**  
  - Replace:
    ```lua
    roxy.Input.saveAndSetHandler(...)
    roxy.Input.restoreHandler()
    ```
    with:
    ```lua
    roxy.Input.addHandler(self, handler, 100)
    roxy.Input.removeHandler(self)
    ```
  - For modal menus, wrap handlers using `roxy.Input.makeModalHandler(handler)`
  - See [BREAKING_CHANGES.md](./BREAKING_CHANGES.md) for full details

---

## [0.1.0] - 2025-05-30

### Added ✨
- Added `roxy-menu`, a flexible and customizable menu plugin for Playdate games using Roxy.
- Supported d-pad, crank, and button navigation for menu interaction.
- Enabled runtime menu item management (add, remove, select).
- Provided modal and dismissible menu options with optional callbacks.
- Exposed appearance customization via Roxy’s theming, font, color, and layout utilities.
