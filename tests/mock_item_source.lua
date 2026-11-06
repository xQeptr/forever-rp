local clock=2000
function GetTime()return clock end
function time()return clock end
SlashCmdList={}
local frame={RegisterEvent=function()end,RegisterUnitEvent=function()end,SetScript=function()end}
function CreateFrame()return setmetatable({},{__index=frame})end
local bag,hooks={},{}
local used=0
C_Container={GetContainerNumSlots=function(b)return b==0 and #bag or 0 end,
 GetContainerItemInfo=function(b,s)if b==0 then return bag[s] end end,
 GetContainerItemID=function(b,s)return b==0 and bag[s] and bag[s].itemID end,
 UseContainerItem=function()used=used+1 end}
C_Item={GetItemInfoInstant=function()return nil,nil,nil,nil,nil,0,1 end,
 GetItemSpell=function()return 'Food',433 end,UseItemByName=function()used=used+1 end}
function UseAction()used=used+1 end
function GetActionInfo()return 'item',4604 end
function hooksecurefunc(owner,name,callback)hooks[owner]=hooks[owner] or {};hooks[owner][name]=callback end
for line in io.lines('ForeverRP/ForeverRP.toc')do if line:match('%.lua$')then dofile('ForeverRP/'..line)end end
local a=ForeverRP;a.Say=function()end;a.SetupMinimap=function()end
local sent={}
local realSendForItem=a.SendForItem
a.SendForItem=function(_,id,link,stock)sent[#sent+1]={id=id,stock=stock,link=link}end
local function item(id,n)return {itemID=id,stackCount=n,hyperlink='|Hitem:'..id..'|h[Food]|h'}end
local function reset(n)
 clock=clock+10;bag={item(2070,1),item(2679,8),item(4604,n or 15)}
 ForeverRPDB={items={[4604]={enabled=true,outOfStockEnabled=true}},defaultScope='always'}
 a:Init();sent={};a.lastCastGUID=nil;a.lastCastSpell=nil;a.lastConfirmedID=nil
end
local function source()hooks[C_Container].UseContainerItem(0,3)end
-- Three shared-spell foods, both normal event orders and the final item.
for _,count in ipairs({1,15})do
 for _,first in ipairs({'bag','spell'})do
  reset(count);source();assert(#sent==0 and used==0)
  if first=='spell'then a:OnSpellSucceeded('cast'..clock,433)end
  bag[3]=count>1 and item(4604,count-1) or nil;a:OnBagsChanged()
  if first=='bag'then a:OnSpellSucceeded('cast'..clock,433)end
  assert(#sent==1 and sent[1].id==4604 and sent[1].stock==(count==1),'wrong sourced food')
  a:OnSpellSucceeded('cast'..clock,433);assert(#sent==1,'duplicate success')
 end
end
-- Success may arrive synchronously before the post-hook.
reset();a:OnSpellSucceeded('early',433);assert(#sent==0);source()
bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==1 and sent[1].id==4604)
-- Both events before hook: item ID remains cached for a non-final stack.
reset();a:OnSpellSucceeded('early-both',433);bag[3]=item(4604,14);a:OnBagsChanged();source();a:MatchPending();assert(#sent==1)
-- A later use cannot resurrect an earlier ambiguous cast.
reset();a:OnSpellSucceeded('old-cast',433);clock=clock+1;source();bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==0)
-- Stock gains invalidate the old source, even if a later decrease follows.
reset();source();bag[3]=item(4604,16);a:OnBagsChanged();a:OnSpellSucceeded('after-gain',433);bag[3]=item(4604,15);a:OnBagsChanged();assert(#sent==0)
-- No source: matching one decrease alone still must not disambiguate.
reset();a:OnSpellSucceeded('no-source',433);bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==0)
-- Source/click alone plus sale is insufficient; success alone insufficient.
reset();source();bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==0)
reset();source();a:OnSpellSucceeded('no-decrease',433);assert(#sent==0)
-- A sale of another item must not be attributed to the observed mushroom use.
reset();source();a:OnSpellSucceeded('other-sale',433);bag[2]=item(2679,7);a:OnBagsChanged();assert(#sent==0)
-- A stale removal predating the source is never reused.
reset();bag[3]=item(4604,14);a:OnBagsChanged();clock=clock+0.1;source();a:OnSpellSucceeded('stale-sale',433);assert(#sent==0)
-- Stale, conflicting, failed and bank/merchant uses never supply identity.
reset();source();clock=clock+4;a:OnSpellSucceeded('stale',433);bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==0)
reset();source();hooks[C_Container].UseContainerItem(0,2);a:OnSpellSucceeded('conflict',433);bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==0)
reset();source();a:OnCastInterrupted('failed',433,'UNIT_SPELLCAST_FAILED');a:OnSpellSucceeded('after-failed',433);bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==0)
reset();MerchantFrame={IsShown=function()return true end};source();MerchantFrame=nil;assert(not a.itemUseSource)
hooks[C_Container].UseContainerItem(-1,3);assert(not a.itemUseSource)
-- Exact action IDs and item API IDs can also supply read-only evidence.
for _,route in ipairs({'action','item'})do
 reset();if route=='action'then hooks[_G].UseAction(1)else hooks[C_Item].UseItemByName(4604)end
 a:OnSpellSucceeded('route'..clock,433);bag[3]=item(4604,14);a:OnBagsChanged();assert(#sent==1 and sent[1].id==4604)
end
-- A second observed use of the same item after the deduplication window works.
reset();source();a:OnSpellSucceeded('repeat1',433);bag[3]=item(4604,14);a:OnBagsChanged();clock=clock+1;source();a:OnSpellSucceeded('repeat2',433);bag[3]=item(4604,13);a:OnBagsChanged();assert(#sent==2)
-- No hook duplication on Init/reload, no automatic item use.
assert(used==0)
-- Secret API arguments are ignored before indexing/comparison.
local secret={};function issecretvalue(v)return rawequal(v,secret)end
reset();hooks[C_Container].UseContainerItem(secret,3);hooks[C_Item].UseItemByName(secret);hooks[_G].UseAction(secret)
assert(not a.itemUseSource)
print('PASS passive item-source correlation: shared foods, both orders, final item, false uses, stale/conflict, action/item routes, secret values')

-- End-to-end: real bag scanner + item source + speech-only group sender.
a.SendForItem=realSendForItem
function IsInGroup()return true end
function IsInRaid()return false end
function IsInInstance()return false end
function UnitName()return 'Tester' end
function UnitGUID()return 'Player-1' end
local groupMessages={}
C_ChatInfo={SendChatMessage=function(text,channel)groupMessages[#groupMessages+1]={text,channel}end}
for _,first in ipairs({'bag','spell'})do
 reset(1)
 for _,e in ipairs(a.DefaultEntries)do a:SetDefaultDisabled(e.id,true)end
 local cfg=a.db.items[4604];cfg.outputMode='me';cfg.outSayLines={'That was my last mushroom.'};cfg.librarySchema=1
 source()
 if first=='spell'then a:OnSpellSucceeded('group-final'..clock,433)end
 bag[3]=nil;a:OnBagsChanged()
 if first=='bag'then a:OnSpellSucceeded('group-final'..clock,433)end
 assert(#groupMessages==(first=='bag' and 1 or 2))
 local message=groupMessages[#groupMessages]
 assert(message[1]=='That was my last mushroom.' and message[2]=='PARTY')
 assert(a.last.channel=='say' and cfg.outputMode=='me','legacy mode leaked into live group output')
end
print('PASS end-to-end shared food identity -> final-item speech -> PARTY in both event orders')
