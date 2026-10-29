-- Forever RP v0.9.2: manual group context scopes. No gameplay automation.
local A=ForeverRP
A.ScopeOrder={'always','group','instance','off'}
A.ScopeNames={always='Everywhere',group='Only in groups',instance='Dungeon / Raid only',off='Disabled'}
A.ValidScopes={always=true,group=true,instance=true,off=true}
function A:GetEffectiveScope(itemID)
  local cfg=self:GetSettings(itemID)
  if cfg and self.ValidScopes[cfg.scopeOverride] then return cfg.scopeOverride end
  local global=self.db and self.db.defaultScope or 'group'
  return self.ValidScopes[global] and global or 'group'
end
function A:CanSendInContext(itemID)
  local scope=self:GetEffectiveScope(itemID)
  if scope=='off' then return false,'disabled_by_scope' end
  if scope=='always' then return true end
  local inGroup=(type(IsInGroup)=='function' and IsInGroup()) or (type(IsInRaid)=='function' and IsInRaid())
  if scope=='group' then return not not inGroup, 'not_in_group' end
  if scope=='instance' then
    local inInstance,kind=false,nil
    if type(IsInInstance)=='function' then inInstance,kind=IsInInstance() end
    if inGroup and inInstance and (kind=='party' or kind=='raid') then return true end
    return false,'not_in_group_dungeon_or_raid'
  end
  return false,'invalid_scope'
end
