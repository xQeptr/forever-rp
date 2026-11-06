dofile('tests/mock_identity_speech.lua')
local a=ForeverRP
local locale='deDE'
GetLocale=function()return locale end
ForeverRPDB={language='en',globalCooldown=60,globalLastEmoteAt=321,items={
 [118]={enabled=true,autoCategory='potion',librarySchema=1,outOfStockEnabled=false,
 lines={'legacy action'},sayLines={'My English text.'},deMeLines={'alter Aktionstext'},
 deSayLines={'Mein deutscher Text.'},outSayLines={'Last English.'},outDeSayLines={'Letzter deutscher Text.'}}
}}
a:Init()
assert(a.db.languageMode=='auto' and a.db.language=='de')
local cfg=a.db.items[118]
local legacy=cfg.lines
assert(cfg.outOfStockEnabled==false and a.db.globalCooldown==60 and a.db.globalLastEmoteAt==321)
assert(a:GetCustomPhrases(118,'de','say')[1]=='Mein deutscher Text.')
local germanID
for _,e in ipairs(a.DefaultEntries)do
 if e.id:find(':native-0100-',1,true) and e.category=='potion' then germanID=e.id;break end
end
a:SetDefaultDisabled(germanID,true)
assert(a:SetLanguageMode('en'))
assert(a.db.language=='en' and a:GetCustomPhrases(118,'en','say')[1]=='My English text.')
locale='deDE';a:Init();assert(a.db.language=='en','manual override lost on reload')
assert(a:SetLanguageMode('auto') and a.db.language=='de')
assert(a:IsDefaultDisabled(germanID) and cfg.lines==legacy and cfg.deMeLines[1]=='alter Aktionstext')
assert(cfg.outSayLines[1]=='Last English.' and cfg.outDeSayLines[1]=='Letzter deutscher Text.')
locale='frFR';a:Init();assert(a.db.language=='en' and a.db.languageMode=='auto')
locale='deDE';a:Init();assert(a.db.language=='de')
ForeverRPDB={language='de',items={}};a:Init()
assert(a.db.languageMode=='de' and a.db.language=='de')
ForeverRPDB={language='en',languageMode={},items={}};a:Init()
assert(a.db.languageMode=='auto' and type(a.db.invalidSavedValues.languageMode)=='table')
GetLocale=nil;assert(a:DetectedLanguage()=='en')
GetLocale=function()error('unavailable')end;assert(a:DetectedLanguage()=='en')
local secret={};GetLocale=function()return secret end
issecretvalue=function(v)return rawequal(v,secret)end
assert(a:DetectedLanguage()=='en');issecretvalue=nil
GetLocale=function()return 'deDE' end
a.db.language='en';a.db.languageMode='auto'
a.db.editorDraft={item=118,tab='last',channel='say',text='invalid EN draft'}
a:InitLanguage()
assert(a.db.editorDraft==nil and a.db.languageDrafts.en[1].text=='invalid EN draft')
assert(a.db.languageDrafts.en[1].language=='en')
a:SetLanguageMode('en')
assert(a.db.editorDraft.text=='invalid EN draft' and #a.db.languageDrafts.en==0)
a:SetLanguageMode('de')
assert(a.db.editorDraft==nil and #a.db.languageDrafts.en==1)
for key in pairs(a.GermanUI)do
 local args={}
 for spec in key:gmatch('%%[sd]')do args[#args+1]=spec=='%d' and 7 or 'sample' end
 local unpackArgs=unpack or table.unpack
 assert(pcall(function()a:L(key,unpackArgs(args))end),key)
end
a.db.language='de'
assert(a:L('GLOBAL SETTINGS')=='ALLGEMEINE EINSTELLUNGEN')
local parsed,err=a:ParseLines(string.rep('ü',101),'item')
assert(not parsed and err:find('202 Byte',1,true),tostring(err))
local before=a.db.globalLastEmoteAt
a:SetLanguageMode('en');a:SetLanguageMode('de')
assert(a.db.globalLastEmoteAt==before)
print('PASS locale: auto/manual/reload, guarded API, legacy data, German validation and language-specific draft recovery')

-- Exercise active group sends with exact independent customs and a shared throttle.
a.SendForItem=a.SendLegacyForItem -- fixture above installed a legacy test alias
dofile('ForeverRP/Emotes.lua')
a.CanSendInContext=a.CanSendGroupInContext or a.CanSendInContext
dofile('ForeverRP/Scopes.lua')
function IsInGroup()return true end
function IsInRaid()return false end
function IsInInstance()return false,'none' end
local clock=1000
function GetTime()return clock end
function time()return clock end
local sent={}
C_ChatInfo={SendChatMessage=function(text,ch)sent[#sent+1]={text,ch}end}
ForeverRPDB={languageMode='de',auto=true,globalCooldown=30,items={
 [118]={enabled=true,autoCategory='potion',librarySchema=1,sayLines={'English regular.'},
 deSayLines={'Deutscher Gruppentext.'},outDeSayLines={'Mein letzter deutscher Trank.'},outOfStockEnabled=true}}}
a:Init()
-- Isolate customs for exact end-to-end language assertions.
for _,pool in ipairs({a.DefaultEntries,a.RaceEntries,a.ClassEntries})do
 for _,e in ipairs(pool)do a:SetDefaultDisabled(e.id,true)end
end
a:SendForItem(118,nil,false)
assert(#sent==1 and sent[1][1]=='Deutscher Gruppentext.' and sent[1][2]=='PARTY')
local stamp=a.db.globalLastEmoteAt
a:SetLanguageMode('en');a:SendForItem(118,nil,false)
assert(#sent==1 and a.db.globalLastEmoteAt==stamp,'language switch bypassed cooldown')
clock=clock+31;a:SendForItem(118,nil,false)
assert(#sent==2 and sent[2][1]=='English regular.')
clock=clock+31;a:SetLanguageMode('de');a:SendForItem(118,nil,true)
assert(#sent==3 and sent[3][1]=='Mein letzter deutscher Trank.')
print('PASS selected-language group sends, German Last Item and shared cooldown across languages')
