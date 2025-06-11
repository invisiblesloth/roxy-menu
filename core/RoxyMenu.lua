-- RoxyMenu

local logWarn <const> = Log.warn --#DEBUG

-- ---------------------------------- --
-- ! Module & SDK Aliases             --
-- ---------------------------------- --

local pd           <const> = playdate
local Graphics     <const> = pd.graphics
local Gridview     <const> = pd.ui.gridview

local r            <const> = roxy
local Theme        <const> = r.Theme
local Text         <const> = r.Text
local Sounds       <const> = r.Sounds

-- ---------------------------------- --
-- ! Performance-Oriented Aliases     --
-- ---------------------------------- --

-- Lua
local type_             <const> = type

-- Math & table
local max               <const> = math.max
local min               <const> = math.min
local insert            <const> = table.insert
local remove            <const> = table.remove

-- Graphics
local pushContext       <const> = Graphics.pushContext
local popContext        <const> = Graphics.popContext
local setColor          <const> = Graphics.setColor
local getImageDrawMode  <const> = Graphics.getImageDrawMode
local setImageDrawMode  <const> = Graphics.setImageDrawMode
local newImage          <const> = Graphics.image.new
local fillRect          <const> = Graphics.fillRect
local fillRoundRect     <const> = Graphics.fillRoundRect

-- Text
local getFontOffset     <const> = Text.getFontOffset

-- Input
local addHandler    <const> = roxy.Input.addHandler
local removeHandler <const> = roxy.Input.removeHandler

-- Sounds
local loadSound         <const> = Sounds.load
local playSound         <const> = Sounds.play

-- UI
local newRectImage      <const> = roxy.UI.newRectImage
local newTextImage      <const> = roxy.UI.newTextImage

-- ---------------------------------- --
-- ! Constants                        --
-- ---------------------------------- --

-- Graphics modes
local drawModeCopy      <const> = Graphics.kDrawModeCopy

local DISPLAY_HEIGHT    <const> = roxy.Graphics.displayHeight
local CENTER_X          <const> = roxy.Graphics.displayWidthCenter
local CENTER_Y          <const> = roxy.Graphics.displayHeightCenter
local Z_INDEX_DEFAULT   <const> = 1000

local CRANK_THRESHOLD_DEFAULT   <const> = 30
local HOLD_DELAY_MS_DEFAULT     <const> = 1000
local SELECTION_INTERVAL_FRAMES <const> = 2

local DEFAULT_TRUNCATION_STRING        <const> = "…" -- Overflow marker
local DEFAULT_TEXT_HEIGHT              <const> = 20  -- Fallback height
local VERTICAL_GAP_DEFAULT             <const> = 2   -- Menu item gap
local PADDING_HORIZONTAL_DEFAULT       <const> = 4   -- Left/right padding
local PADDING_VERTICAL_DEFAULT         <const> = 2   -- Top/bottom padding
local CONTENT_INSET_HORIZONTAL_DEFAULT <const> = 2   -- Inner left/right inset
local CONTENT_INSET_VERTICAL_DEFAULT   <const> = 2   -- Inner top/bottom inset
local CORNER_RADIUS_DEFAULT            <const> = 4   -- Menu corner radius
local SELECTED_CORNER_RADIUS_DEFAULT   <const> = 4   -- Selection radius

local setupDimensions  <const> = import "libraries/roxy-menu/core/RoxyMenuDimensions"
local setupGridview    <const> = import "libraries/roxy-menu/core/RoxyMenuGridview"
local setupSprite      <const> = import "libraries/roxy-menu/core/RoxyMenuSprite"
local makeInputHandler <const> = import "libraries/roxy-menu/core/RoxyMenuInput"

class("RoxyMenu").extends(RoxySprite)

-- ! Initialize
function RoxyMenu:init(menuItems, props)
  RoxyMenu.super.init(self)

  self:loadProperties(props)
  self.menuItems = menuItems or {}

  loadSound("click")

  local config = r.Configuration.getConfiguration()
  self.crankDirection = config.crankDirection or 1

  self._inputHandler       = props and props.inputHandler or makeInputHandler(self)
  self._inputHandlerPushed = false
  self._crankAccumulated   = 0

  self._upKeyTimer          = nil
  self._downKeyTimer        = nil
  self._upHoldActive        = false
  self._downHoldActive      = false
  self._dPadUpAccumulated   = 0
  self._dPadDownAccumulated = 0

  setupDimensions(self)
  setupGridview(self)
  setupSprite(self)

  self.dismissible = props and props.dismissible or false
  self.modal = (props and props.modal ~= false) -- default true
  self.onDismissCallback = props and props.onDismiss or nil

  self.isActive = props and props.isActive or false
end

--
-- ! Internal Methods
--

