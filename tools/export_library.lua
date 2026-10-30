-- lua tools/export_library.lua | python3 tools/audit_library.py
ForeverRP={}
dofile('ForeverRP/DefaultLibrary.lua')
dofile('ForeverRP/RaceLibrary.lua')
dofile('ForeverRP/EditorialLibrary.lua')
for _,pool in ipairs({ForeverRP.DefaultEntries,ForeverRP.RaceEntries}) do
 for _,e in ipairs(pool) do
  io.write(table.concat({e.id,e.category,e.source,e.language,e.channel,
   e.stock and 'last' or 'regular',e.text},'\t')..'\n')
 end
end
