-- Real selection and chat-draft boundary, independent from automatic sends.
local clock=1000
function GetTime() return clock end
function time() return clock end
local frame={RegisterEvent=function()end,RegisterUnitEvent=function()end,SetScript=function()end}
function CreateFrame()return setmetatable({},{__index=frame})end
SlashCmdList={}
function IsInInstance()return false end
function IsInGroup()return true end
local combat=false
function InCombatLockdown()return combat end
function UnitGUID()return 'Player-1' end
function UnitName()return 'Tester' end
local sends,opened=0,{}
C_ChatInfo={SendChatMessage=function()sends=sends+1 end,InChatMessagingLockdown=function()return false end}
local active=nil
ChatFrameUtil={OpenChat=function(text)opened[#opened+1]=text end,GetActiveWindow=function()return active end}
for line in io.lines('ForeverRP/ForeverRP.toc')do if line:match('%.lua$')then dofile('ForeverRP/'..line)end end
local a=ForeverRP
a.SendForItem=a.SendLegacyForItem
a.CanSendInContext=a.CanSendLegacyInContext
a.GetGroupSpeechChannels=a.GetAvailableChannels
a.Say=function()end;a.ScanBags=function()return {},{}end;a.SetupMinimap=function()end
ForeverRPDB={chatDestination="local",auto=true,defaultScope='always',globalCooldown=30,globalLastEmoteAt=900,items={
 [118]={enabled=true,lines={'uses the potion.'},sayLines={'A potion!'},outMeLines={'The last potion.'},outOfStockEnabled=true,outputMode='me',librarySchema=1}}}
a:Init();assert(a.db.manualChat==false and a.db.globalLastEmoteAt==900)
for _,entry in ipairs(a.DefaultEntries)do a:SetDefaultDisabled(entry.id,true)end
a.db.manualChat=true;assert(a.db.manualChat)
a:ConfirmedUse(118,nil,111,0)
assert(sends==0 and #opened==0 and a.manualDraft.text=='The last potion.')
a:OpenManualChat();assert(opened[1]=='/emote The last potion.' and a.db.globalLastEmoteAt==900)
a:OpenManualChat();assert(#opened==1,'draft reused')
-- Only matching own echo records the manual send; another player cannot do so.
a:OnChatEcho('CHAT_MSG_EMOTE','The last potion.','Other')
assert(a.db.globalLastEmoteAt==900)
a:OnChatEcho('CHAT_MSG_EMOTE','Tester The last potion.','Tester')
assert(a.db.globalLastEmoteAt==1000 and sends==0)
a:SendForItem(118,nil,false);assert(a.manualDraft==nil,'shared cooldown bypass')
clock=1031;a.db.items[118].outputMode='say';a:SendForItem(118,nil,false)
a:OpenManualChat();assert(opened[2]=='/say A potion!' and sends==0,'manual say outdoors')
clock=1062;a:SendForItem(118,nil,false);clock=1078;a:OpenManualChat();assert(#opened==2,'stale draft opened')
a:SendForItem(118,nil,false);active={};a:OpenManualChat();assert(#opened==2,'existing draft overwritten');active=nil
a:SendForItem(118,nil,false);combat=true;a:OpenManualChat();assert(#opened==2,'combat draft opened');combat=false
a:SendForItem(118,nil,false);a.db.items[118].enabled=false;a:OpenManualChat();assert(#opened==2,'disabled item draft opened');a.db.items[118].enabled=true
a.db.auto=false;a:SendForItem(118,nil,false);assert(not a.manualDraft and sends==0)
a.db.auto=true;a.db.manualChat=false;a:SendForItem(118,nil,false)
assert(not a.manualDraft and sends==0,'automatic say outdoor guard changed')
-- Hearthstone drafts cannot be opened on arrival or after interruption.
a.db.manualChat=true;a.db.items[6948]={enabled=true,outputMode='me',lines={'Departs.'},librarySchema=1}
a.manualDraft={at=clock,itemID=6948,channel='me',text='Departs.'};a.hearthCast={state='cast_completed'}
a:OpenManualChat();assert(#opened==2)
a.manualDraft={at=clock,itemID=6948,channel='me',text='Departs.'};a.hearthCast={state='not_announced'}
a:OpenManualChat();assert(opened[3]=='/emote Departs.' and a.db.hearthLastAnnounceAt==0)
a:OnChatEcho('CHAT_MSG_EMOTE','Tester Departs.','Tester')
assert(a.db.hearthLastAnnounceAt==clock and a.db.globalLastEmoteAt==clock)
print('PASS manual chat: no automated sends, channels, stock replacement, expiry, guards, echo cooldowns')

clock=clock+121
a.manualDraft={at=clock,itemID=118,channel='say',text='A potion!'}
a:OpenManualChat();assert(opened[4]=='/say A potion!')
-- Recheck scope and channel after preparation, including the deferred path.
a.manualDraft={at=clock,itemID=118,channel='say',text='A potion!'}
a.db.items[118].outputMode='me';a:OpenManualChat();assert(#opened==4)
a.db.items[118].outputMode='say'
a.manualDraft={at=clock,itemID=118,channel='say',text='A potion!'}
a.db.items[118].scopeOverride='off';a:OpenManualChat();assert(#opened==4)
-- Explicit manual-mode opt-out survives initialization; enabled mode does too.
a.db.manualChat=false;a:Init();assert(a.db.manualChat==false)
a.db.manualChat=true;a:Init();assert(a.db.manualChat==true)
print('PASS manual chat: deferred slash opening, changed scope/mode, persisted opt-outs')
