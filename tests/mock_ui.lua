local mt={}
mt.__index=function(o,k)
 if k=='TitleText' then return o._title end
 if k=='GetText' then return function(self) return self._text or '' end end
 if k=='GetHeight' then return function(self) return self._height or 0 end end
 if k=='GetVerticalScroll' then return function(self) return self._scroll or 0 end end
 if k=='SetVerticalScroll' then return function(self,x) self._scroll=x end end
 if k=='GetChecked' then return function(self) return self._checked end end
 if k=='GetStringWidth' or k=='GetUnboundedStringWidth' then return function(self) return #(self._text or '')*6 end end
 if k=='GetStringHeight' then return function(self) return 30 end end
 if k=='IsShown' then return function(self) return self._shown or false end end
 if k=='CreateFontString' or k=='CreateTexture' then return function(self) return setmetatable({ _text='' },mt) end end
 if k=='SetText' then return function(self,x) self._text=x end end
 if k=='SetChecked' then return function(self,x) self._checked=x end end
 if k=='Show' then return function(self) self._shown=true end end
 if k=='Hide' then return function(self) self._shown=false end end
 if k=='SetShown' then return function(self,x) self._shown=x end end
 if k=='SetScript' then return function(self,event,callback) self['_script_'..event]=callback end end
 if k=='SetupMenu' then return function(self,cb) self._menu=cb end end
 if k=='SetDefaultText' then return function(self,x) self._default=x end end
 if k=='OverrideText' then return function(self,x) self._caption=x end end
 if k=='SetScrollChild' then return function(self,x) self._child=x end end
 if k=='SetSize' then return function(self,w,h) self._width=w;self._height=h end end
 return function(self,...) return nil end
end
function CreateFrame(kind,name,parent,template)
 local f=setmetatable({_name=name,_kind=kind,_template=template},mt)
 if template=='BasicFrameTemplateWithInset' then f._title=setmetatable({},mt) end
 return f
end
UIParent=CreateFrame('Frame')
GameTooltip=CreateFrame('Frame')
function GameTooltip:SetHyperlink(x) self.last=x end
function GameTooltip:SetText(x) self.last=x end
function GetTime() return 1111 end
function time() return 1711111111 end
function UnitName() return 'Lucien' end
function UnitGUID() return 'guid-lucien' end
local root='ForeverRP/'
ForeverRP={db={language='en',auto=true,showMinimap=true,defaultScope='group',globalCooldown=30,items={}},inventory={},shuffles={}}
local A=ForeverRP
function A:GetSettings(id) return self.db.items[id] end
for _,file in ipairs({'Categories','Samples','LocalizedSamples','ExtendedSamples','AlcoholSamples','StockSamples','Scopes','Emotes','Config'}) do
 dofile(root..file..'.lua')
