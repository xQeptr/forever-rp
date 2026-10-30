local BASE='ForeverRP/'
local clock=1000
function GetTime() return clock end
function time() return math.floor(clock) end
local sent={}
local printed={}
function print(x) printed[#printed+1]=x end
local frame={}
function frame:RegisterEvent(event) self.events=self.events or {};self.events[event]=true end
function frame:RegisterUnitEvent(...) end
function frame:SetScript(event,callback) self[event]=callback end
function CreateFrame(...) return setmetatable({}, {__index=frame}) end
function IsInInstance() return false,'none' end
function InCombatLockdown() return false end
function IsInGroup() return false end
function IsInRaid() return false end
C_ChatInfo={SendChatMessage=function(text,ch) sent[#sent+1]={text=text,ch=ch} end, InChatMessagingLockdown=function() return false end}
function UnitGUID() return 'Player-1' end
function UnitName() return 'Elendrah' end
C_Timer=nil
SLASH_FOREVERRP1=nil
SlashCmdList={}
local function ok(x,msg) if not x then error(msg,2) end end
local files={'Core.lua','Compat.lua','Categories.lua','Samples.lua','LocalizedSamples.lua','ExtendedSamples.lua','AlcoholSamples.lua','StockSamples.lua','DefaultLibrary.lua','RaceLibrary.lua','Library.lua','Inventory.lua','Scopes.lua','Emotes.lua','Config.lua','Minimap.lua'}
for _,f in ipairs(files) do assert(loadfile(BASE..f))() end
local a=ForeverRP
-- pre-existing settings survive migration.
ForeverRPDB={items={[118]={name='Minor Healing Potion',enabled=true,lines={'uses a {item}.'},outOfStockEnabled=true,outMeLines={'finishes the last {item}. "Out!"'}},
  [1179]={name='Ice Cold Milk',enabled=true,outOfStockEnabled=false,lines={'sips {item}.'}},[333]={name='Legacy enabled Potion',enabled=true,lines={'drinks {item}.'}}},defaultScope='always',auto=true,showMinimap=false}
a.ScanBags=function() return {},{} end
a.SetupMinimap=function() end
a:Init()
ok(a.db.items[118].lines[1]=='uses a {item}.','legacy phrases changed')
ok(a.db.globalCooldown==30,'default cooldown missing')
ok(a.db.items[1179].outOfStockEnabled==false, 'explicit legacy off switched on')
ok(a.db.items[333].outOfStockEnabled==true, 'legacy enabled nil should default on')
ok(a.db.items[333].outMeLines==nil and #a:GetResolvedPhrases(333,'en','me',true)>0,'stock defaults must resolve without copying')
-- Isolate event invariants using custom texts; library integration has its own suite.
for _,entry in ipairs(a.DefaultEntries) do a:SetDefaultDisabled(entry.id,true) end
local link='|cffffffff|Hitem:118::::::::|h[Minor Healing Potion]|h|r'
local milk='|cffffffff|Hitem:1179::::::::|h[Ice Cold Milk]|h|r'
local function tick(t) clock=t end
-- first regular item; then shared 30 second guard across different item IDs.
a:ConfirmedUse(118,link,111,4)
ok(#sent==1 and sent[1].text:find('uses a',1,true),'regular emit failed')
tick(1001); a:ConfirmedUse(1179,milk,112,3)
ok(#sent==1 and a.last.result:find('shared_cooldown',1,true),'shared cooldown failed')
-- 1->0 replaces normal line with special line
clock=1031
-- prevent duplicate id guard (last confirmed other id)
a:ConfirmedUse(118,link,111,0)
ok(#sent==2 and sent[2].text:find('finishes the last',1,true) and not sent[2].text:find('uses a',1,true),'last-item replacement wrong')
ok(a.last.stock=='out_of_stock','stock mode not recorded')
-- another fresh use while message throttle running
clock=1033; a:ConfirmedUse(1179,milk,112,2)
ok(#sent==2,'spam across items')
-- no out-of-stock opt-in on milk -> normal
clock=1065; a:ConfirmedUse(1179,milk,112,0)
ok(#sent==3 and sent[3].text:find('sips',1,true),'normal when not opted-in')
-- no auto on bag movement without spell success
clock=1097
sent={}
a.inventory={[118]={id=118,count=1,link=link,spell=111}}
a.spellToItems={[111]={[118]=true}}
a.removals={};a.pending={}
a.ScanBags=function() return {},{} end
a:OnBagsChanged()
ok(#sent==0,'removal falsely announced')
-- matching success after bags updates
clock=1098
a:OnSpellSucceeded('v1',111)
ok(#sent==1 and sent[1].text:find('finishes the last',1,true),'success-after-bag-updates failed')
-- casting first, update second
clock=1130
sent={}; a.inventory={[118]={id=118,count=1,link=link,spell=111}}
a.spellToItems={[111]={[118]=true}}; a.removals={}; a.pending={}
a:OnSpellSucceeded('v2',111)
ok(#sent==0, 'pre-bag event emitted')
a:OnBagsChanged()
ok(#sent==1 and sent[1].text:find('finishes the last',1,true),'bag-after-success failed')
-- stolen item (no cast) shouldn't emit again
clock=1161; sent={}; a.inventory={[118]={id=118,count=1,link=link,spell=111}};a.spellToItems={[111]={[118]=true}};a.pending={};a.removals={}
a:OnBagsChanged();ok(#sent==0,'sale/waste alarm emitted')
-- verify stock template library lengths and links
for _,cat in ipairs({'healthstone','potion','drink','food','bufffood','elixir','bandage','alcohol','other'}) do
 for _,channel in ipairs({'me','say'}) do
  local p=a:GetStockSamplePack(cat,channel)
  ok(#p==20,'wrong stock size '..cat..'/'..channel)
  for _,l in ipairs(p) do ok(l:find('{item}',1,true)~=nil,'sample missing item token') end
 end
end
local am=a:GetSamplePack('alcohol','en','me')
local as=a:GetSamplePack('alcohol','en','say')
ok(#am==30 and #as==30, 'new alcohol sample count')
ok(am[1]:find('tavern',1,true) and not am[1]:find('long sip',1,true),'alcohol pack not drink pack')
ok(a:GetSamplePack('drink','en','me')[1]~=am[1],'drinks should remain different')
for _,line in ipairs(am) do ok(line:find('{item}',1,true),'missing alcohol me placeholder') end
for _,line in ipairs(as) do ok(line:find('{item}',1,true),'missing alcohol say placeholder') end
-- classifier hedges; manual override possible
local cat=a:DetectCategory({id=9999,name='Dwarven Stout',spellName='Drink',subclassID=5},0,1)
ok(cat=='alcohol','alcohol category')
local regular=a:DetectCategory({id=1179,name='Ice Cold Milk',spellName='Drink',subclassID=5},0,1)
ok(regular=='drink','milk classified as alcohol')
-- hearth 120s cooldown and shared throttle
clock=1200; sent={}
a.inventory={[6948]={id=6948,count=1,link='|Hitem:6948|h[Hearthstone]|h',spell=8690,reusable=true}}
a.db.items[6948]={name='Hearthstone',enabled=true,lines={'begins to use {item}.'}}
a.db.hearthLastAnnounceAt=0;a.db.globalLastEmoteAt=1100
a:OnCastStart('h1',8690)
ok(#sent==1,'hearth first cast failed')
a:OnCastInterrupted('h1',8690,'UNIT_SPELLCAST_INTERRUPTED')
clock=1280;a:OnCastStart('h2',8690)
ok(#sent==1,'hearth 120s throttle broken')
clock=1321;a:OnCastStart('h3',8690)
ok(#sent==2,'hearth after throttle failed')
-- Global cooldown should not shorten 120s hearth limit
clock=1322; a:OnCastInterrupted('h3',8690,'UNIT_SPELLCAST_INTERRUPTED')
clock=1332; a:OnCastStart('h4',8690)
ok(#sent==2,'hearth repeat after 10s')
print('All simulated cases pass')
io.write('PASS mock WoW event tests (stock, global throttle, sales, cast ordering, hearth, classification, samples)\n')

-- Confirmed consumed item using a template without the item link works
-- even when the cache has no hyperlink yet.
clock=1500;sent={}
a.db.items[118].lines={'stares into the empty cup.'}
a.db.items[118].outOfStockEnabled=false
a.db.globalLastEmoteAt=1000
a:ConfirmedUse(118,nil,111,5)
ok(#sent==1 and sent[1].text=='stares into the empty cup.','plain text required unneeded item link')
clock=1535;sent={};a.db.items[118].lines={'takes {item} in hand.'}
a:ConfirmedUse(118,nil,111,4)
ok(#sent==0 and a.last.result=='confirmed_missing_genuine_item_link_no_send','missing required item link not blocked')
io.write('PASS v0.9.16 plain RP and missing-link gating\n')

-- Logout flush is bound once on the lifetime event frame; no UI is required.
ok(a.eventFrame.events.PLAYER_LOGOUT,'logout event missing')
local saves=0;local save=a.SaveEditor
a.SaveEditor=function() saves=saves+1;return true end
a.eventFrame.OnEvent(a.eventFrame,'PLAYER_LOGOUT')
ok(saves==1,'logout did not flush editor')
a.SaveEditor=save
