local frame={RegisterEvent=function()end,RegisterUnitEvent=function()end,SetScript=function()end}
function CreateFrame()return setmetatable({},{__index=frame})end
SlashCmdList={}
function GetTime()return 1000 end
function time()return 1000 end
local race,class='Scourge','PALADIN'
local raceIDs={Scourge=5,Dwarf=3,Gnome=7,Orc=2,Troll=8,Tauren=6,Human=1,NightElf=4,Skyborne=777}
function UnitRace()return 'Localized',race,raceIDs[race]end
function UnitClass()return 'Localized',class end
for line in io.lines('ForeverRP/ForeverRP.toc')do if line:match('%.lua$')then dofile('ForeverRP/'..line)end end
local a=ForeverRP;a.Say=function()end;a.ScanBags=function()return {},{}end;a.SetupMinimap=function()end
ForeverRPDB={items={[1]={enabled=true,autoCategory='food',librarySchema=1},[2]={enabled=true,autoCategory='drink',librarySchema=1}},defaultScope='group'}
a:Init()
local allIDs,newText={},{}
local newCount=0
local oldText={}
local function normalized(text)return text:lower():gsub('[^%w%s{}]',''):gsub('%s+',' ')end
for _,entries in ipairs({a.DefaultEntries,a.RaceEntries,a.ClassEntries})do
 for _,entry in ipairs(entries)do
  assert(not allIDs[entry.id],'duplicate ID '..entry.id);allIDs[entry.id]=true
  if not entry.id:find(':voice-',1,true)then oldText[normalized(entry.text)]=true end
 end
end
for _,entries in ipairs({a.RaceEntries,a.ClassEntries})do
 for _,entry in ipairs(entries)do
  if entry.id:find(':voice-',1,true)then
   newCount=newCount+1
   local norm=normalized(entry.text)
   assert(not oldText[norm],'new speech duplicates historical content '..entry.id)
   assert(not newText[norm],'duplicate new speech '..entry.id);newText[norm]=true
   assert(entry.channel=='say' and entry.language=='en' and entry.migrationMatch==false)
   assert(entry.text:match('^[A-Z]') and not entry.text:find('[|\r\n]'))
   local valid,err=a:ParseLines(entry.text,string.rep('x',120));assert(valid and #valid==1,entry.id..': '..tostring(err))
   assert(not (entry.category=='hearthstone' and entry.stock))
  end
 end
end
assert(newCount==955,'unexpected curated identity coverage')
-- Every supported original/Skyborne race and all nine classes have useful speech pools.
for r in pairs(raceIDs)do
 race=r
 for c in pairs(a.Classes)do
  class=c
  for _,category in ipairs(a.categoryOrder)do
   a.db.items[1].autoCategory=category
   for _,stock in ipairs({false,true})do
    local u,rr,k=a:GetLibrarySources(1,'en','say',stock)
    if category=='hearthstone' and stock then assert(#u+#rr+#k==0)
    else assert(#u>=2 and #rr>=(stock and 3 or 4) and #k>=(stock and 3 or 4),r..'/'..c..'/'..category)end
   end
  end
 end
end
race,class='Scourge','PALADIN'
-- Cache only the real fixture pools to test the selector at useful statistical scale.
local realSources=a.GetLibrarySources
local function measure(category,stock,missing)
 a.db.items[1].autoCategory=category
 local u,r,k,c=realSources(a,1,'en','say',stock)
 if missing=='race'then r={}elseif missing=='class'then k={}end
 a.GetLibrarySources=function()return u,r,k,c end
 a.libraryPrevious={};a.libraryLastText={};a.shuffles={}
 local counts={universal=0,race=0,class=0}
 local previous
 local n=20000
 for i=1,n do
  local text,source=a:PickLibrary(1,'en','say',stock)
  assert(text~=previous,'immediate repetition');previous=text
  counts[source]=counts[source]+1
 end
 local expected=missing=='race' and {50/70,0,20/70} or missing=='class' and {50/80,30/80,0} or {.5,.3,.2}
 for i,source in ipairs({'universal','race','class'})do assert(math.abs(counts[source]/n-expected[i])<.02,source..' weighting')end
 a.GetLibrarySources=realSources
 return counts
end
math.randomseed(30421)
for _,cat in ipairs({'food','drink','potion'})do for _,stock in ipairs({false,true})do measure(cat,stock)end end
measure('food',false,'race');measure('food',false,'class')
-- Global no-repeat covers switching items, categories and regular/Last Item pools.
a.libraryPrevious={};a.libraryLastText={};a.shuffles={}
local previous
for i=1,150 do
 local id=i%2+1
 local text=a:PickLibrary(id,'en','say',i%3==0)
 assert(text~=previous,'cross-item immediate repeat');previous=text
end
-- Per-entry opt-outs and category overrides still determine the effective source pools.
a.db.items[1].autoCategory='potion'
local u,r,k=realSources(a,1,'en','say',false)
for _,entry in ipairs(a.ClassEntries)do if entry.category=='potion' and entry.channel=='say' and entry.source=='PALADIN' and not entry.stock then a:SetDefaultDisabled(entry.id,true)end end
local _,_,disabled=realSources(a,1,'en','say',false);assert(#disabled==0)
a.db.items[1].categoryOverride='drink'
local _,_,enabled=realSources(a,1,'en','say',false);assert(#enabled>=4)
print('PASS 955 curated identity lines: coverage, originality, byte limits, 50/30/20, missing sources, opt-outs and no-repeat')
