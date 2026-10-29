-- Forever RP v0.9.2b | Dual-client codebase. No protected actions, no combat automation.
ForeverRP = ForeverRP or {}
local A = ForeverRP
A.version = '0.9.17-retail-beta'
A.db = nil
A.inventory = {}
A.spellToItems = {}
A.last = {result='not_tested', itemID=nil, spellID=nil, echo='none'}
A.activeConfig = nil
A.debugEnabled = false

function A:Say(message)
  print('|cffb69adaForever RP:|r ' .. tostring(message))
end
function A:Debug(message)
  if self.db and self.db.debug then self:Say('[DEBUG] ' .. tostring(message)) end
end
function A:Now() return GetTime() end
function A:GetSettings(itemID)
  if not self.db then return nil end
  return self.db.items[itemID]
end
function A:Remember(id, meta)
  if not self.db then return end
  local item = self.db.items[id]
  if not item then
    item = {enabled=false, lines={}, name=meta.name or ('Item ' .. id)}
    self.db.items[id] = item
  end
  if meta.name then item.name=meta.name end
  -- Never overwrite a player-selected category on a fresh bag scan.
  if self.categoryNames and meta.autoCategory and self.categoryNames[meta.autoCategory] then
    item.autoCategory=meta.autoCategory
    item.categoryMethod=meta.categoryMethod or 'auto'
  end
end
function A:Init()
  if type(ForeverRPDB)~='table' then ForeverRPDB={} end
  self.db=ForeverRPDB
  if type(self.db.items)~='table' then self.db.items={} end
  if self.db.auto==nil then self.db.auto=true end
  if self.db.debug==nil then self.db.debug=false end
  if self.db.showMinimap==nil then self.db.showMinimap=true end
  if type(self.db.minimapAngle)~='number' then self.db.minimapAngle=220 end
  if type(self.db.hearthLastAnnounceAt)~='number' then self.db.hearthLastAnnounceAt=0 end
  -- Shared anti-spam window across all RP types, persisted across /reload.
  if type(self.db.globalCooldown)~='number' then self.db.globalCooldown=30 end
  if type(self.db.globalLastEmoteAt)~='number' then self.db.globalLastEmoteAt=0 end
  -- English-only UI/output for v0.9.7; old German phrases remain stored but dormant.
  self.db.language='en'
  if self.db.defaultScope==nil then self.db.defaultScope='group' end
  if not self.ValidScopes[self.db.defaultScope] then self.db.defaultScope='group' end
  self:ResetInventory()
  -- Last Item defaults ON for already enabled consumables, unless previously
  -- explicitly opted out. Hearthstone never needs a last-item notification.
  for id,cfg in pairs(self.db.items) do
    if id==6948 then
      cfg.outOfStockEnabled=false
    elseif cfg.enabled and cfg.outOfStockEnabled==nil then
      cfg.outOfStockEnabled=true
    end
    if cfg.enabled and cfg.outOfStockEnabled and self.SeedLastItemPhrases then
      self:SeedLastItemPhrases(id,cfg)
    end
  end
  if self.SetupMinimap then self:SetupMinimap() end
  self:Say('v' .. self.version .. ' loaded. /frp config opens the editor. New items are OFF by default.')
end
function A:PrintStatus()
  local l=self.last
  self:Say('Auto: ' .. (self.db.auto and 'ON' or 'OFF') .. ' | Scope: '..tostring(self.db.defaultScope)..' | Last item: '
    .. tostring(l.itemID or 'none') .. ' | Spell: ' .. tostring(l.spellID or '-')
    .. ' | Result: ' .. tostring(l.result) .. ' | Own echo: ' .. tostring(l.echo)
    .. ' | Language: '..tostring(self.db.language)..' | Mode: '..tostring(l.channel or '-')
    .. ' | Trigger: '..tostring(l.trigger or '-')
    .. ' | RP cooldown: '..tostring(self.db.globalCooldown or 30)..'s'
    .. ' | Last stock: '..tostring(l.stock or 'normal'))
  if self.hearthCast then
    self:Say('Hearthstone: '..tostring(self.hearthCast.state)..' | elapsed='..math.floor(self:Now()-(self.hearthCast.at or 0))..'s')
  end
