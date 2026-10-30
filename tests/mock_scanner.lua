local clock=2000
function GetTime() return clock end
function time() return clock end
SlashCmdList={}
local f={RegisterEvent=function()end,RegisterUnitEvent=function()end,SetScript=function(self,_,fn)self.event=fn end}
function CreateFrame()return setmetatable({},{__index=f})end
local bags={}
local missing=false
C_Container={GetContainerNumSlots=function(b)return #(bags[b] or {})end,
 GetContainerItemInfo=function(b,s)return bags[b][s]end}
C_Item={GetItemSpell=function(id)if not missing then return 'Use',111 end end,
 GetItemInfoInstant=function()return nil,nil,nil,nil,nil,0,1 end}
for _,name in ipairs({'Core','Categories','Inventory','Scopes','Emotes','StockSamples','Config'})do dofile('ForeverRP/'..name..'.lua')end
local a=ForeverRP
a.SetupMinimap=function()end
local function item(id,n)return {itemID=id,stackCount=n,hyperlink=not missing and '|Hitem:'..id..'|h[Item]|h' or nil}end
local sends={}
a.SendForItem=function(_,id,link,stock)sends[#sends+1]={id=id,stock=stock}end
local function reset()
 clock=clock+10;missing=false;bags={[0]={item(118,2)}}
 ForeverRPDB={items={[118]={enabled=true,outOfStockEnabled=true}},defaultScope='always'}
 a:Init();a.lastCastGUID=nil;a.lastCastSpell=nil;a.lastConfirmedID=nil;sends={}
end
for _,first in ipairs({'bag','spell'})do
 reset()
 if first=='spell'then a:OnSpellSucceeded('cast'..clock,111)end
 bags[0]={item(118,1)};missing=true;a:OnBagsChanged()
 assert(a.inventory[118].count==1,'uncached item vanished')
 if first=='bag'then a:OnSpellSucceeded('cast'..clock,111)end
 assert(#sends==1 and not sends[1].stock,'false final item')
 reset();missing=true;a:OnBagsChanged();a:OnSpellSucceeded('no-use'..clock,111)
 assert(#sends==0,'metadata gap confirmed consumption')
 reset();bags[0]={item(118,1),item(119,1)};a:ResetInventory()
 bags[0]={item(119,1)};a:OnBagsChanged()
 if first=='spell'then a:OnSpellSucceeded('ambiguous'..clock,111)end
 bags[0]={};a:OnBagsChanged()
 if first=='bag'then a:OnSpellSucceeded('ambiguous'..clock,111)end
 assert(#sends==0,'stale sale attributed to shared spell')
end
reset();bags[0]={item(118,1)};a:OnBagsChanged();assert(a.removals[118])
bags[0]={item(118,2)};a:OnBagsChanged();assert(not a.removals[118],'gain retained removal')
-- All carried stacks, including bag 5; no bank slots queried.
reset();bags={[0]={item(118,2)},[5]={item(118,3)},[-1]={item(118,99)}}
a:ResetInventory();assert(a.inventory[118].count==5)
-- Charges are deliberately not inferred from an unchanged stack count.
a:OnSpellSucceeded('charge',111);a:OnBagsChanged();assert(#sends==0)
-- Invalid persisted values remain recoverable and migration is idempotent.
reset();ForeverRPDB.items[42]=false;ForeverRPDB.items[118].lines={42,'valid text'}
ForeverRPDB.items[118].outputMode='say';a:Init();a:Init()
assert(a.db.invalidSavedValues[42]==false)
assert(a.db.items[118].lines[1]==42 and a:GetPhrases(a.db.items[118],'en','me')[1]=='valid text')
assert(#a.db.items[118].outSayLines==20)
local custom={'custom'};a.db.items[118].outSayLines=custom;a:Init();assert(a.db.items[118].outSayLines==custom)
-- Secret values must never reach comparisons/indexing or change cast state.
local secret={};function issecretvalue(v)return rawequal(v,secret)end
local before=a.lastCastGUID
a:OnSpellSucceeded(secret,111);a:OnCastStart('x',secret);a:OnCastInterrupted(secret,111,'failed')
a.eventFrame.event(nil,'UNIT_SPELLCAST_SUCCEEDED',secret,secret,secret)
assert(a.lastCastGUID==before)
-- Import failure preserves saved pool, selection and tab.
a.selectedID=118;a.activeChannel='say';a.templateKind='regular';a.activeTab='templates'
a.templateSelection={[1]=true};local selection=a.templateSelection
local original={'old'};a.db.items[118].sayLines=original
a.inventory[118].link='|Hitem:118|h['..string.rep('x',240)..']|h'
a.GetTemplatePack=function()return {'uses {item} with considerable ceremony.'}end
a.editorStatus={SetText=function()end}
assert(a:ApplyInlineTemplates('selected')==false)
assert(a.db.items[118].sayLines==original and a.templateSelection==selection and a.activeTab=='templates')
io.write('PASS real scanner, ambiguity, metadata, migration, secrets and import regressions\n')
