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
function A:CanSendLegacyInContext(itemID)
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

-- Active group-only policy. Legacy scope fields above remain untouched.
A.GroupScopeOrder={'groups','dungeons','raids','disabled'}
A.GroupScopeNames={groups='Groups (all)',dungeons='Dungeons',raids='Raids',disabled='Disabled'}
function A:InitGroupSettings()
  local db=self.db
  if type(db.invalidSavedValues)~='table' then db.invalidSavedValues={} end
  local function migrate(value) return value=='off' and 'disabled' or value=='instance' and 'dungeons' or 'groups' end
  local function fill(t,key,legacy,backupKey)
    if t[key]~=nil and not self.GroupScopeNames[t[key]] then
      db.invalidSavedValues[backupKey]=t[key];t[key]=nil
    end
    if t[key]==nil and legacy~=nil then t[key]=migrate(legacy) end
  end
  fill(db,'groupScope',db.groupPolicyVersion==1 and 'group' or db.defaultScope or 'group','groupScope')
  db.groupPolicyVersion=1
  for id,cfg in pairs(db.items) do
    if type(cfg)=='table' then
      local legacy=cfg.groupPolicyVersion~=1 and cfg.scopeOverride or nil
      fill(cfg,'groupScopeOverride',legacy,tostring(id)..':groupScopeOverride')
      cfg.groupPolicyVersion=1
    end
  end
  -- Preserve an old action-editor draft without making it the speech editor.
  local draft=db.editorDraft
  if type(draft)=='table' and draft.channel=='me' then
    if type(db.legacyEditorDrafts)~='table' then
      if db.legacyEditorDrafts~=nil then db.invalidSavedValues.legacyEditorDrafts=db.legacyEditorDrafts end
      db.legacyEditorDrafts={}
    end
    table.insert(db.legacyEditorDrafts,draft);db.editorDraft=nil
  end
end
function A:GetGroupContext()
  local inGroup=(type(IsInGroup)=='function' and IsInGroup()) or (type(IsInRaid)=='function' and IsInRaid())
  local instanceGroup=type(IsInGroup)=='function' and type(LE_PARTY_CATEGORY_INSTANCE)=='number' and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
  if not inGroup and not instanceGroup then return nil,nil end
  local inside,kind=false,nil
  if type(IsInInstance)=='function' then inside,kind=IsInInstance() end
  if inside and (kind=='pvp' or kind=='arena') then return nil,nil end
  local raid=(type(IsInRaid)=='function' and IsInRaid()) or (inside and kind=='raid')
  local context=raid and 'raids' or (inside and kind=='party') and 'dungeons' or 'groups'
  return context,instanceGroup and 'INSTANCE_CHAT' or raid and 'RAID' or 'PARTY'
end
function A:GetEffectiveGroupScope(id)
  local cfg=self:GetSettings(id)
  local value=cfg and cfg.groupScopeOverride or self.db and self.db.groupScope
  return self.GroupScopeNames[value] and value or 'groups'
end
function A:CanSendInContext(id)
  local scope=self:GetEffectiveGroupScope(id)
  if scope=='disabled' then return false,'disabled_by_group_setting' end
  local context=self:GetGroupContext()
  if not context then return false,'not_in_supported_group' end
  if scope=='groups' or scope==context then return true end
  return false,'group_context_filtered'
end
