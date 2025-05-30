-- Roxy Menu Input Handler Setup
-- Creates and returns a reusable input handler for menu navigation.

local logError <const> = Log.error --#DEBUG

local pd                <const> = playdate
local abs               <const> = math.abs
local performAfterDelay <const> = pd.timer.performAfterDelay

local DEFAULT_CRANK_ACCUMULATION <const> = 0 -- Crank starting value
local RESET_ACCUMULATOR_VALUE    <const> = 0 -- Reset value for accumulators
local DPAD_INCREMENT_PER_HOLD    <const> = 1 -- Increment per d-pad hold

--
-- ! Initialize Menu Input Handling
-- Validates input timing values, prepares accumulators, and sets up input callbacks.
-- @returns table - The menu input handler table.
--
return function(self)
  if self._inputHandler then return self._inputHandler end

  local crankDirection = self.crankDirection

  if not self.holdDelay or self.holdDelay <= 0 then logError("RoxyMenu: holdDelay must be positive", 2) end --#DEBUG
  if not self.selectionInterval or self.selectionInterval <= 0 then logError("RoxyMenu: selectionInterval must be positive", 2) end --#DEBUG
  if not self.crankThreshold or self.crankThreshold <= 0 then logError("RoxyMenu: crankThreshold must be positive", 2) end --#DEBUG

  -- Initialize accumulators
  self._crankAccumulated = DEFAULT_CRANK_ACCUMULATION
  self._dPadUpAccumulated = RESET_ACCUMULATOR_VALUE
  self._dPadDownAccumulated = RESET_ACCUMULATOR_VALUE

  -- Timer callbacks for hold detection
  local function upTimer()
    self._upHoldActive = true
    self._upKeyTimer = nil -- Clear for reuse
  end
  local function downTimer()
    self._downHoldActive = true
    self._downKeyTimer = nil -- Clear for reuse
  end

  -- Create the menu input handler table
  local handler = {
    -- ! D-Pad Up
    upButtonDown = function()
      self:selectPrevious()
    end,
    upButtonHold = function()
      if not self._upKeyTimer then
        self._upKeyTimer = performAfterDelay(self.holdDelay, upTimer)
      end
      self._dPadUpAccumulated += DPAD_INCREMENT_PER_HOLD
      if self._upHoldActive and self._dPadUpAccumulated > self.selectionInterval then
        self._dPadUpAccumulated = RESET_ACCUMULATOR_VALUE
        self:selectPrevious()
      end
    end,
    upButtonUp = function()
      self._upHoldActive = false
      self._dPadUpAccumulated = RESET_ACCUMULATOR_VALUE
      if self._upKeyTimer then
        self._upKeyTimer:remove()
        self._upKeyTimer = nil
      end
    end,

    -- ! D-Pad Down
    downButtonDown = function()
      self:selectNext()
    end,
    downButtonHold = function()
      if not self._downKeyTimer then
        self._downKeyTimer = performAfterDelay(self.holdDelay, downTimer)
      end
      self._dPadDownAccumulated += DPAD_INCREMENT_PER_HOLD
      if self._downHoldActive and self._dPadDownAccumulated > self.selectionInterval then
        self._dPadDownAccumulated = RESET_ACCUMULATOR_VALUE
        self:selectNext()
      end
    end,
    downButtonUp = function()
      self._downHoldActive = false
      self._dPadDownAccumulated = RESET_ACCUMULATOR_VALUE
      if self._downKeyTimer then
        self._downKeyTimer:remove()
        self._downKeyTimer = nil
      end
    end,

    -- A button
    AButtonDown = function()
      self:click()
    end,

    -- Crank
    cranked = function(change, acceleratedChange)
      local adjustedChange = change * crankDirection
      self._crankAccumulated += adjustedChange
      local absAccumulated = abs(self._crankAccumulated)
      if absAccumulated > self.crankThreshold then
        if self._crankAccumulated > 0 then
          self:selectNext()
        else
          self:selectPrevious()
        end
        self._crankAccumulated = DEFAULT_CRANK_ACCUMULATION
      end
    end,
  }

  if self.dismissible then
    handler.BButtonDown = function()
      self:deactivate()
    end
  end

  self._inputHandler = handler
  return handler
end
