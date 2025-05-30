-- Roxy Menu Sprite Setup
-- Initializes the menu sprite with a background image and configures its size, opacity, Z-index, and position.

local newRectImage <const> = roxy.UI.newRectImage

local DEFAULT_Z_INDEX <const> = 1000 -- Default Z-index for menu sprite

--
-- ! Initialize Menu Sprite
-- Validates properties and sets up the sprite appearance and position.
-- @returns nil
--
return function(self)
  -- Create background image if enabled
  if self.hasBackground then
    self.background = newRectImage(
      self.spriteWidth,
      self.spriteHeight,
      self.colorScheme.normalColor,
      self.cornerRadius
    )
  end

  -- Configure sprite properties
  self:setSize(self.spriteWidth, self.spriteHeight)
  self:setOpaque(self.hasBackground and self.cornerRadius <= 0) -- Opaque only for non-rounded backgrounds
  self:setZIndex(self.propsZIndex or DEFAULT_Z_INDEX)
  self:moveTo(self.menuX, self.menuY)
end
