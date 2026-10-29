-- Forever RP v0.9: optional, overridable classification of usable consumables.
-- This classification only changes suggested text; it NEVER triggers emotes by itself.
local A = ForeverRP
A.categoryOrder = {'healthstone','potion','drink','alcohol','food','bufffood','elixir','bandage','hearthstone','other'}
A.categoryNames = {
  healthstone='Healthstone', potion='Potion', drink='Drink', food='Food',
  alcohol='Alcohol (optional RP)', bufffood='Buff food', elixir='Elixir / Flask', bandage='Bandage', hearthstone='Hearthstone / Teleport', other='Other consumable'
}

local function contains(s,part)
  return type(s)=='string' and s:lower():find(part,1,true) ~= nil
end

-- C_TooltipInfo may be unavailable, uncached or secret in combat. Ignore unsafe
-- fields and never make combat actions based on tooltip values.
local function tooltipText(bag,slot)
  if InCombatLockdown and InCombatLockdown() then return nil end
  if not (C_TooltipInfo and C_TooltipInfo.GetBagItem) then return nil end
  -- Both retrieval AND inspection are guarded: newer clients can return
  -- secret-marked tooltip fields even when GetBagItem itself succeeds.
  local ok,result=pcall(function()
    local data=C_TooltipInfo.GetBagItem(bag,slot)
    if type(issecretvalue)=='function' and issecretvalue(data) then return nil end
    if type(data)~='table' or type(data.lines)~='table' then return nil end
    if type(issecretvalue)=='function' and issecretvalue(data.lines) then return nil end
    local strings={}
    for _,line in ipairs(data.lines) do
      if type(issecretvalue)~='function' or not issecretvalue(line) then
        if type(line)=='table' then
          local left,right=line.leftText,line.rightText
          if type(left)=='string' and not (type(issecretvalue)=='function' and issecretvalue(left)) then
            strings[#strings+1]=left:lower()
          end
          if type(right)=='string' and not (type(issecretvalue)=='function' and issecretvalue(right)) then
            strings[#strings+1]=right:lower()
          end
        end
      end
    end
    return table.concat(strings,' ')
  end)
  return ok and result or nil
end

local function detectFoodBuff(t)
  if not t then return false end
  return contains(t,'well fed') or contains(t,'well-fed')
    or contains(t,'gut genährt') or contains(t,'satt und')
    or contains(t,'become well fed') or contains(t,'becomes well fed')
end

-- Returns a suggested category plus a description of what was reliable.
function A:DetectCategory(meta,bag,slot)
  local id=meta.id
  local name=(meta.name or ''):lower()
  local spellName=(meta.spellName or ''):lower()
  local subclass=meta.subclassID
  local t=nil

  if id==6948 then return 'hearthstone','known Hearthstone item' end
  -- Subclass IDs based on retail ItemConsumableSubclass. Do NOT assume they
  -- map identically on Classic. Forever client will need a separate smoke test.
  if contains(name,'healthstone') or contains(name,'gesundheitsstein')
       or contains(spellName,'healthstone') or contains(spellName,'gesundheitsstein')
       or id==5512 then
    return 'healthstone','item name / use spell'
  end
  if subclass==1 then return 'potion','item subclass' end
  if subclass==2 or subclass==3 then return 'elixir','item subclass' end
  if subclass==7 then return 'bandage','item subclass' end
  if subclass==5 then
    t=tooltipText(bag,slot)
    -- Heuristic only: WoW drunkenness emotes are separate game messages.
    -- New items remain OFF; players can override the category manually.
    if contains(t,'alcoholic') or contains(t,'intoxicat') or contains(t,'betrunken')
      or contains(t,'makes you drunk') or contains(t,'get drunk')
      or contains(name,'beer') or contains(name,'ale ') or contains(name,' stout')
      or contains(name,'wine') or contains(name,'whiskey') or contains(name,'whisky')
      or contains(name,'bourbon') or contains(name,'mead') or contains(name,'rum ')
      or contains(name,'bier') or contains(name,'wein') or contains(name,'met ')
      or contains(name,'schnaps') then
      return 'alcohol','name / tooltip (heuristic)'
    end
    if detectFoodBuff(t) then return 'bufffood','tooltip (heuristic)' end
    if contains(spellName,'drink') or contains(spellName,'trinken') then
      return 'drink','use spell'
    end
    if contains(spellName,'eat') or contains(spellName,'essen') then
      return 'food','use spell'
    end
    if t then
      local restoreMana=contains(t,'mana') or contains(t,'manapunkte')
      local restoreHealth=contains(t,'health') or contains(t,'gesundheit')
      if restoreMana and not restoreHealth then return 'drink','tooltip (heuristic)' end
      if restoreHealth and not restoreMana then return 'food','tooltip (heuristic)' end
    end
    return 'food','food & drink subclass (uncertain)'
  end
  return 'other','fallback'
end

function A:GetCategory(id)
  local cfg=self:GetSettings(id)
  if cfg and self.categoryNames[cfg.categoryOverride] then
    return cfg.categoryOverride,'manual'
  end
  if cfg and self.categoryNames[cfg.autoCategory] then
    return cfg.autoCategory,cfg.categoryMethod or 'auto'
  end
  return 'other','not yet identified'
end

function A:NextCategory(id,direction)
  local cfg=self:GetSettings(id)
  if not cfg then return nil end
  local current=self:GetCategory(id)
  local idx=1
  for i,k in ipairs(self.categoryOrder) do if k==current then idx=i break end end
  local nextIndex=(idx-1+(direction or 1))%#self.categoryOrder+1
  cfg.categoryOverride=self.categoryOrder[nextIndex]
  return cfg.categoryOverride
end
