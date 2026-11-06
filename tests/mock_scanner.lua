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
for _,name in ipairs({'Core','Categories','Inventory','Scopes','Emotes','Samples','LocalizedSamples','ExtendedSamples','AlcoholSamples','StockSamples','DefaultLibrary','RaceLibrary','Library','Config'})do dofile('ForeverRP/'..name..'.lua')end
local a=ForeverRP
a.SendForItem=a.SendLegacyForItem
a.CanSendInContext=a.CanSendLegacyInContext
a.GetGroupSpeechChannels=a.GetAvailableChannels
a.SetupMinimap=function()end
local function item(id,n)return {itemID=id,stackCount=n,hyperlink=not missing and '|Hitem:'..id..'|h[Item]|h' or nil}end
local sends={}
local realSendForItem=a.SendForItem
a.SendForItem=function(_,id,link,stock)sends[#sends+1]={id=id,stock=stock}end
local function reset()
 clock=clock+10;missing=false;bags={[0]={item(118,2)}}
 ForeverRPDB={chatDestination="local",items={[118]={enabled=true,outOfStockEnabled=true}},defaultScope='always'}
 a:Init();for _,e in ipairs(a.DefaultEntries)do a:SetDefaultDisabled(e.id,true)end;a.lastCastGUID=nil;a.lastCastSpell=nil;a.lastConfirmedID=nil;sends={}
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
-- A newly acquired shared-spell item is discovered only after its success.
-- Its pending cast must not later consume an unrelated sale of item 118.
reset();a:OnSpellSucceeded('late-shared'..clock,111)
bags[0]={item(118,2),item(119,1)};a:OnBagsChanged()
assert(#a.pending==0,'late shared-spell discovery retained guessed candidate')
bags[0]={item(118,1),item(119,1)};a:OnBagsChanged()
assert(#sends==0,'pending cast attributed unrelated sale to old candidate')
reset();bags[0]={item(118,1)};a:OnBagsChanged();assert(a.removals[118])
bags[0]={item(118,2)};a:OnBagsChanged();assert(not a.removals[118],'gain retained removal')
reset();bags[0]={};a:OnBagsChanged();assert(a.removals[118])
bags[0]={item(118,1)};a:OnBagsChanged();assert(not a.removals[118],'reacquisition retained removal')
-- All carried stacks, including bag 5; no bank slots queried.
reset();bags={[0]={item(118,2)},[5]={item(118,3)},[-1]={item(118,99)}}
a:ResetInventory();assert(a.inventory[118].count==5)
-- Missing optional class metadata must not crash Hearthstone discovery or
-- erase an already known consumable's carried count/use-spell mapping.
local savedItemAPI=C_Item
for _,api in ipairs({{}, {GetItemSpell=savedItemAPI.GetItemSpell}}) do
 reset();bags={[0]={item(118,2),item(6948,1)}};C_Item=api
 a:OnBagsChanged()
 assert(a.inventory[118].count==2 and a.inventory[118].spell==111)
 assert(a.inventory[6948].count==1 and a.inventory[6948].reusable)
 assert(a.inventory[6948].autoCategory=='hearthstone' and #sends==0)
 C_Item=savedItemAPI
end
reset();bags={[0]={item(6948,1)}};C_Item=nil
a:ResetInventory();assert(a.inventory[6948].count==1 and #sends==0)
C_Item=savedItemAPI
reset();bags={[0]={item(118,2)},[5]={item(118,3)}};a:ResetInventory()
-- Charges are deliberately not inferred from an unchanged stack count.
a:OnSpellSucceeded('charge',111);a:OnBagsChanged();assert(#sends==0)
-- Invalid persisted values remain recoverable and migration is idempotent.
reset();ForeverRPDB.items[42]=false;ForeverRPDB.items[118].lines={42,'valid text'}
ForeverRPDB.items[118].outputMode='say';a:Init();a:Init()
assert(a.db.invalidSavedValues[42]==false)
assert(a.db.items[118].lines[1]==42 and a:GetPhrases(a.db.items[118],'en','me')[1]=='valid text')
assert(a.db.items[118].outSayLines==nil,'defaults must not materialize')
local custom={'custom'};a.db.items[118].outSayLines=custom;a:Init();assert(a.db.items[118].outSayLines==custom)
-- Secret values must never reach comparisons/indexing or change cast state.
local secret={};function issecretvalue(v)return rawequal(v,secret)end
local before=a.lastCastGUID
a:OnSpellSucceeded(secret,111);a:OnCastStart('x',secret);a:OnCastInterrupted(secret,111,'failed')
a.eventFrame.event(nil,'UNIT_SPELLCAST_SUCCEEDED',secret,secret,secret)
assert(a.lastCastGUID==before)
-- Real sender plus real scanner: invalid saved text must never spend cooldown.
a.SendForItem=realSendForItem
a.Say=function()end
function IsInInstance()return true,'party'end
local chat={}
C_ChatInfo={SendChatMessage=function(text,channel)chat[#chat+1]={text=text,channel=channel}end}
for _,language in ipairs({'en','de'})do
 for _,channel in ipairs({'me','say'})do
  for _,stock in ipairs({false,true})do
   for _,order in ipairs({'direct','bag','spell'})do
    for _,blank in ipairs({'','   ','\t  '})do
     for _,mixed in ipairs({false,true})do
      reset();chat={};a.shuffles={}
      local cfg=a.db.items[118]
      cfg.outputMode=channel;a.db.language=language
      local pool=mixed and {blank,42,'  valid RP  ',blank} or {blank}
      a:SetPhrases(cfg,language,channel,pool,stock)
      a.db.globalLastEmoteAt=123
      local function cast()
       a.eventFrame.event(nil,'UNIT_SPELLCAST_SUCCEEDED','player','blank-test'..clock,111)
      end
      if order=='direct'then a:SendForItem(118,nil,stock)
      else
       if order=='spell'then cast()end
       bags[0]=stock and {} or {item(118,1)}
       a.eventFrame.event(nil,'BAG_UPDATE_DELAYED')
       if order=='bag'then cast()end
      end
      assert(#chat==(mixed and 1 or 0),'invalid pool sent or valid pool suppressed')
      assert(a.db.globalLastEmoteAt==(mixed and clock or 123),'invalid output spent cooldown')
      local key=language..'_'..channel
      local field=(stock and {en_me='outMeLines',en_say='outSayLines',de_me='outDeMeLines',de_say='outDeSayLines'}
       or {en_me='lines',en_say='sayLines',de_me='deMeLines',de_say='deSayLines'})[key]
      assert(cfg[field]==pool and pool[1]==blank,'saved original changed')
      if mixed then
       assert(pool[2]==42 and pool[3]=='  valid RP  ','mixed originals changed')
       assert(chat[1].text=='valid RP' and chat[1].channel==(channel=='say' and 'SAY' or 'EMOTE'),'wrong text/channel')
      end
     end
    end
   end
  end
 end
end
io.write('PASS blank/mixed persisted pools: regular/Last Item, both languages/channels, direct/event/scanner\n')

-- Ambiguity diagnostics must not show a stale successful send from another use.
reset();bags[0]={item(118,2),item(119,2)};a:ResetInventory()
a.last.echo='observed';a.last.channel='say';a.last.text='stale'
a.lastProbe={at=clock,observed=false}
a:OnSpellSucceeded('trace-ambiguous',111)
assert(a.last.spellID==111 and a.last.echo=='none' and a.last.channel==nil and a.last.text==nil and a.lastProbe==nil)
local trace={};a.Say=function(_,text)trace[#trace+1]=text end;a.db.debug=true
local previousStamp=a.db.globalLastEmoteAt
a:TraceItemCandidates(111,{[118]=true,[119]=true},'test')
assert(#trace==3 and trace[2]:find('item=118',1,true) and trace[3]:find('item=119',1,true))
assert(a.db.globalLastEmoteAt==previousStamp,'diagnostics spent cooldown')
print('PASS bounded ambiguity diagnostics and fresh status')
