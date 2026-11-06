dofile('tests/mock_group_ui.lua')
dofile('ForeverRP/QuestItems.lua')
local a=ForeverRP
local selected=a.selectedID
local text=a.textEditor:GetText()
local original=a.db.items[selected]
local pool=original.outSayLines
C_Item={GetItemInfoInstant=function(id)return id,nil,nil,nil,nil,id==selected and 12 or 0,1 end}
a:RefreshConfig()
assert(a.selectedID==nil and not a.editorDirty)
assert(a.db.items[selected]==original and original.outSayLines==pool)
assert(#a.db.questEditorDrafts==1 and a.db.questEditorDrafts[1].text==text)
for _,row in ipairs(a:ConfigItems())do assert(row.id~=selected)end
a:SelectItem(selected);assert(a.selectedID==nil,'hidden quest item selectable')
print('PASS quest UI: removed selection, hidden rows and archived invalid draft without changing player pools')
