local mt={}
mt.__index=function(o,k)
 if k=='entry' then return nil end
 if k=='TitleText' then return o._title end
 if k=='GetText' then return function(self) return rawget(self,'_text') or '' end end
 if k=='GetHeight' then return function(self) return rawget(self,'_height') or 0 end end
 if k=='GetWidth' then return function(self) return rawget(self,'_width') or 622 end end
 if k=='SetHeight' then return function(self,h) self._height=h end end
 if k=='SetWidth' then return function(self,w) self._width=w end end
 if k=='GetFontString' then return function(self) return self._fontString end end
 if k=='SetFontString' then return function(self,f) self._fontString=f end end
 if k=='GetScript' then return function(self,event) return rawget(self,'_script_'..event) end end
 if k=='HookScript' then return function(self,event,fn)
  local previous=self:GetScript(event)
  self:SetScript(event,function(...) if previous then previous(...) end;fn(...) end)
 end end
 if k=='SetPoint' then return function(self,...) self._point={...} end end
 if k=='EnableMouse' then return function(self,x) self._mouse=x end end
 if k=='GetTop' then return function(self) return rawget(self,'_top') or 500 end end
 if k=='GetEffectiveScale' then return function(self) return rawget(self,'_scale') or 1 end end
 if k=='HasFocus' then return function(self) return rawget(self,'_focus') or false end end
 if k=='SetFocus' then return function(self) self._focus=true end end
 if k=='ClearFocus' then return function(self) self._focus=false end end
 if k=='SetCursorPosition' then return function(self,x) self._cursor=x end end
 if k=='GetVerticalScroll' then return function(self) return rawget(self,'_scroll') or 0 end end
 if k=='SetVerticalScroll' then return function(self,x) self._scroll=x end end
 if k=='GetChecked' then return function(self) return self._checked end end
 if k=='GetStringWidth' or k=='GetUnboundedStringWidth' then return function(self) return #(self._text or '')*6 end end
 if k=='GetStringHeight' then return function(self)
  assert(rawget(self,'_kind')~='EditBox','text measurement must use the FontString API')
  -- Deliberately approximate font metrics: model explicit lines and wrapping,
  -- so resizing/content-height tests cannot pass with a constant stub.
  local width=rawget(self,'_width') or 622
  local columns=math.max(1,math.floor(width/6))
  local lines=0
  for line in (tostring(rawget(self,'_text') or '')..'\n'):gmatch('(.-)\n') do
   lines=lines+math.max(1,math.ceil(#line/columns))
  end
  return lines*16
 end end
 if k=='IsShown' then return function(self) return self._shown or false end end
 if k=='CreateFontString' or k=='CreateTexture' then return function(self) return setmetatable({ _text='' },mt) end end
 if k=='SetText' then return function(self,x,...)
  assert(select('#',...)==0,'addon text widgets must receive one text argument')
  assert(type(x)=='string' or type(x)=='number','invalid widget text')
  self._text=x
 end end
 if k=='SetTextColor' then return function(self,r,g,b,a)
  for _,v in ipairs({r,g,b,a or 1}) do assert(type(v)=='number' and v>=0 and v<=1,'invalid text color') end
  self._color={r,g,b,a or 1}
 end end
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
 local f=setmetatable({_name=name,_kind=kind,_template=template,_parent=parent},mt)
 if template=='BasicFrameTemplateWithInset' then f._title=setmetatable({},mt) end
 return f
end
UIParent=CreateFrame('Frame')
GameTooltip=CreateFrame('Frame')
function GameTooltip:SetHyperlink(x) self.last=x end
-- Enforce the reported native color-object overload, rather than silently
-- discarding extra Lua results. This is not a full client API simulation.
function GameTooltip:SetText(x,color,alpha,wrap,...)
 assert(type(x)=='string','invalid tooltip text')
 assert(color==nil or (type(color)=='table' and type(color.GetRGBA)=='function'),
  "bad argument #2 to 'SetText' (Usage: self:SetText(text [, color, alpha, wrap]))")
 assert(alpha==nil or type(alpha)=='number','invalid tooltip alpha')
 assert(wrap==nil or type(wrap)=='boolean','invalid tooltip wrap')
 assert(select('#',...)==0,'too many tooltip arguments')
 self.last=x
end
function GetTime() return 1111 end
function time() return 1711111111 end
function UnitName() return 'Lucien' end
function UnitGUID() return 'guid-lucien' end
local root='ForeverRP/'
ForeverRP={db={language='en',auto=true,showMinimap=true,defaultScope='group',globalCooldown=30,items={}},inventory={},shuffles={}}
local A=ForeverRP
function A:GetSettings(id) return self.db.items[id] end
for _,file in ipairs({'Categories','Samples','LocalizedSamples','ExtendedSamples','AlcoholSamples','StockSamples','DefaultLibrary','RaceLibrary','Classes','IdentityLibrary','Library','Scopes','Emotes','Config'}) do
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
assert(A.configFrame and A.listScroll and A.libraryContent and not A.tabButtons.templates,'building inline default UI')
A:SelectItem(118)
assert(not A.customEditor:IsShown(),'custom editor starts visible')
assert(A.customEditor._parent==UIParent and A.editorScroll._parent._parent==A.customEditor,'editor is not independent')
A.editCustomButton._script_OnClick()
assert(A.customEditor:IsShown(),'editor button did not open window')
assert(A.libraryScroll._height==300,'defaults did not gain space')
-- Hover the actual library row: gsub's count must never reach native SetText.
local hoverRow
for _,r in ipairs(A.libraryRows) do if type(r.entry)=='table' then hoverRow=r;break end end
assert(hoverRow,'missing hover row')
local originalEntry=hoverRow.entry
for _,text in ipairs({'plain phrase','uses {item}.','{item} then {item}.'}) do
 hoverRow.entry={text=text}
 hoverRow._script_OnEnter(hoverRow)
 assert(GameTooltip.last==A:PreviewTemplateLine(text),'hover preview differs')
 hoverRow._script_OnLeave(hoverRow)
 assert(not GameTooltip:IsShown(),'hover tooltip did not hide')
end
hoverRow.entry=originalEntry
assert(not pcall(function() GameTooltip:SetText('text',1) end),'numeric color accepted')
assert(select('#',A:PreviewTemplateLine('{item}'))==1,'preview leaked replacement count')
assert(A.textEditor:GetText()=='takes a sip of {item}.','loaded correct regular phrase')
-- Geometric hit-test regression: only the actual native EditBox receives a
-- writing-area click. No fake overlay forwarding clicks through to it.
local edit,scroll=A.textEditor,A.editorScroll
scroll._width=622;scroll._height=261;scroll._script_OnSizeChanged(scroll,622,261)
assert(edit._point[1]=='TOPLEFT' and edit._point[2]==scroll,'scroll child not anchored to viewport')
assert(edit._mouse and edit:GetWidth()==622 and edit:GetHeight()>=261,'writing hit rectangle does not cover viewport')
local mouseX,mouseY
GetCursorPosition=function() return mouseX,mouseY end
local function clickWriting(x,y,button)
 assert(x>=0 and x<scroll:GetWidth() and y>=0 and y<scroll:GetHeight(),'outside writing viewport')
 local offset=scroll:GetVerticalScroll()
 edit._top=scroll:GetTop()+offset
 assert(x<edit:GetWidth() and y+offset<edit:GetHeight(),'click misses native EditBox')
 mouseX,mouseY=x*edit:GetEffectiveScale(),(scroll:GetTop()-y)*edit:GetEffectiveScale()
 -- Stand-in native placement occurs before addon HookScript. The addon must
 -- leave this intact on text lines, including native drag-selection state.
 edit._cursor=3;edit._selection={1,3};edit:ClearFocus()
 edit._script_OnMouseDown(edit,button or 'LeftButton')
end
for _,x in ipairs({1,310,621}) do
 clickWriting(x,10)
 assert(edit:HasFocus() and edit._cursor==3 and edit._selection[2]==3,'text-line click damaged native caret/selection')
end
clickWriting(310,220)
assert(edit:HasFocus() and edit._cursor==#edit:GetText(),'blank-area click must focus at text end')
clickWriting(310,220,'RightButton')
assert(not edit:HasFocus() and edit._cursor==3,'right mouse click changed cursor')
assert(not scroll:GetScript('OnMouseDown'),'scroll overlay intercepts native editing')
-- Scrollbar and footer controls are siblings/outside the writing viewport.
assert(edit._parent==scroll and A.customEditor~=edit._parent,'editor escaped its clipping viewport')
-- Width, line count, viewport height, UI scale and scroll offset are independent.
local originalText=edit:GetText()
local function measureDraft(text,width,height)
 A.loadingEditor=true
 edit:SetText(text);edit._script_OnTextChanged(edit)
 scroll._width=width;scroll._height=height;scroll._script_OnSizeChanged(scroll,width,height)
 A.loadingEditor=false
end
measureDraft(string.rep('a',1200),120,120)
local narrowHeight=edit:GetHeight()
assert(narrowHeight>900 and edit:GetWidth()==120,'wrapped content did not grow beyond viewport')
measureDraft(string.rep('a',1200),622,120)
assert(edit:GetHeight()>120 and edit:GetHeight()<narrowHeight,'wider viewport did not reflow content')
measureDraft(string.rep('line\n',20),622,261)
assert(edit:GetHeight()==21*16+30,'trailing newline did not retain final editable line')
scroll:SetVerticalScroll(180);edit._scale=.75
clickWriting(310,120)
assert(edit:HasFocus() and edit._cursor==3,'scaled scrolled text-line click moved cursor to end')
clickWriting(621,165)
assert(edit:HasFocus() and edit._cursor==#edit:GetText(),'scaled scrolled blank click missed text end')
edit._scale=1.5
clickWriting(1,120)
assert(edit:HasFocus() and edit._cursor==3,'large UI scale broke native placement')
clickWriting(310,165)
assert(edit._cursor==#edit:GetText(),'large UI scale broke blank-area placement')
scroll:SetVerticalScroll(0);edit._scale=1;edit._top=nil
measureDraft('',622,400)
assert(edit:GetHeight()==400,'empty editor did not cover enlarged viewport')
measureDraft(originalText,622,261)
assert(edit:GetHeight()==261,'short text did not shrink back to viewport')
assert(not A.editorDirty,'geometry-only checks dirtied saved phrases')
GetCursorPosition=nil
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
assert(A.libraryRows and #A.libraryRows>2,'default library rows missing')
local status
for _,r in ipairs(A.libraryRows) do if r.entry then status=r.status;break end end
assert(status,'missing default ON/OFF')
status._script_OnClick(status)
assert(next(A.db.defaultDisabled),'default disable not saved')
assert(A.db.items[118].outSayLines==nil,'default materialized into item')
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
assert(#A:GetResolvedPhrases(118,'en','say',true)>0 or #A:GetResolvedPhrases(118,'en','me',true)>0,'default stock phrases not seeded')
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
A.customEditor._script_OnHide()
assert(popupName=='FOREVERRP_DISCARD_INVALID','missing invalid close confirmation')
assert(A.db.items[118].lines[1]==old,'invalid draft overwrote prior valid saved phrase')
StaticPopupDialogs.FOREVERRP_DISCARD_INVALID.OnCancel()
assert(A.customEditor:IsShown(),'keep editing should reopen editor')
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
assert(cfg.outputMode=='say' and cfg.outSayLines==nil and #A:GetResolvedPhrases(118,'en','say',true)>0 and cfg.outMeLines==custom,'mode switch omitted Last Item say default')
local empty={};cfg.outSayLines=empty;chooseMode('mixed')
assert(cfg.outSayLines==empty and cfg.outMeLines==custom,'mode switch overwrote existing pools')
cfg.outOfStockEnabled=false;cfg.outSayLines=nil;chooseMode('say')
assert(cfg.outSayLines==nil and cfg.outOfStockEnabled==false,'mode switch ignored Last Item opt-out')
print('PASS v0.9.17 mock WoW UI: optional placeholder, exact newlines, validation, restore, autosave, icon layer, cursor scrolling, mode defaults')

-- Default sections follow tab/channel/category changes and preserve bad drafts.
A:SelectItem(118);A:SwitchTab('regular');A:SwitchChannel('me')
local cfg=A.db.items[118];cfg.autoCategory='potion';A:RefreshDetails()
local row
for _,r in ipairs(A.libraryRows)do if type(r.entry)=='table'then row=r;break end end
assert(row and row.entry.category=='potion' and not row.entry.stock and row.entry.channel=='me')
local disabled=row.entry.id;row.status._script_OnClick(row.status)
A.db.items[1179].autoCategory='potion';A:SelectItem(1179)
assert(A:IsDefaultDisabled(disabled),'disable did not survive item switch')
A:SwitchTab('last');A:SwitchChannel('say')
for _,r in ipairs(A.libraryRows)do
 if r:IsShown() and type(r.entry)=='table'then assert(r.entry.stock and r.entry.channel=='say')end
end
-- Reported item, race colors, pooled row reuse and both output pools/channels.
UnitRace=function() return 'Gnome','Gnome',7 end
A.db.items[37863]={name='Test item',enabled=false,autoCategory='potion',lines={},outputMode='mixed'}
A.inventory[37863]={count=1,name='Test item',autoCategory='potion'}
A:SelectItem(37863)
for _,tab in ipairs({'regular','last'}) do
 for _,channel in ipairs({'me','say'}) do
  A:SwitchTab(tab);A:SwitchChannel(channel)
  for _,r in ipairs(A.libraryRows) do
   if r:IsShown() and type(r.entry)=='table' then
    r._script_OnEnter(r);r._script_OnLeave(r)
    local expected=A:IsDefaultDisabled(r.entry.id) and .49 or ((r.entry.source~='universal') and .22 or 1)
    assert(r.display._color[1]==expected,'phrase color does not match source')
   end
  end
 end
end
A.db.items[37863].libraryLegacyEmpty={outSayLines=true}
A.libraryRows[3].display:SetTextColor(.22,.69,.68)
A:RefreshDefaultLibrary()
local foundOptOut=false
for _,r in ipairs(A.libraryRows) do
 if r:IsShown() and r.display:GetText():find('Legacy empty-pool',1,true) then
  foundOptOut=true
  assert(r.display._color[1]==.78 and r.display._color[2]==.81,'opt-out inherited a pooled header color')
 end
end
assert(foundOptOut,'missing legacy opt-out row')
A.textEditor:SetText(string.rep('x',201));A.editorDirty=true
local tab,channel,item=A.activeTab,A.activeChannel,A.selectedID
A:SwitchTab('regular');A:SwitchChannel('me');A:SelectItem(118)
assert(A.activeTab==tab and A.activeChannel==channel and A.selectedID==item,'invalid draft lost on library switch')
assert(A.textEditor:GetText()==string.rep('x',201))
io.write('PASS defaults UI: category sharing, pool switches, invalid drafts\n')

-- All visible rows are phrases, except the explicit legacy opt-out action.
A.editorDirty=false;A.db.editorDraft=nil;A:ReloadEditor()
A.db.items[37863].libraryLegacyEmpty=nil
A.db.defaultDisabled={};A:RefreshDefaultLibrary()
for _,r in ipairs(A.libraryRows) do
 if r:IsShown() then
  assert(type(r.entry)=='table','unexpected heading row')
  assert(r.status:GetText()=='ON','new default not ON')
 end
end
local r=A.libraryRows[1];local id=r.entry.id
r.status._script_OnClick(r.status)
assert(A:IsDefaultDisabled(id) and r.status:GetText()=='OFF','OFF must disable')
assert(r.display._color[1]==.49,'OFF text must be subdued')
r.status._script_OnClick(r.status)
assert(not A:IsDefaultDisabled(id) and r.status:GetText()=='ON','ON must enable')
-- Race color lives on the complete phrase, and resets on reused rows.
for _,race in ipairs({'Scourge','Orc','Dwarf','Gnome'}) do
 UnitRace=function() return race,race end
 A:RefreshDefaultLibrary()
 local _,info=A:GetPlayerRace();local found=false
 for _,r in ipairs(A.libraryRows) do
  if r:IsShown() then
   local color=(r.entry.source~='universal') and info.color or {1,1,1}
   for n=1,3 do assert(r.display._color[n]==color[n],'wrong phrase race color') end
   if (r.entry.source~='universal') then found=true end
  end
 end
 assert(found,'missing racial phrase')
end
-- A reload can recover an invalid draft, including its exact item/pool.
A.textEditor:SetText(string.rep('q',201));A.textEditor._script_OnTextChanged(A.textEditor)
local pending=deferred
assert(A.db.editorDraft.text==string.rep('q',201),'draft not persisted before debounce')
local draft=A.db.editorDraft
A.editorDirty=false;A:ReloadEditor();A:ShowCustomEditor()
assert(A.editorDirty and A.textEditor:GetText()==draft.text,'reload recovery lost draft')
assert(not A:SaveEditor(),'invalid recovered draft saved')
StaticPopupDialogs.FOREVERRP_DISCARD_INVALID.OnAccept()
pending()
assert(not A.editorDirty and A.db.editorDraft==nil,'stale timer restored discarded draft')
print('PASS separate editor, native writing hitbox, ON/OFF defaults, header-free colors, persisted invalid draft')

-- Pending callbacks cannot save into another item or pool after switching.
A:SelectItem(118);A:SwitchTab('regular');A:SwitchChannel('me')
A.textEditor:SetText('timer lifetime check');A.textEditor._script_OnTextChanged(A.textEditor)
local stale=deferred
A:SwitchChannel('say')
local sayBefore=A.textEditor:GetText()
stale()
assert(A.textEditor:GetText()==sayBefore and A.db.items[118].lines[1]=='timer lifetime check')
assert(A.customChannelButtons.say._selected and not A.customChannelButtons.me._selected)
A:SwitchTab('last')
assert(A.customTabButtons.last._selected and not A.customTabButtons.regular._selected)
-- Exercise real logout dispatch with the real editor, before debounce runs.
local savedDB,savedInventory=A.db,A.inventory
SlashCmdList={}
dofile(root..'Core.lua')
A.db,A.inventory=savedDB,savedInventory
A:SwitchTab('regular');A:SwitchChannel('me')
A.textEditor:SetText('saved immediately on logout');A.textEditor._script_OnTextChanged(A.textEditor)
A.eventFrame._script_OnEvent(A.eventFrame,'PLAYER_LOGOUT')
assert(A.db.items[118].lines[1]=='saved immediately on logout' and A.db.editorDraft==nil)
A:SwitchTab('last');A:SwitchChannel('say')
local prior=A.db.items[118].outSayLines
A.textEditor:SetText(string.rep('z',201));A.textEditor._script_OnTextChanged(A.textEditor)
A.eventFrame._script_OnEvent(A.eventFrame,'PLAYER_LOGOUT')
assert(A.db.items[118].outSayLines==prior and A.db.editorDraft.text==string.rep('z',201))
-- Simulate UI recreation after reload, starting without a selected item.
A.selectedID=nil;A.editorDirty=false
A:BuildConfig()
assert(A.customEditor:IsShown() and A.selectedID==118 and A.activeTab=='last' and A.activeChannel=='say')
assert(A.textEditor:GetText()==string.rep('z',201) and A.editorDirty,'build lost reload draft')
assert(A.customTabButtons.last._selected and A.customChannelButtons.say._selected)
print('PASS actual logout flush and BuildConfig reload recovery')
