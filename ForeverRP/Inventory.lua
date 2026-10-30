local A=ForeverRP
A.removals={} -- [itemID]={at,delta} from recent bag updates
A.pending={}  -- pending successful spell casts for a short time, not chat messages
A.lastCastGUID=nil
A.lastCastSpell=nil
A.lastCastAt=0
A.lastConfirmedAt=0
A.lastConfirmedID=nil
local BAG_LAST = 5 -- Retail: includes the reagent bag; skips bank/warbank

local function itemSpell(id)
  if C_Item and C_Item.GetItemSpell then
    local name,spell=C_Item.GetItemSpell(id)
    return type(spell)=='number' and spell or nil, name
  end
end
local function isConsumable(id)
  if not (C_Item and C_Item.GetItemInfoInstant) then return false end
  local _,_,_,_,_,classID=C_Item.GetItemInfoInstant(id)
  return classID == (Enum and Enum.ItemClass and Enum.ItemClass.Consumable or 0)
end
function A:ScanBags()
  if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then
    self.last.result='bag_api_unavailable'
    return nil,nil
  end
  local found,spells={},{}
  for bag=0,BAG_LAST do
    for slot=1,(C_Container.GetContainerNumSlots(bag) or 0) do
      local info=C_Container.GetContainerItemInfo(bag,slot)
      if info and type(info.itemID)=='number' then
        local id=info.itemID
        if type(info.stackCount)~='number' or info.stackCount<1 then return nil,nil end
        if isConsumable(id) or id==6948 or self.inventory[id] then
          local spell,spellName=itemSpell(id)
          local previous=self.inventory[id]
          -- Metadata cache misses cannot erase a known use-spell candidate.
          spell=spell or (previous and previous.spell)
          spellName=spellName or (previous and previous.spellName)
          do
            local meta=found[id]
            if not meta then
              meta={id=id,reusable=(id==6948),name=info.itemName or ('Item ' .. id),link=info.hyperlink,
                    icon=info.iconFileID, count=0,spell=spell,spellName=spellName}
              local _,_,_,_,_,_,subclassID=C_Item.GetItemInfoInstant(id)
              meta.subclassID=subclassID
              local category,method=self:DetectCategory(meta,bag,slot)
              -- Retain earlier positive tooltip classification when a scan
              -- during combat cannot safely read tooltip data.
              local cfg=self:GetSettings(id)
              if cfg and cfg.autoCategory=='bufffood' and category=='food' and InCombatLockdown and InCombatLockdown() then
                category,method='bufffood',cfg.categoryMethod
              end
              meta.autoCategory=category
              meta.categoryMethod=method
              found[id]=meta
            end
            meta.count=meta.count+(info.stackCount or 1)
            if spell then
              if not spells[spell] then spells[spell]={} end
              spells[spell][id]=true
            end
            self:Remember(id,meta)
          end
        end
      end
    end
  end
  return found,spells
end
function A:InventorySummary()
  local all,enabled=0,0
  for id,meta in pairs(self.inventory) do
    all=all+1
    local cfg=self:GetSettings(id)
    if cfg and cfg.enabled then enabled=enabled+1 end
  end
  return all .. ' usable consumables found, ' .. enabled .. ' enabled'
end
function A:ResetInventory()
  self.removals={}
  self.pending={}
  local inventory,spells=self:ScanBags()
  if inventory then
    self.inventory=inventory
    self.spellToItems=spells
  end
end

-- We keep a 3-second window for event ordering, but NEVER announce solely
-- because an item moved out of the bags. The matching spell-success is required.
local WINDOW=3.0
local function within(now,at) return at and now-at>=0 and now-at<=WINDOW end

function A:OnBagsChanged()
  local current,spells=self:ScanBags()
  if not current then return end
  local old=self.inventory
  local now=self:Now()
  local changes={}
  for id,prev in pairs(old) do
    local newCount=current[id] and current[id].count or 0
    if newCount>prev.count then self.removals[id]=nil end
    if newCount<prev.count and prev.spell then
      changes[id]=(prev.count-newCount)
      local remove=self.removals[id]
      if within(now,remove and remove.at) then
        remove.delta=remove.delta+changes[id]
      else
        self.removals[id]={at=now,delta=changes[id],link=prev.link,spell=prev.spell}
      end
    end
  end
  self.inventory=current
  self.spellToItems=spells
  self:MatchPending()
  if self.configFrame and self.configFrame:IsShown() then self:RefreshConfig() end
end
function A:MatchPending()
  local now=self:Now()
  for n=#self.pending,1,-1 do
    local p=self.pending[n]
    if not within(now,p.at) then
      table.remove(self.pending,n)
    else
      local matchID,matchCount=nil,0
      for id in pairs(p.candidates) do
        local removal=self.removals[id]
        if removal and within(now,removal.at) and removal.spell==p.spell and removal.delta>0 then
          matchID=id
          matchCount=matchCount+1
        end
      end
      if matchCount>1 then
        self.last.result='ambiguous_items_same_spell_no_send'
        self:Debug('Ambiguous item use: multiple items share use spell and changed quantity.')
        table.remove(self.pending,n)
      elseif matchCount==1 then
        local removed=self.removals[matchID]
        removed.delta=removed.delta-1
        if removed.delta<=0 then self.removals[matchID]=nil end
        table.remove(self.pending,n)
        -- Captured AFTER the verified bag decrement; never infer stock from
        -- unrelated inventory changes. All equipped bags and stacks are counted.
        local remaining=self.inventory[matchID] and self.inventory[matchID].count or 0
        self:ConfirmedUse(matchID,removed.link,p.spell,remaining)
        return
      end
    end
  end
