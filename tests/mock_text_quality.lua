-- New editorial content has stronger rules; historical wording stays frozen.
dofile('tests/mock_library.lua')
local a=ForeverRP
local entries,old,new={},{},{}
for _,pool in ipairs({a.DefaultEntries,a.RaceEntries}) do
 for _,e in ipairs(pool) do
  entries[#entries+1]=e
  if e.id:find(':editorial-',1,true) then new[#new+1]=e else old[#old+1]=e end
 end
end
table.sort(old,function(x,y)return x.id<y.id end)
local hash=0
for _,e in ipairs(old) do
 local s=table.concat({e.id,e.category,e.language,tostring(e.stock),e.channel,e.source,e.text,e.legacyText or ''},'\t')..'\n'
 for i=1,#s do hash=(hash*31+s:byte(i))%2147483647 end
end
assert(#old==1968 and hash==1113376397,'historical IDs, text or metadata changed')
assert(#new>=150,'editorial coverage unexpectedly missing')
local function normalized(s)
 return s:lower():gsub('{item}',' ITEM '):gsub('[^%w%s]',''):gsub('%s+',' ')
end
local exact={}
for _,e in ipairs(old) do exact[normalized(e.text)]=true end
local link='|cffffffff|Hitem:3382::::::::80:250:::::::::|h[Weak Troll\'s Blood Elixir]|h|r'
local counts={}
local function tokens(text)
 local set,n={},0
 for word in normalized(text):gmatch('%w+') do
  if word~='item' and not set[word] then set[word]=true;n=n+1 end
 end
 return set,n
end
local tokenized={}
for _,e in ipairs(entries) do
 local words,n=tokens(e.text);tokenized[e]={words=words,n=n}
end
for _,e in ipairs(new) do
 assert(e.language=='en' and not (e.category=='hearthstone' and e.stock),e.id)
 assert(e.migrationMatch==false,'new content must not become legacy import matches')
 assert(not exact[normalized(e.text)],'duplicate editorial text '..e.id)
 exact[normalized(e.text)]=true
 local parsed,err=a:ParseLines(e.text,link)
 assert(parsed and #parsed==1,e.id..': '..tostring(err))
 local expanded=e.text:gsub('{item}',function()return string.rep('x',120) end)
 assert(#expanded<=255,'120-byte item-link budget exceeded '..e.id)
 assert(not e.text:find('[\r\n|]') and not e.text:find('/me',1,true) and not e.text:find('/say',1,true),e.id)
 local lower=' '..e.text:lower()..' '
 for _,pronoun in ipairs({'he','his','him','she','her','hers'}) do
  assert(not lower:find('%f[%a]'..pronoun..'%f[%A]'),'gender assumption '..e.id)
 end
 if e.channel=='me' then
  assert(e.text:match('^[a-z]') and not e.text:find('"',1,true),'action grammar '..e.id)
 else
  assert(e.text:match('^[A-Z{]') and not e.text:find('"',1,true),'speech grammar '..e.id)
 end
 local key=table.concat({e.category,e.source,e.channel,e.stock and 'last' or 'regular'},'/')
 counts[key]=(counts[key] or 0)+1
 local left=tokenized[e]
 for _,other in ipairs(entries) do
  local right=tokenized[other]
  if e~=other and e.language==other.language and left.n>=5 and right.n>=5 then
   local common=0
   for word in pairs(left.words) do if right.words[word] then common=common+1 end end
   assert(common/(left.n+right.n-common)<.75,'near duplicate '..e.id..' / '..other.id)
  end
 end
end
-- Reload and category-wide disable retain new IDs; identical existing customs
-- remain visible and editable even when that new default is switched off.
local sample
for _,e in ipairs(new) do if e.source=='universal' and e.channel=='me' and not e.stock then sample=e;break end end
assert(sample)
a.db.items[3382]={enabled=true,autoCategory=sample.category,librarySchema=1,lines={sample.text}}
a.db.items[3383]={enabled=true,autoCategory=sample.category,librarySchema=1}
a:SetDefaultDisabled(sample.id,true);a:Init();a:Init()
assert(a:IsDefaultDisabled(sample.id))
assert(a:GetCustomPhrases(3382,'en','me')[1]==sample.text,'new default swallowed existing custom')
for _,text in ipairs(a:GetResolvedPhrases(3383,'en','me')) do assert(text~=sample.text) end
a:SetCustomPhrases(3382,'en','me',{},false)
assert(#a.db.items[3382].lines==0,'new matching custom cannot be deleted')
io.write('PASS editorial: frozen 1968-entry fingerprint, unique text, channel grammar, gender, link budget, new opt-outs and existing custom ownership\n')