end
A.db.items[118]={name='Minor Healing Potion',enabled=true,lines={'takes a sip of {item}.'},sayLines={'I need {item}.'},outputMode='mixed'}
A.db.items[1179]={name='Ice Cold Milk',enabled=true,lines={'drinks a {item}.'},outputMode='me'}
A.inventory[118]={count=5,name='Minor Healing Potion',icon=123,link='|Hitem:118|h[Minor Healing Potion]|h',autoCategory='potion'}
A.inventory[1179]={count=2,name='Ice Cold Milk',icon=456,link='|Hitem:1179|h[Ice Cold Milk]|h',autoCategory='drink'}
A:BuildConfig()
assert(A.configFrame._kind=='Frame','uses independent themed window')
assert(A.tabButtons.regular.SetSelected and A.channelButtons.me.SetSelected,'real selection-enabled tabs')
assert(A.listScroll~=nil,'list panel built')
assert(A.configFrame and A.listScroll and A.tabButtons.templates,'building UI')
A:SelectItem(118)
assert(A.textEditor:GetText()=='takes a sip of {item}.','loaded correct regular phrase')
A.textEditor:SetText('consumes a {item} politely.')
A.editorDirty=true
A:SelectItem(1179)
assert(A.db.items[118].lines[1]=='consumes a {item} politely.','autosave during item switch')
assert(A.activeTab=='regular','item click shows regular immediately')
A:SelectItem(118)
A:SwitchChannel('say')
assert(A.textEditor:GetText()=='I need {item}.','/say loaded correctly')
A.textEditor:SetText('More {item}, please.')
A.editorDirty=true
A:SwitchTab('last')
assert(A.db.items[118].sayLines[1]=='More {item}, please.','save on tab switch')
A:SwitchTab('templates')
assert(A.templateKind=='last','templates inherit last item mode')
A.templateSelection={[1]=true}
A:ApplyInlineTemplates('selected')
assert(A.activeTab=='last','templates return to appropriate editor')
assert(#A.db.items[118].outSayLines==1,'template saved in last-item /say')
A:SwitchChannel('me')
A:SwitchTab('regular')
assert(A.textEditor:GetText()=='consumes a {item} politely.','regular /me unchanged')
A:SelectItem(1179)
assert(A.db.items[1179].lines[1]=='drinks a {item}.','other item unchanged')
-- v0.9.15: direct row toggle, default-on Last Item, explicit opt-out and debounce autosave.
A:SelectItem(118)
local row
for _,r in ipairs(A.listButtons) do if r.itemID==118 then row=r;break end end
assert(row and row.status._script_OnClick,'per-item ON/OFF segment missing')
assert(A.enableCheck==nil,'duplicate enable checkbox remains')
local prior=A.db.items[118].enabled
row.status._script_OnClick(row.status)
assert(A.db.items[118].enabled==not prior,'row click does not toggle')
row.status._script_OnClick(row.status)
assert(A.db.items[118].enabled==prior,'second row click does not restore')
assert(A.db.items[118].outOfStockEnabled==true,'stock not ON by default')
assert(#A:GetPhrases(A.db.items[118],'en','say',true)>0 or #A:GetPhrases(A.db.items[118],'en','me',true)>0,'default stock phrases not seeded')
A.stockCheck:SetChecked(false);A.stockCheck._script_OnClick(A.stockCheck)
assert(A.db.items[118].outOfStockEnabled==false,'last-item optout failed')
row.status._script_OnClick(row.status);row.status._script_OnClick(row.status)
assert(A.db.items[118].outOfStockEnabled==false,'explicit last-item optout not preserved')
A:SelectItem(118)
A:SwitchTab('regular');A:SwitchChannel('me')
local deferred
C_Timer={After=function(seconds,fn) if seconds==0 then fn() else assert(seconds==.7);deferred=fn end end}
local before=A.db.items[118].lines[1]
A.textEditor:SetText('new auto-save {item} line.')
A.textEditor._script_OnTextChanged(A.textEditor)
assert(A.db.items[118].lines[1]==before,'saved before debounce')
assert(deferred,'autosave timer not scheduled')
deferred()
assert(A.db.items[118].lines[1]=='new auto-save {item} line.','debounced autosave failed')
local valid=A.db.items[118].lines[1]

-- Optional placeholder and real newline semantics.
local lines,err=A:ParseLines('looks to the stars.\n\nshakes the empty flask.')
assert(lines and #lines==2 and not err,'optional placeholder/newline failed')
lines,err=A:ParseLines(('a'):rep(160))
assert(lines and #lines==1,'visual wraps incorrectly split one sentence')
lines,err=A:ParseLines('first line with {item}.\n\n'..('a'):rep(201))
assert(lines==nil and err:find('Line 3',1,true),'oversize line error does not point to source line')
lines,err=A:ParseLines('It is done.\n\n|Hitem:123|h[bad]|h')
assert(lines==nil and err:find('Line 3',1,true),'bad hyperlink line not identified')
lines,err=A:ParseLines('drinks {item} and keeps drinking.',('x'):rep(253))
assert(lines==nil and err:find('255',1,true),'long resolved link not rejected')
lines,err=A:ParseLines('bare itemless emote.',('x'):rep(253))
assert(lines and #lines==1,'itemless phrase should not depend on link length')
-- Editor auto-save accepts plain text.
A.textEditor:SetText('a calm sigh, then silence.')
A.textEditor._script_OnTextChanged(A.textEditor);deferred()
assert(A.db.items[118].lines[1]=='a calm sigh, then silence.','itemless phrase was not autosaved')
-- The item texture sits above selection/hover ARTWORK and stays enabled.
assert(row.icon._kind == nil or row.icon.SetDrawLayer,'texture mock exists')
-- v0.9.17: cursor scrolling tracks a freshly inserted final line.
assert(A.editorScroll and A.textEditor._script_OnCursorChanged,'editor cursor scrolling hook missing')
A.editorScroll._height=250
A.textEditor:SetHeight(390)
A.editorScroll:SetVerticalScroll(0)
A.textEditor._script_OnCursorChanged(A.textEditor,0,-346,0,18)
assert(A.editorScroll:GetVerticalScroll()>=120,'Enter at end did not scroll to the caret')
A.textEditor._script_OnCursorChanged(A.textEditor,0,-2,0,18)
assert(A.editorScroll:GetVerticalScroll()==0,'moving caret back to top should restore scroll')
A.editorScroll:SetVerticalScroll(160)
A:SelectItem(1179)
assert(A.editorScroll:GetVerticalScroll()==0,'item switch must reset editor scroll')
A:SelectItem(118)
-- Invalid draft triggers explicit native confirmation on close.
StaticPopupDialogs={};local popupName
StaticPopup_Show=function(name) popupName=name end
A.textEditor:SetText(('a'):rep(201));A.textEditor._script_OnTextChanged(A.textEditor);deferred()
local old=A.db.items[118].lines[1]
A.configFrame._script_OnHide()
assert(popupName=='FOREVERRP_DISCARD_INVALID','missing invalid close confirmation')
assert(A.db.items[118].lines[1]==old,'invalid draft overwrote prior valid saved phrase')
StaticPopupDialogs.FOREVERRP_DISCARD_INVALID.OnCancel()
assert(A.configFrame:IsShown(),'keep editing should reopen config')
StaticPopupDialogs.FOREVERRP_DISCARD_INVALID.OnAccept()
assert(A.editorDirty==false and A.textEditor:GetText()==old,'discard should restore saved phrase')
-- Mode changes seed only missing Last Item pools, without replacing drafts,
-- custom pools, explicit empty pools or the Last Item opt-out.
local cfg=A.db.items[118]
local function chooseMode(mode)
 A.modeDropdown._menu(nil,{CreateRadio=function(_,_,_,choose,key)
  if key==mode then choose(key) end
 end})
end
cfg.outputMode='me';cfg.outOfStockEnabled=true
local custom={'custom last me'};cfg.outMeLines=custom;cfg.outSayLines=nil
chooseMode('say')
assert(cfg.outputMode=='say' and #cfg.outSayLines>0 and cfg.outMeLines==custom,'mode switch omitted Last Item say default')
local empty={};cfg.outSayLines=empty;chooseMode('mixed')
assert(cfg.outSayLines==empty and cfg.outMeLines==custom,'mode switch overwrote existing pools')
cfg.outOfStockEnabled=false;cfg.outSayLines=nil;chooseMode('say')
assert(cfg.outSayLines==nil and cfg.outOfStockEnabled==false,'mode switch ignored Last Item opt-out')
print('PASS v0.9.17 mock WoW UI: optional placeholder, exact newlines, validation, restore, autosave, icon layer, cursor scrolling, mode defaults')