-- ! Load Properties
function RoxyMenu:loadProperties(props)
  props = props or {}

  -- Position (center when x/y omitted)
  if props.x == nil and props.y == nil then
    self.menuX = CENTER_X
    self.menuY = CENTER_Y
  else
    self.menuX = props.x or 0
    self.menuY = props.y or 0
    self:setCenter(0, 0)
  end

  -- Dimensions & layering
  self.propsWidth  = props.width
  self.propsHeight = props.height
  self.propsZIndex = props.zIndex or Z_INDEX_DEFAULT

  -- Font & text
  self.font          = props.font            or Text.font
  self.textHeight    = self.font:getHeight() or DEFAULT_TEXT_HEIGHT
  self.textAlignment = props.textAlignment   or Text.ALIGN_LEFT
  self.fontOffset    = props.fontOffset      or getFontOffset(props.font) or 0

  -- Spacing
  self.verticalGapBetweenItems = props.verticalGapBetweenItems
                                 or VERTICAL_GAP_DEFAULT
  self.paddingHorizontal       = props.paddingHorizontal
                                 or PADDING_HORIZONTAL_DEFAULT
  self.paddingVertical         = props.paddingVertical
                                 or PADDING_VERTICAL_DEFAULT
  self.contentInsetHorizontal  = props.contentInsetHorizontal
                                 or CONTENT_INSET_HORIZONTAL_DEFAULT
  self.contentInsetVertical    = props.contentInsetVertical
                                 or CONTENT_INSET_VERTICAL_DEFAULT

  -- Styling
  self.cornerRadius         = props.cornerRadius         or CORNER_RADIUS_DEFAULT
  self.selectedCornerRadius = props.selectedCornerRadius or SELECTED_CORNER_RADIUS_DEFAULT
  self.hasBackground        = props.hasBackground ~= false
  self.hasTransparency      = (self.cornerRadius > 0)    or (not self.hasBackground)
  self.colorScheme          = Theme.getScheme(props.color
                              or props.foreground, props.background)

  -- Behavior
  self.wrapSelection     = (props.wrapSelection == nil) and true or props.wrapSelection
  self.crankThreshold    = props.crankThreshold    or CRANK_THRESHOLD_DEFAULT
  self.holdDelay         = props.holdDelay         or HOLD_DELAY_MS_DEFAULT
  self.selectionInterval = props.selectionInterval or SELECTION_INTERVAL_FRAMES

  self.propsDrawCell = props.drawCell
end

-- ! Refresh Size
function RoxyMenu:refreshSize()
  local newHeight = self.cellHeight * #self.menuItems + 2 * self.contentInsetVertical
  newHeight = min(newHeight, DISPLAY_HEIGHT)
  if newHeight ~= self.spriteHeight then
    self.spriteHeight = newHeight
    self.background = self.hasBackground and newRectImage(
      self.spriteWidth, self.spriteHeight,
      self.colorScheme.normalColor,
      self.cornerRadius
    )
    self:setSize(self.spriteWidth, self.spriteHeight)
  end
end

--
-- ! Public Methods
--

function RoxyMenu:activate(pushHandler, handlerOverride)
  if self.isActive then return self end

  self.isActive = true
  self.listview:setSelectedRow(1)
  self:markDirty()

  if pushHandler ~= false then
    local handlerSpec = handlerOverride or self._inputHandler
    local handler

    if handlerSpec then
      --#DEBUG START
      if type(handlerSpec) ~= "function" and type(handlerSpec) ~= "table" then
        logWarn("RoxyMenu: Invalid inputHandler type (" .. type(handlerSpec) .. "). Expected function or table.")
      end
      --#DEBUG END
      handler = (type(handlerSpec) == "function") and handlerSpec(self) or handlerSpec
      self._inputHandler = handlerSpec
    end

    -- Always try to get a handler, fallback to default if needed
    if not handler then
      handler = makeInputHandler and makeInputHandler(self) or {}
    end

    -- Fill all keys if modal, to fully mask input below
    if self.modal and roxy.Input.makeModalHandler then
      handler = roxy.Input.makeModalHandler(handler)
    end

    if handler then
      addHandler(self, handler, 100)
      self._inputHandlerPushed = true
    else --#DEBUG
      logWarn("RoxyMenu: Failed to construct valid input handler. Skipping input registration.") --#DEBUG
    end
  end

  return self
end

-- ! Deactivate
function RoxyMenu:deactivate()
  if self._inputHandlerPushed then
    removeHandler(self)
    self._inputHandlerPushed = false
  else --#DEBUG
    logWarn("RoxyMenu: attempted to remove input handler, but it wasn't registered.") --#DEBUG
  end

  self.isActive = false
  self.listview:setSelectedRow(0)
  self:remove()
  self:markDirty()

  if self.onDismissCallback then
    self.onDismissCallback()
  end

  return self
