dofile('tests/mock_identity_speech.lua')
local a=ForeverRP
local counts,ids,texts={},{},{}
local n=0
local categories={'food','drink','bufffood','potion','healthstone','elixir','bandage','alcohol','other','hearthstone'}
for _,pool in ipairs({a.DefaultEntries,a.RaceEntries,a.ClassEntries})do
 for _,e in ipairs(pool)do
  assert(not ids[e.id],e.id);ids[e.id]=true
  if e.id:find(':native-0100-',1,true)then
   n=n+1
   assert(e.language=='de' and e.channel=='say' and e.migrationMatch==false)
   assert(not (e.stock and e.category=='hearthstone'))
   assert(not e.text:find('[|\r\n]') and not e.text:find('�',1,true),e.id)
   assert(not texts[e.text],'duplicate German text '..e.id);texts[e.text]=true
   local valid,err=a:ParseLines(e.text,string.rep('x',120));assert(valid and #valid==1,e.id..': '..tostring(err))
   local key=e.source..':'..e.category..':'..tostring(e.stock)
   counts[key]=(counts[key] or 0)+1
  end
 end
end
assert(n==966,'German coverage changed')
for _,source in ipairs({'universal','Human','Orc','Dwarf','NightElf','Scourge','Tauren','Gnome','Troll','Skyborne','WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID'})do
 for _,cat in ipairs(categories)do
  assert((counts[source..':'..cat..':false'] or 0)>=2,source..'/'..cat)
  if cat~='hearthstone'then assert((counts[source..':'..cat..':true'] or 0)>=2,source..'/'..cat..'/last')end
 end
end
function UnitRace()return 'Untoter','Scourge',5 end
function UnitClass()return 'Paladin','PALADIN' end
a.db.defaultDisables={};a.db.items[1]={enabled=true,autoCategory='food',librarySchema=1}
local real=a.GetLibrarySources
for _,stock in ipairs({false,true})do
 local u,r,k,c=real(a,1,'de','say',stock)
 assert(#u>=8 and #r>=2 and #k>=2)
 a.GetLibrarySources=function()return u,r,k,c end
 a.libraryPrevious={};a.libraryLastText={};a.shuffles={}
 local sums={universal=0,race=0,class=0}
 local previous
 math.randomseed(stock and 1010 or 1000)
 for i=1,20000 do
  local text,source=a:PickLibrary(1,'de','say',stock)
  assert(text~=previous,'German immediate repeat');previous=text
  sums[source]=sums[source]+1
 end
 for source,w in pairs({universal=.5,race=.3,class=.2})do assert(math.abs(sums[source]/20000-w)<.02,source)end
 a.GetLibrarySources=real
end
print('PASS 966 German additions: stable IDs, categories/identities, Last Item, uniqueness, UTF-8/link budgets, 50/30/20 and no-repeat')
