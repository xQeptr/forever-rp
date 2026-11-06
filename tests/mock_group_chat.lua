local clock=1000
function GetTime()return clock end
function time()return clock end
local frame={RegisterEvent=function(self,e)self.events=self.events or {};self.events[e]=true end,RegisterUnitEvent=function()end,SetScript=function(self,k,f)self[k]=f end}
function CreateFrame()return setmetatable({},{__index=frame})end
SlashCmdList={}
LE_PARTY_CATEGORY_INSTANCE=2
local group,raid,instance=false,false,false
function IsInGroup(category)if category==2 then return instance end;return group or raid or instance end
function IsInRaid()return raid end
function IsInInstance()return instance,'party' end
function UnitName()return 'Tester' end
function UnitGUID()return 'Player-1' end
local sent={}
C_ChatInfo={SendChatMessage=function(text,ch)sent[#sent+1]={text=text,ch=ch}end,InChatMessagingLockdown=function()return false end}
for line in io.lines('ForeverRP/ForeverRP.toc')do if line:match('%.lua$')then dofile('ForeverRP/'..line)end end
local a=ForeverRP
a.Say=function()end;a.SetupMinimap=function()end;a.ScanBags=function()return {},{}end
ForeverRPDB={auto=true,manualChat=true,chatDestination='local',defaultScope='always',globalCooldown=30,globalLastEmoteAt=900,items={
 [118]={enabled=true,outputMode='me',lines={'legacy action'},sayLines={'A potion!'},outSayLines={'My last potion!'},outOfStockEnabled=true,librarySchema=1},
 [119]={enabled=true,outputMode='mixed',sayLines={'A drink!'},librarySchema=1},
 [6948]={enabled=true,outputMode='me',sayLines={'I am departing.'},librarySchema=1}}}
a:Init()
assert(a.db.groupScope=='groups' and a.db.manualChat==true and a.db.chatDestination=='local')
for _,e in ipairs(a.DefaultEntries)do a:SetDefaultDisabled(e.id,true)end
local function tick()clock=clock+31 end
local function use(id,remaining)tick();a:ConfirmedUse(id,nil,id,remaining or 1)end
-- Active path ignores dormant local/mode choices, but never overwrites them.
a:ConfirmedUse(118,nil,111,1);assert(#sent==0 and a.last.result:find('not_in_supported_group',1,true))
group=true;use(118);assert(#sent==1 and sent[1].ch=='PARTY' and sent[1].text=='A potion!' and not a.manualDraft)
assert(a.db.items[118].outputMode=='me' and a.db.items[118].lines[1]=='legacy action')
a:ConfirmedUse(119,nil,112,1);assert(#sent==1,'cross-item cooldown')
raid=true;use(118,0);assert(sent[2].ch=='RAID' and sent[2].text=='My last potion!' and #sent==2)
instance=true;use(119);assert(sent[3].ch=='INSTANCE_CHAT' and sent[3].text=='A drink!')
a.eventFrame.OnEvent(nil,'CHAT_MSG_INSTANCE_CHAT_LEADER','A drink!','Tester');assert(a.last.echo=='observed')
-- Context classification uses party/raid membership and instance kind independently.
raid=false;instance=false;group=true
assert(a:GetGroupContext()=='groups')
local originalInstance=IsInInstance
IsInInstance=function()return true,'party'end
local context,channel=a:GetGroupContext();assert(context=='dungeons' and channel=='PARTY')
a.db.groupScope='dungeons';use(119);assert(#sent==4)
IsInInstance=function()return true,'raid'end
context,channel=a:GetGroupContext();assert(context=='raids' and channel=='RAID')
use(119);assert(#sent==4,'dungeon-only emitted in raid')
a.db.groupScope='raids';use(119);assert(#sent==5)
IsInInstance=originalInstance
use(119);assert(#sent==5,'raid-only emitted in ordinary group')
a.db.items[119].groupScopeOverride='groups';use(119);assert(#sent==6)
a.db.items[119].groupScopeOverride='disabled';use(119);assert(#sent==6)
a.db.items[119].groupScopeOverride=nil;a.db.groupScope='groups'
IsInInstance=function()return true,'pvp'end;use(119);assert(#sent==6,'battleground leaked output');IsInInstance=originalInstance
-- Rejected attempts never spend cooldown or fall back.
local previous=a.db.globalLastEmoteAt
C_ChatInfo.SendChatMessage=function()error('rejected')end;use(118);assert(a.db.globalLastEmoteAt==previous and #sent==6)
C_ChatInfo.SendChatMessage=function()return false end;use(118);assert(a.db.globalLastEmoteAt==previous)
C_ChatInfo.SendChatMessage=function(text,ch)sent[#sent+1]={text=text,ch=ch}end
-- Speech pool opt-outs do not fall back to action text.
a.db.items[118].sayLines={};use(118);assert(#sent==6)
a.db.auto=false;use(119);assert(#sent==6 and a.last.result=='confirmed_auto_off_preview_only');a.db.auto=true
-- Hearthstone cast-start only, shared and independent throttles, interruption.
local link='|Hitem:6948|h[Hearthstone]|h'
a.inventory={[6948]={id=6948,reusable=true,count=1,spell=8690,link=link}};a.spellToItems={[8690]={[6948]=true}}
group=false;tick();a:OnCastStart('solo',8690);assert(#sent==6 and a.db.hearthLastAnnounceAt==0)
group=true;tick();a:OnCastStart('hs1',8690);assert(#sent==7 and sent[7].text=='I am departing.' and a.db.hearthLastAnnounceAt==clock)
a:OnCastInterrupted('hs1',8690,'UNIT_SPELLCAST_INTERRUPTED');tick();a:OnCastStart('hs2',8690);a:OnSpellSucceeded('hs2',8690);assert(#sent==7)
-- Additive, idempotent policy migration; preserve all old pool data and timestamps.
local cfg=a.db.items[118];local action=cfg.lines;local de={'dormant German'};cfg.deMeLines=de;cfg.scopeOverride='off';cfg.groupPolicyVersion=nil;cfg.groupScopeOverride=nil
local saved=a.db.globalLastEmoteAt;a:Init();assert(cfg.groupScopeOverride=='disabled' and cfg.lines==action and cfg.deMeLines==de and a.db.globalLastEmoteAt==saved)
cfg.groupScopeOverride=nil;a:Init();assert(cfg.groupScopeOverride==nil,'inherit was remigrated from archived scope')
cfg.groupScopeOverride='raids';a:Init();assert(cfg.groupScopeOverride=='raids')
a.db.groupScope='disabled';a:Init();assert(a.db.groupScope=='disabled')
cfg.groupScopeOverride=nil;cfg.scopeOverride='instance';cfg.groupPolicyVersion=nil;a:Init();assert(cfg.groupScopeOverride=='dungeons' and cfg.scopeOverride=='instance')
local draft={channel='me',item=118,tab='regular',text=string.rep('x',201)};a.db.editorDraft=draft;a:Init();a:Init()
assert(a.db.editorDraft==nil and #a.db.legacyEditorDrafts==1 and a.db.legacyEditorDrafts[1]==draft)
-- Exactly the four active policy choices; legacy scopes stay available only internally.
assert(table.concat(a.GroupScopeOrder,',')=='groups,dungeons,raids,disabled')
print('PASS group-only speech: routes, contexts, filters, scopes, migration, dormant pools, opt-outs, cooldowns, Hearthstone')

-- Old missing/disabled/invalid settings and all phrase arrays survive additive migration.
local oldPools={lines={'action'},sayLines={'Speech.'},deMeLines={'German action'},deSayLines={'German speech'},
 outMeLines={'last action'},outSayLines={'Last speech.'},outDeMeLines={'last German action'},outDeSayLines={'last German speech'}}
local disabled={enabled=false,outOfStockEnabled=false,outputMode='mixed',scopeOverride='off',categoryOverride='food'}
for key,pool in pairs(oldPools)do disabled[key]=pool end
ForeverRPDB={defaultScope='off',auto=false,manualChat=true,chatDestination='local',globalCooldown=60,globalLastEmoteAt=456,hearthLastAnnounceAt=123,showMinimap=false,items={[10]=disabled}}
a:Init();a:Init()
assert(a.db.groupScope=='disabled' and disabled.groupScopeOverride=='disabled')
assert(a.db.auto==false and a.db.showMinimap==false and not disabled.enabled and not disabled.outOfStockEnabled)
assert(a.db.globalLastEmoteAt==456 and a.db.hearthLastAnnounceAt==123 and a.db.globalCooldown==60)
for key,pool in pairs(oldPools)do assert(disabled[key]==pool,key..' overwritten')end
assert(disabled.outputMode=='mixed' and disabled.scopeOverride=='off' and disabled.categoryOverride=='food')
a.db.groupScope=false;disabled.groupScopeOverride=42;a:Init()
assert(a.db.invalidSavedValues.groupScope==false and a.db.invalidSavedValues['10:groupScopeOverride']==42)
assert(a.db.groupScope=='groups' and disabled.groupScopeOverride==nil)
print('PASS additive group policy migration: old/missing/disabled/malformed settings and all legacy arrays')
