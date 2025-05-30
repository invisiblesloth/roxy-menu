-- Roxy Menu Layout Calculation
-- Calculates sprite and cell dimensions for menu rendering.

local min <const> = math.min
local max <const> = math.max

local RoxyGraphics <const> = roxy.Graphics

local MINIMUM_MENU_WIDTH <const> = 1 -- Minimum starting width to prevent zero-width menus
local MINIMUM_TEXT_WIDTH <const> = 1 -- Minimum starting width to avoid empty text crash

local DISPLAY_WIDTH  <const> = RoxyGraphics.displayWidth
local DISPLAY_HEIGHT <const> = RoxyGraphics.displayHeight

--
-- ! Calculate Menu Dimensions
-- Computes and sets the sprite width, height, and internal cell dimensions.
--
return function(self)
  -- Calculate the height of a single menu item (cell)
  self.cellHeight = self.textHeight + 2 * self.paddingVertical + self.verticalGapBetweenItems

  -- Determine menu width based on widest menu item
  local maxWidth = MINIMUM_MENU_WIDTH
  if not self.propsWidth then
    local widestText = MINIMUM_TEXT_WIDTH
    for _, item in ipairs(self.menuItems) do
      widestText = max(widestText, self.font:getTextWidth(item[3] or ""))
    end
    maxWidth = min(widestText + 2 * (self.paddingHorizontal + self.contentInsetHorizontal), DISPLAY_WIDTH)
  end

  -- Finalize sprite width and height
  self.spriteWidth  = min(self.propsWidth or maxWidth, DISPLAY_WIDTH)
  self.spriteHeight = min(
    self.propsHeight or (self.cellHeight * #self.menuItems + 2 * self.contentInsetVertical),
    DISPLAY_HEIGHT
  )

  -- Calculate internal dimensions for each cell
  self.cellInnerWidth = self.spriteWidth - 2 * (self.paddingHorizontal + self.contentInsetHorizontal)
  self.cellInnerHeight = self.cellHeight - self.verticalGapBetweenItems - 2 * self.paddingVertical
end
