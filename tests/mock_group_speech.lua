dofile('tests/mock_group_chat.lua')
local a=ForeverRP
local counts,ids,texts={},{},{}
local link=string.rep('x',120)
local total=0
for _,entry in ipairs(a.DefaultEntries)do
 assert(not ids[entry.id],'duplicate library ID');ids[entry.id]=true
 if entry.id:find(':group-speech-',1,true)then
  total=total+1
  assert(entry.channel=='say' and entry.language=='en' and entry.migrationMatch==false)
  assert(entry.text:match('^[A-Z]') and not entry.text:find('[|\r\n]'))
  local valid,err=a:ParseLines(entry.text,link);assert(valid and #valid==1,tostring(err))
  assert(#entry.text:gsub('{item}',function()return link end)<=255)
  assert(not texts[entry.text],'repeated new phrase');texts[entry.text]=true
  local key=entry.category..':'..tostring(entry.stock);counts[key]=(counts[key] or 0)+1
 end
end
assert(total==192)
for _,category in ipairs({'food','drink','potion','healthstone','bufffood','elixir','bandage','alcohol','other'})do
 assert(counts[category..':false']==12 and counts[category..':true']==8,category)
end
assert(counts['hearthstone:false']==12 and counts['hearthstone:true']==nil)
print('PASS 192 unique group speech additions: categories, Last Item, stable IDs and byte budgets')