end
-- Hearthstone is reusable. Tell the current group when the cast STARTS,
-- never after the loading screen. This describes an attempted departure,
-- NOT a successful teleport. Interruptions cannot retract the message.
-- Persist a wall-clock throttle so /reload cannot reset anti-spam.
local HEARTH_THROTTLE=120
local function isHearthSpell(self,spell)
  local meta=self.inventory and self.inventory[6948]
  return meta and meta.reusable and type(spell)=='number'
    and (spell==meta.spell or spell==8690)
end
local function wallSeconds(self)
  if type(time)=='function' then return time() end
  return math.floor(self:Now())
end
function A:OnCastStart(guid,spell)
  if not self:SafeCastValues(guid,spell) then return end
  if not isHearthSpell(self,spell) then return end
  if self.hearthCast and guid and self.hearthCast.guid==guid then return end
  local current=wallSeconds(self)
  local last=self.db.hearthLastAnnounceAt or 0
  local remaining=HEARTH_THROTTLE-(current-last)
  self.hearthCast={guid=guid,spell=spell,at=self:Now(),state='cast_started'}
  self.last.trigger='hearthstone_cast_start_unverified'
  if remaining>0 then
    self.last.result='hearthstone_cast_start_throttled_'..math.ceil(remaining)..'s'
    self.hearthCast.state='throttled'
    self:Debug('Hearthstone RP suppressed for '..math.ceil(remaining)..' more seconds.')
    return
  end
  local cfg=self:GetSettings(6948)
  if not self.db.auto or not cfg or not cfg.enabled then
    self.last.result='hearthstone_cast_start_disabled'
    return
  end
  -- Do not consume the throttle when context/phrases already prohibit output.
  local permitted=self:CanSendInContext(6948)
  if not permitted or #self:GetAvailableChannels(cfg,self.db.language)==0 then
    self.last.result='hearthstone_cast_start_no_eligible_context_or_lines'
    return
  end
  local link=self.inventory[6948].link
  if type(link)~='string' or not link:find('|Hitem:',1,true) then
    self.last.result='hearthstone_missing_item_link'
    return
  end
  self.last.itemID=6948
  self.last.spellID=spell
  if self:SendForItem(6948,link,false) then
    self.db.hearthLastAnnounceAt=current
    self.hearthCast.state='announcement_attempted'
    self:Debug('Hearthstone cast START announcement attempted; a cancel cannot undo chat.')
  else
    self.hearthCast.state='not_announced'
  end
end
function A:OnCastInterrupted(guid,spell,event)
  if not self:SafeCastValues(guid,spell) then return end
  local p=self.hearthCast
  if p and p.spell==spell and (not p.guid or not guid or p.guid==guid) then
    if p.state=='announcement_attempted' then
      self.last.result='hearthstone_interrupted_after_cast_start_message'
      self:Debug('Hearthstone interrupted AFTER start; anti-spam throttle stays active.')
    else
      self.last.result='hearthstone_interrupted_no_new_message'
    end
    self.hearthCast=nil
  end
end
function A:CheckHearthstoneArrival(source)
  -- Intentionally disabled: RP after arrival would be seen by the wrong people.
  return
end
function A:OnSpellSucceeded(guid,spell)
  if not self:SafeCastValues(guid,spell) then return end
  if type(spell)~='number' then return end
  local now=self:Now()
  if guid and guid==self.lastCastGUID then return end
  if spell==self.lastCastSpell and within(now,self.lastCastAt) and now-self.lastCastAt<0.75 then return end
  -- The item can have disappeared entirely: use previous inventory's removals.
  local candidates={}
  if self.spellToItems[spell] then
    for id in pairs(self.spellToItems[spell]) do candidates[id]=true end
  end
  for id,rem in pairs(self.removals) do
    if rem.spell==spell and within(now,rem.at) then candidates[id]=true end
  end
  if not next(candidates) then return end
  local candidateCount=0
  for _ in pairs(candidates) do candidateCount=candidateCount+1 end
  if candidateCount>1 then
    self.last.result='ambiguous_items_same_spell_no_send'
    return
  end
  -- Hearthstone output, if any, already happened at cast start.
  -- Never duplicate it after successful completion/loading screens.
  if isHearthSpell(self,spell) then
    if self.hearthCast then self.hearthCast.state='cast_completed' end
    return
  end
  self.lastCastGUID=guid
  self.lastCastSpell=spell
  self.lastCastAt=now
  table.insert(self.pending,{spell=spell,candidates=candidates,at=now})
  self.last.spellID=spell
  self.last.result='waiting_for_item_decrement'
  self:MatchPending()
  if C_Timer and C_Timer.After then
    C_Timer.After(WINDOW+0.2,function()
      A:MatchPending()
      if A.last.result=='waiting_for_item_decrement' then
        A.last.result='spell_succeeded_but_no_item_decrement_no_send'
      end
    end)
  end
end
function A:ConfirmedUse(id,link,spell,remaining)
  local now=self:Now()
  if self.lastConfirmedID==id and now-self.lastConfirmedAt<0.8 then return end
  self.lastConfirmedID=id
  self.lastConfirmedAt=now
  self.last.itemID=id
  self.last.spellID=spell
  self.last.result='confirmed_item_consumed'
  local cfg=self:GetSettings(id)
  local isOut=cfg and cfg.outOfStockEnabled and remaining==0 and id~=6948
  self.last.stock=isOut and 'out_of_stock' or 'normal'
  -- Last-item emote REPLACES the usual emote; only one send path exists.
  self:SendForItem(id,link,isOut)
end