end
function A:Slash(text)
  local command=(text or ''):lower():match('^%s*(.-)%s*$')
  if command=='' or command=='config' then
    self:ShowConfig()
  elseif command=='scan' then
    self:ResetInventory()
    self:Say('Bag scan complete. ' .. self:InventorySummary() .. '. /frp config for items.')
    self:RefreshConfig()
  elseif command=='status' then
    self:PrintStatus()
  elseif command=='compat' then
    self:PrintCompat()
  elseif command=='auto on' or command=='auto off' then
    self.db.auto=(command=='auto on')
    self:Say('Automatic RP emotes ' .. (self.db.auto and 'enabled' or 'disabled'))
    self:RefreshConfig()
  elseif command=='debug on' or command=='debug off' then
    self.db.debug=(command=='debug on')
    self:Say('Debug ' .. (self.db.debug and 'enabled' or 'disabled'))
  elseif command:match('^scope%s+') then
    local scope=command:match('^scope%s+(.+)$')
    if self.ValidScopes[scope] then
      self.db.defaultScope=scope
      self:Say('Default emote scope: '..self.ScopeNames[scope])
      self:RefreshConfig()
    else
      self:Say('Scope options: always, group, instance, off')
    end
  elseif command:match('^cooldown%s+%d+$') then
    local seconds=tonumber(command:match('^cooldown%s+(%d+)$'))
    if seconds==0 or seconds==15 or seconds==30 or seconds==60 or seconds==120 then
      self.db.globalCooldown=seconds
      self:Say('Shared RP cooldown set to '..seconds..'s')
      self:RefreshConfig()
    else self:Say('Allowed cooldowns: 0, 15, 30, 60, 120 seconds.') end
  elseif command=='minimap on' or command=='minimap off' then
    self.db.showMinimap=(command=='minimap on')
    if self.UpdateMinimapVisibility then self:UpdateMinimapVisibility() end
    if self.minimapCheck then self.minimapCheck:SetChecked(self.db.showMinimap) end
    self:Say('Minimap button '..(self.db.showMinimap and 'shown' or 'hidden'))
  elseif command=='preview' then
    self:Say(self.last.text or 'No confirmed consumption yet.')
  else
    self:Say('Commands: /frp config | scan | status | minimap on/off | compat | preview | auto on/off | scope always/group/instance/off | cooldown 0/15/30/60/120 | debug on/off')
  end
end
SLASH_FOREVERRP1='/frp'
SLASH_FOREVERRP2='/hsrp'
SlashCmdList.FOREVERRP=function(s) A:Slash(s) end

-- Standard WoW add-on compartment entry by the minimap (optional on client).
-- A manual click merely opens the editor; it never uses an item or sends emotes.
function ForeverRP_OnAddonCompartmentClick(addonName, buttonName)
  if not A.db then return end
  if A.configFrame and A.configFrame:IsShown() then
    A.configFrame:Hide()
  else
    A:ShowConfig()
  end
end


A.eventFrame=CreateFrame('Frame')
A.eventFrame:RegisterEvent('PLAYER_LOGIN')
A.eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
A.eventFrame:RegisterEvent('BAG_UPDATE_DELAYED')
A.eventFrame:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED','player')
A.eventFrame:RegisterUnitEvent('UNIT_SPELLCAST_START','player')
A.eventFrame:RegisterUnitEvent('UNIT_SPELLCAST_FAILED','player')
A.eventFrame:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED','player')
A.eventFrame:RegisterEvent('CHAT_MSG_EMOTE')
A.eventFrame:RegisterEvent('CHAT_MSG_SAY')
A.eventFrame:SetScript('OnEvent',function(_,event,...)
  if event=='PLAYER_LOGIN' then A:Init()
  elseif event=='PLAYER_ENTERING_WORLD' then
    if A.db then
      A:ResetInventory()
      -- No post-teleport emote: departure announcements happen at cast start.
    end
  elseif event=='BAG_UPDATE_DELAYED' then
    if A.db then A:OnBagsChanged() end
  elseif event=='UNIT_SPELLCAST_START' then
    local unit,castGUID,spellID=...
    if unit=='player' and A.db then A:OnCastStart(castGUID,spellID) end
  elseif event=='UNIT_SPELLCAST_FAILED' or event=='UNIT_SPELLCAST_INTERRUPTED' then
    local unit,castGUID,spellID=...
    if unit=='player' and A.db then A:OnCastInterrupted(castGUID,spellID,event) end
  elseif event=='UNIT_SPELLCAST_SUCCEEDED' then
    local unit, castGUID, spellID=...
    if unit=='player' and A.db then A:OnSpellSucceeded(castGUID,spellID) end
  elseif event=='CHAT_MSG_EMOTE' or event=='CHAT_MSG_SAY' then
    if A.db then A:OnChatEcho(event,...) end
  end
end)