end

-- ! Get `isActive`
function RoxyMenu:getIsActive()
  return self.isActive
end

-- ! Add Item
function RoxyMenu:addItem(itemName, callback, displayName, placement)
  -- Determine insertion index (clamped to [1, #menuItems+1])
  local insertIndex = placement
    and max(1, min(placement, #self.menuItems + 1))
    or #self.menuItems + 1

  -- Create and insert the data model
  local newItem = { itemName, callback, displayName }
  insert(self.menuItems, insertIndex, newItem)

  -- Pre-render the cell image and insert it
  local newImage = newTextImage(
    newItem[3],
    self.font,
    self.cellInnerWidth, self.cellInnerHeight,
    self.colorScheme.invertedColor,
    self.fontOffset,
    DEFAULT_TRUNCATION_STRING,
    self.textAlignment
  )
  insert(self.cellImages, insertIndex, newImage)

  -- Refresh the gridview’s row count and adjust selection
  self.listview:setNumberOfRows(#self.menuItems)
  local currentSelected = self.listview:getSelectedRow()
  if currentSelected > 0 and insertIndex <= currentSelected then
    self.listview:setSelectedRow(currentSelected + 1)
  end

  -- Resize and redraw
  self:refreshSize()
  self:markDirty()

  return self
end

-- ! Remove Item
function RoxyMenu:removeItem(menuItem)
  local removeIndex
  if type(menuItem) == "number" then
    if menuItem < 1 or menuItem > #self.menuItems then
      return self
    end
    removeIndex = menuItem
  elseif type(menuItem) == "string" then
    for i, item in ipairs(self.menuItems) do
      if item[1] == menuItem then
        removeIndex = i break
      end
    end
    if not removeIndex then
      return self
    end
  else
    logWarn("`menuItem` must be a number or string.") --#DEBUG
    return self
  end

  remove(self.menuItems, removeIndex)
  remove(self.cellImages, removeIndex)
  self.listview:setNumberOfRows(#self.menuItems)

  local currentSelected = self.listview:getSelectedRow()
  if currentSelected > 0 then
    if removeIndex < currentSelected then
      self.listview:setSelectedRow(currentSelected - 1)
    elseif removeIndex == currentSelected then
      local newSelected = removeIndex - 1
      if newSelected < 1 and #self.menuItems > 0 then
        newSelected = 1
      end
      self.listview:setSelectedRow(newSelected)
    end
  end

  self:refreshSize()
  self:markDirty()
  return self
end

-- ! Select
function RoxyMenu:select(menuItem, ignoreActiveStatus)
  if not (ignoreActiveStatus or self.isActive) then return self end
  local row
  if type(menuItem) == "number" then
    if menuItem < 1 or menuItem > #self.menuItems then
      return self
    end
    row = menuItem
  elseif type(menuItem) == "string" then
    for i, item in ipairs(self.menuItems) do
      if item[1] == menuItem then
        row = i
        break
      end
    end
    if not row then
      return self
    end
  else
    logWarn("`menuItem` must be a number or string.") --#DEBUG
    return self
  end
  self.listview:setSelectedRow(row)
  self:markDirty()
  return self
end

-- ! Select Next
function RoxyMenu:selectNext(wrapSelection, ignoreActiveStatus)
  if not (ignoreActiveStatus or self.isActive) then return self end
  wrapSelection = (wrapSelection == nil) and self.wrapSelection or wrapSelection
  self.listview:selectNextRow(wrapSelection)
  return self
end

-- ! Select Previous
function RoxyMenu:selectPrevious(wrapSelection, ignoreActiveStatus)
  if not (ignoreActiveStatus or self.isActive) then return self end
  wrapSelection = (wrapSelection == nil) and self.wrapSelection or wrapSelection
  self.listview:selectPreviousRow(wrapSelection)
  return self
end

-- ! Get Selected Item
function RoxyMenu:getSelectedItem()
  local row = self.listview:getSelectedRow()
  if row and row >= 1 and row <= #self.menuItems then
    return self.menuItems[row]
  end
  return nil
end


-- ! Click
function RoxyMenu:click(ignoreActiveStatus)
  if not (ignoreActiveStatus or self.isActive) then return end

  playSound("click")

  local row = self.listview:getSelectedRow()
  local item = self.menuItems[row]

  if item and item[2] then
    item[2]()
  end
end

-- ! Update
function RoxyMenu:update()
  RoxyMenu.super.update(self)
  if self.listview.needsDisplay and self.isActive then
    self:markDirty()
  end
end

-- ! Draw
function RoxyMenu:draw(x, y, width, height)
  if #self.menuItems <= 0 then return end
  if self.hasBackground then self.background:draw(x, y) end
  self.listview:drawInRect(x, y, width, height)
end
