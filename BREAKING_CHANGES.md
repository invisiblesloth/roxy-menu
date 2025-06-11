# Breaking Changes

This document catalogs all **breaking changes** introduced across the Roxy Menu’s releases. Each section below corresponds to a specific version that included incompatible updates requiring developers to adjust their code. For migration details on each change, see the corresponding **code references** and recommended actions.

---

## [0.2.0] - 2025-06-11

### Input Handler System Overhauled

**What Changed:**
- Replaced deprecated input methods `roxy.Input.saveAndSetHandler()` and `roxy.Input.restoreHandler()` with the new `roxy.Input.addHandler()` and `roxy.Input.removeHandler()`.
- Added support for `roxy.Input.makeModalHandler()` to explicitly block input from lower-priority handlers.

**Required Updates:**
- If you override or extend `RoxyMenu:activate()` or `:deactivate()`, update all input logic:

  - **Before:**
    ```lua
    roxy.Input.saveAndSetHandler(handler, true)
    roxy.Input.restoreHandler()
    ```

  - **After:**
    ```lua
    handler = roxy.Input.makeModalHandler(handler) -- Optional for modal
    roxy.Input.addHandler(self, handler, 100)
    roxy.Input.removeHandler(self)
    ```

- Ensure you remove all usage of `saveAndSetHandler`, `restoreHandler`, and any fallback stack-based handler logic.
- Assign an appropriate priority (e.g., 100+) for modal menus to override gameplay or scene input handlers.

**Reason:**
This change was necessary to align `RoxyMenu` with `roxy-engine`’s new input architecture, which uses an explicit, priority-based stack. It improves input predictability, supports simultaneous contexts, and integrates more cleanly with scenes and transitions.

---

## **Additional Notes**

- If you’re **upgrading multiple versions**, review **each** relevant section above to ensure your project is updated correctly at every step.
- For more details on specific changes (including the rationale or performance impact), see the [CHANGELOG.md](./CHANGELOG.md) file or individual commit messages.