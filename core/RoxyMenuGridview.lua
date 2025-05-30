-- Menu Rendering Setup
-- Prepares cell images, background selection visuals, and configures the gridview for menu layout.

local logWarn <const> = Log.warn --#DEBUG

local pd               <const> = playdate
local Gridview         <const> = pd.ui.gridview
local getImageDrawMode <const> = pd.graphics.getImageDrawMode
local setImageDrawMode <const> = pd.graphics.setImageDrawMode
local drawModeCopy     <const> = pd.graphics.kDrawModeCopy
local newRectImage     <const> = roxy.UI.newRectImage
local newTextImage     <const> = roxy.UI.newTextImage

local DEFAULT_TRUNCATION_STRING     <const> = "…"
local GRIDVIEW_INITIAL_X            <const> = 0
local GRIDVIEW_INITIAL_SELECTED_ROW <const> = 0 -- Default selection before interaction
local GRIDVIEW_CELL_PADDING         <const> = 0 -- No cell padding initially
local GRIDVIEW_SINGLE_COLUMN        <const> = 1 -- Roxy menus are single column

--
-- ! Initialize Gridview and Cells
-- Sets up the gridview and pre-renders menu item text and selection backgrounds.
--
return function(self)
  -- Create pre-rendered text images for each menu item
  self.cellImages = {}
  for i, item in ipairs(self.menuItems) do
    self.cellImages[i] = newTextImage(
      item[3], -- Menu item label
      self.font,
      self.cellInnerWidth, self.cellInnerHeight,
      self.colorScheme.invertedFill,
      self.fontOffset,
      DEFAULT_TRUNCATION_STRING,
      self.textAlignment
    )
  end

  -- Pre-render the background image for selected menu items
  self.selectedBgImage = newRectImage(
    self.spriteWidth - 2 * self.contentInsetHorizontal,
    self.cellHeight - self.verticalGapBetweenItems,
    self.colorScheme.invertedColor,
    self.selectedCornerRadius
  )

  -- Initialize the gridview
  self.listview = Gridview.new(GRIDVIEW_INITIAL_X, self.cellHeight)
  self.listview:setNumberOfColumns(GRIDVIEW_SINGLE_COLUMN)
  self.listview:setNumberOfRows(#self.menuItems)
  self.listview:setCellPadding(
    GRIDVIEW_CELL_PADDING,
    GRIDVIEW_CELL_PADDING,
    GRIDVIEW_CELL_PADDING,
    GRIDVIEW_CELL_PADDING
  )
  self.listview:setContentInset(
    self.contentInsetHorizontal,
    self.contentInsetHorizontal,
    self.contentInsetVertical,
    self.contentInsetVertical
  )
  self.listview:setSelectedRow(GRIDVIEW_INITIAL_SELECTED_ROW)

  -- Pass additional properties to the listview instance
  self.listview.fillcolor               = self.colorScheme.normalFill
  self.listview.paddingHorizontal       = self.paddingHorizontal
  self.listview.paddingVertical         = self.paddingVertical
  self.listview.cellImages              = self.cellImages
  self.listview.verticalGapBetweenItems = self.verticalGapBetweenItems
  self.listview.selectedBgImage         = self.selectedBgImage

  --
  -- ! listview.drawCell
  -- Draws a gridview cell, highlighting selection and rendering the menu item text.
  -- @param self table - The gridview instance.
  -- @param section number - Gridview section (unused, always 1 in Roxy menus).
  -- @param row number - Row index to render.
  -- @param column number - Column index (unused, always 1).
  -- @param selected boolean - Whether this cell is selected.
  -- @param x number - X coordinate to draw at.
  -- @param y number - Y coordinate to draw at.
  -- @param width number - Width of the cell (unused, controlled elsewhere).
  -- @param height number - Height of the cell (unused, controlled elsewhere).
  --
  self.listview.drawCell = self.propsDrawCell or function(self, section, row, column, selected, x, y, width, height)
    if row > #self.cellImages then
      logWarn(string.format("RoxyMenu: Attempted to draw missing row %d (only %d cell images exist)", row, #self.cellImages)) --#DEBUG
      return
    end

    local prevMode = getImageDrawMode()

    if selected then
      self.selectedBgImage:draw(x, y)
      setImageDrawMode(self.fillcolor)
    end
    self.cellImages[row]:draw(x + self.paddingHorizontal, y + self.paddingVertical)

    setImageDrawMode(prevMode)
  end
end
