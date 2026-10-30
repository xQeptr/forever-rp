local frame={RegisterEvent=function()end,RegisterUnitEvent=function()end,SetScript=function()end}
function CreateFrame()return setmetatable({},{__index=frame})end
SlashCmdList={}
function GetTime()return 1000 end
function time()return 1000 end
function IsInInstance()return true,'party' end
function IsInGroup()return true end
local sent={}
C_ChatInfo={SendChatMessage=function(text,ch)sent[#sent+1]={text,ch}end}
for line in io.lines('ForeverRP/ForeverRP.toc') do
 if line:match('%.lua$')then dofile('ForeverRP/'..line)end
end
local a=ForeverRP
a.SetupMinimap=function()end
a.ScanBags=function()return {},{}end
a.Say=function()end
local function reset(items)
 ForeverRPDB={items=items or {},defaultScope='always',globalCooldown=0}
 a:Init();a.shuffles={};a.libraryPrevious={};sent={}
end
local file,id='Gnome',7
function UnitRace()return 'Localized race',file,id end
local function settings(cat)return {enabled=true,autoCategory=cat,librarySchema=1}end
reset({[118]=settings('potion'),[858]=settings('potion')})
assert(a:GetPlayerRace()=='Gnome')
for _,race in ipairs({{'Human',1},{'Orc',2},{'Dwarf',3},{'NightElf',4},{'Scourge',5},{'Tauren',6},{'Gnome',7},{'Troll',8}})do
 file,id=race[1],race[2];assert(a:GetPlayerRace()==file)
 local _,pool=a:GetLibraryEntries(118,'en','me',false)
 for _,e in ipairs(pool)do assert(e.source==file,'wrong racial pack')end
end
file,id='Draenei',11
local _,noAuthored=a:GetLibraryEntries(118,'en','me',false);assert(#noAuthored==0)
file,id='Gnome',7
local u,r=a:GetLibraryEntries(118,'en','me',false)
assert(#u>0 and #r>=2)
for _,e in ipairs(r)do assert(e.source=='Gnome')end
local gnomeID=r[1].id
file,id='Scourge',5;assert(a:GetPlayerRace()=='Scourge')
local _,forsaken=a:GetLibraryEntries(118,'en','me',false)
for _,e in ipairs(forsaken)do assert(e.source=='Scourge' and e.id~=gnomeID)end
for _,case in ipairs({{'Gnome',5},{'CustomRace',7},{'Gnome',999},{'Unknown',999}})do
 file,id=case[1],case[2];assert(a:GetPlayerRace()==nil)
 local neutral,none=a:GetLibraryEntries(118,'en','me',false);assert(#neutral>0 and #none==0)
end
file,id='Gnome',nil;assert(a:GetPlayerRace()=='Gnome')
local unitRace=UnitRace
UnitRace=function()error('not available')end;assert(a:GetPlayerRace()==nil)
UnitRace=nil;assert(a:GetPlayerRace()==nil)
UnitRace=unitRace
local secret={};issecretvalue=function(v)return rawequal(v,secret)end
file,id=secret,7;assert(a:GetPlayerRace()==nil)
file,id='Gnome',secret;assert(a:GetPlayerRace()==nil)
issecretvalue=nil;file,id='Gnome',7
assert(a.Races.Gnome.color[2]>.6 and a.Races.Gnome.color[3]>.6)
-- Frozen registry integrity, unique IDs, validation and all legacy coverage.
local ids={}
for _,entries in ipairs({a.DefaultEntries,a.RaceEntries})do
 for _,entry in ipairs(entries)do
  assert(not ids[entry.id],'duplicate ID '..entry.id);ids[entry.id]=entry
  local parsed,err=a:ParseLines(entry.text)
  assert(parsed and #parsed==1,entry.id..': '..tostring(err))
 end
end
assert(ids['potion:en:regular:me:universal:legacy-001'].text==a:GetSamplePack('potion','en','me')[1])
for _,cat in ipairs(a.categoryOrder)do
 for _,lang in ipairs({'en','de'})do
  for _,ch in ipairs({'me','say'})do
   for _,text in ipairs(a:GetSamplePack(cat,lang,ch))do
    local found=false
    for _,entry in ipairs(a.DefaultEntries)do
     if entry.category==cat and entry.language==lang and entry.channel==ch and not entry.stock
       and (entry.text==text or entry.legacyText==text)then found=true;break end
    end
    assert(found,'legacy sample lost '..cat..'/'..lang..'/'..ch)
   end
  end
 end
end
-- Reordering the registry must not change a disabled entry's identity.
local target=u[1];a:SetDefaultDisabled(target.id,true)
local before=#a:GetResolvedPhrases(118,'en','me')
a.DefaultEntries[1],a.DefaultEntries[#a.DefaultEntries]=a.DefaultEntries[#a.DefaultEntries],a.DefaultEntries[1]
assert(#a:GetResolvedPhrases(858,'en','me')==before)
for _,item in ipairs({118,858})do
 for _,text in ipairs(a:GetResolvedPhrases(item,'en','me'))do assert(text~=target.text)end
end
assert(#a:GetResolvedPhrases(118,'en','say')>0 and #a:GetResolvedPhrases(118,'en','me',true)>0)
a:Init();assert(a:IsDefaultDisabled(target.id));a:SetDefaultDisabled(target.id,false)
-- Deterministic RNG: exactly 70 universal, 30 racial source draws per cycle.
local random=math.random
local draw=0
math.random=function(n)
 if n==100 then draw=draw%100+1;return draw end
 return n
end
local racial={};for _,e in ipairs(r)do racial[e.text]=true end
local raceCount=0;local previous
for i=1,1000 do
 local text=a:PickLibrary(118,'en','me',false)
 if racial[text]then raceCount=raceCount+1 end
 assert(text~=previous,'immediate repeat');previous=text
end
assert(raceCount==300,'70:30 broken: '..raceCount)
math.random=random
-- Each source deck uses every phrase before cycling.
a.shuffles={};a.libraryPrevious={}
local shuffled,deckLines={},{}
for _,entry in ipairs(u)do deckLines[#deckLines+1]=entry.text end
for i=1,#u do
 local text=a:Pick('deck-check',deckLines,'en','me',false)
 assert(not shuffled[text],'shuffle repeated before deck exhaustion');shuffled[text]=true
end
-- Custom phrases receive tickets and remain in the same effective selection pool.
a:SetCustomPhrases(118,'en','me',{'A fair custom choice.'},false)
math.random=function()return 1 end
assert(a:PickLibrary(118,'en','me',false)=='A fair custom choice.')
math.random=random
a:SetCustomPhrases(118,'en','me',{},false)
-- Known legacy matches remain saved but do not masquerade as customs.
local original={target.text,'My own altered potion text.'}
a.db.items[118].lines=original
local _,_,custom=a:GetLibrarySources(118,'en','me',false)
assert(#custom==1 and custom[1]=='My own altered potion text.')
a:SetDefaultDisabled(target.id,true)
for _,text in ipairs(a:GetResolvedPhrases(118,'en','me'))do assert(text~=target.text)end
assert(a.db.items[118].lines==original)
a:SetCustomPhrases(118,'en','me',{'Replacement custom.'},false)
assert(a.db.items[118].lines[1]==target.text,'ambiguous legacy original deleted')
a:SetCustomPhrases(118,'en','me',{target.text,'Replacement custom.'},false)
local _,_,reclaimed=a:GetLibrarySources(118,'en','me',false)
assert(#reclaimed==2,'explicit identical custom not recoverable')
-- All disabled: no fallback, send, cooldown, or delayed attempt.
for _,e in ipairs(a.DefaultEntries)do a:SetDefaultDisabled(e.id,true)end
for _,e in ipairs(a.RaceEntries)do a:SetDefaultDisabled(e.id,true)end
a.db.items[858].lines={};a.db.globalLastEmoteAt=123
assert(#a:GetResolvedPhrases(858,'en','me')==0)
assert(a:PickLibrary(858,'en','me')==nil)
a:SendForItem(858,nil,false)
assert(#sent==0 and a.db.globalLastEmoteAt==123 and a.last.result=='confirmed_no_phrases_for_language_or_mode')
a:SetCustomPhrases(858,'en','me',{'Only my text.'},false)
a:SendForItem(858,nil,false);assert(#sent==1 and sent[1][1]=='Only my text.')
-- Single-source availability, including unknown race / missing DE racial data.
a:SetDefaultDisabled(target.id,false)
a:SetCustomPhrases(858,'en','me',{},false)
file,id='Unknown',999
assert(a:PickLibrary(858,'en','me')==target.text)
file,id='Gnome',7
a:SetDefaultDisabled(target.id,true);a:SetDefaultDisabled(gnomeID,false)
assert(a:PickLibrary(858,'en','me')==r[1].text)
-- Empty legacy opt-outs, German data, explicit booleans, timestamps and reload.
local de={'Eigener Text.'};local empty={}
reset({[118]={enabled=true,autoCategory='potion',lines=empty,sayLines={'Own say'},deMeLines=de,outOfStockEnabled=false},
 [858]={enabled=true,autoCategory='potion'},
 [859]={enabled=true,autoCategory='potion',lines={'   ',42}},
 [860]={enabled=true,autoCategory='potion',lines={42,'Good custom.'}}})
assert(a.db.items[118].libraryLegacyEmpty.lines==true)
assert(a.db.items[859].libraryLegacyEmpty.lines and #a:GetResolvedPhrases(859,'en','me')==0)
assert(a.db.items[859].lines[2]==42 and not a.db.items[860].libraryLegacyEmpty.lines)
assert(#a:GetResolvedPhrases(118,'en','me')==0)
assert(a.db.items[118].lines==empty and a.db.items[118].deMeLines==de and not a.db.items[118].outOfStockEnabled)
assert(a.db.items[858].outMeLines==nil and #a:GetResolvedPhrases(858,'en','me',true)>0)
a.db.globalLastEmoteAt=333;a.db.hearthLastAnnounceAt=444
a:Init();a:Init()
assert(a.db.globalLastEmoteAt==333 and a.db.hearthLastAnnounceAt==444 and a.db.items[118].deMeLines==de)
a:Remember(999,{name='New potion',autoCategory='potion'})
local cfg=a.db.items[999];assert(not cfg.enabled and cfg.librarySchema==1)
local count=#a:GetResolvedPhrases(999,'en','me');assert(count>0)
a:Init();assert(#a:GetResolvedPhrases(999,'en','me')==count and not cfg.libraryLegacyEmpty)
-- Never offer Last Item Hearthstone defaults, including category overrides.
a.db.items[6948]=settings('hearthstone');a.db.items[998]=settings('hearthstone')
assert(#a:GetResolvedPhrases(6948,'en','me',true)==0 and #a:GetResolvedPhrases(998,'en','me',true)==0)
io.write('PASS library: race isolation, Gnome, unknown/secret, frozen IDs, 70:30, category disables, custom ownership, empty fallback, migration, reload\n')
