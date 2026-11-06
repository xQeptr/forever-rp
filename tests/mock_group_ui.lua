dofile('tests/mock_ui.lua')
local a=ForeverRP
assert(a.modeDropdown==nil and next(a.channelButtons)==nil and next(a.customChannelButtons)==nil)
assert(a.activeChannel=='say')
local draft=a.textEditor:GetText()
local saved=a.db.items[a.selectedID].outSayLines
local oldGlobal=a.db.defaultScope
local cfg=a.db.items[a.selectedID]
local oldMode,oldScope=cfg.outputMode,cfg.scopeOverride
local function menuKeys(control,chosen)
 local keys={}
 control._menu(nil,{CreateRadio=function(_,_,_,select,key)
  keys[#keys+1]=key
  if key==chosen then select(key) end
 end})
 return table.concat(keys,',')
end
assert(menuKeys(a.globalScopeDropdown,'raids')=='groups,dungeons,raids,disabled')
assert(a.db.groupScope=='raids' and a.db.defaultScope==oldGlobal)
assert(a.textEditor:GetText()==draft and a.editorDirty and a.db.items[a.selectedID].outSayLines==saved,'policy switch lost invalid speech draft')
assert(menuKeys(a.itemScopeDropdown,'disabled')=='inherit,groups,dungeons,raids,disabled')
assert(cfg.groupScopeOverride=='disabled' and cfg.outputMode==oldMode and cfg.scopeOverride==oldScope)
menuKeys(a.itemScopeDropdown,'inherit');a:InitGroupSettings();assert(cfg.groupScopeOverride==nil)
assert(a.textEditor:GetText()==draft and a.db.editorDraft.channel=='say')
print('PASS group-only UI: no modes/channels, four policies, inheritance, archived settings and invalid-draft preservation')
