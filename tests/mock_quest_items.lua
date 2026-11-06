local clock=1000
function GetTime()return clock end
function time()return clock end
SlashCmdList={}
function IsInGroup()return true end
function IsInRaid()return false end
function IsInInstance()return false end
local frame={RegisterEvent=function()end,RegisterUnitEvent=function()end,SetScript=function()end}
function CreateFrame()return setmetatable({},{__index=frame})end
local secret={};function issecretvalue(value)return rawequal(value,secret)end
local function item(id)return {itemID=id,stackCount=2,itemName='Item '..id,hyperlink='|Hitem:'..id..'|h[Item]|h'}end
local bags={[0]={item(5457),item(12),item(13),item(14),item(15),item(16),item(6948),item(17)}}
local unknown=false
C_Container={GetContainerNumSlots=function(b)return #(bags[b] or {})end,
 GetContainerItemInfo=function(b,s)return bags[b][s]end,
 GetContainerItemQuestInfo=function(b,s)
  local id=bags[b][s].itemID
  if id==13 then return {isQuestItem=true}end
  if id==14 then return {isQuestItem=false,questID=123,isActive=false}end
  if id==17 then return {isQuestItem=secret,questID=secret}end
  return {isQuestItem=false}
 end}
C_Item={GetItemSpell=function(id)return 'Use',id end,
 GetItemInfoInstant=function(id)if unknown then return end;return id,nil,nil,nil,nil,(id==12 or id==99)and 12 or 0,1 end,
 GetItemInfo=function(id)
  if unknown then return end
  return 'Item '..id,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,0,1,id==5457 and 4 or 1
 end}
local sent=0;C_ChatInfo={SendChatMessage=function()sent=sent+1 end}
for line in io.lines('ForeverRP/ForeverRP.toc')do if line:match('%.lua$')then dofile('ForeverRP/'..line)end end
local a=ForeverRP;a.Say=function()end;a.SetupMinimap=function()end
local custom={'Old custom text.'}
ForeverRPDB={auto=true,defaultScope='always',globalLastEmoteAt=123,items={
 [5457]={enabled=true,categoryOverride='food',sayLines=custom,outOfStockEnabled=false},
 [99]={enabled=true,sayLines={'Absent quest tool.'}}}}
a:Init()
assert(not a.inventory[5457] and not a.inventory[12] and not a.inventory[13] and not a.inventory[14])
assert(not a.db.items[12] and not a.db.items[13] and not a.db.items[14],'new quest items remembered')
assert(a.inventory[15] and a.inventory[16] and a.inventory[17] and a.inventory[6948],'ordinary/reward/unknown data was guessed as quest')
assert(a.db.items[5457].sayLines==custom and a.db.items[5457].enabled and a.db.items[5457].outOfStockEnabled==false)
for _,filter in ipairs({'all','enabled','disabled','inbags','saved','unconfigured'})do
 a.itemFilter=filter
 for _,row in ipairs(a:ConfigItems())do assert(row.id~=5457 and row.id~=99 and row.id~=12 and row.id~=13 and row.id~=14)end
end
assert(a:CountRemembered()==4,'hidden quest items counted as usable saved items')
a:SendForItem(5457,'|Hitem:5457|h[Quest]|h',false)
assert(sent==0 and a.db.globalLastEmoteAt==123 and a.last.result=='quest_item_excluded_no_send')
-- Temporary quest association on ordinary supplies can clear with positive normal metadata.
C_Container.GetContainerItemQuestInfo=function()return {isQuestItem=false}end
assert(not a:IsQuestItem(13,0,3) and a.db.questItemIDs[13]==nil)
a:ResetInventory();assert(a.inventory[13] and a.db.items[13].enabled==false)
assert(a:IsQuestItem(5457,0,1),'quest binding wrongly cleared')
-- Cached positives survive missing optional APIs and absent quest items.
unknown=true;C_Container.GetContainerItemQuestInfo=nil
assert(a:IsQuestItem(5457) and a:IsQuestItem(99))
assert(not a:IsQuestItem(15) and not a:IsQuestItem(6948) and not a:IsQuestItem(secret))
-- Missing/throwing optional APIs cannot crash or classify a reward as a quest item.
C_Item.GetItemInfo=function()error('uncached')end
assert(not a:IsQuestItem(16))
a.db.editorDraft={item=5457,channel='say',tab='regular',text=string.rep('x',201)}
a:ArchiveQuestDraft();a:ArchiveQuestDraft()
assert(a.db.editorDraft==nil and #a.db.questEditorDrafts==1 and a.db.questEditorDrafts[1].text==string.rep('x',201))
assert(a.db.items[5457].sayLines==custom and a.db.globalLastEmoteAt==123)
print('PASS quest exclusions: class/binding/bag/start quest, remembered data, overrides, rewards, unsafe APIs, cooldowns and draft archive')

-- A delayed item-cache result refreshes the real inventory and saved-item view.
unknown=false
C_Item.GetItemInfoInstant=function(id)return id,nil,nil,nil,nil,id==20 and 12 or 0,1 end
C_Item.GetItemInfo=nil
bags[0][9]=item(20);a.db.items[20]={enabled=true,sayLines={'Keep this custom text.'}}
a.inventory[20]={id=20,count=2,spell=20}
a:OnQuestItemInfoReceived(20,true)
assert(not a.inventory[20] and a.db.items[20].enabled and a.db.items[20].sayLines[1]=='Keep this custom text.')
a:OnQuestItemInfoReceived(secret,true);a:OnQuestItemInfoReceived(20,secret)
print('PASS quest cache refresh without losing saved settings')
