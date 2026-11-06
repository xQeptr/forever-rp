dofile('tests/mock_ui.lua')
local a=ForeverRP
dofile('ForeverRP/Localization.lua')
a.editorDirty=false;a.db.editorDraft=nil;a.db.languageMode='auto'
GetLocale=function()return 'deDE' end
a:InitLanguage();a.selectedID=nil;a:BuildConfig();a:SelectItem(118)
assert(a.languageDropdown._caption=='Auto: Deutsch')
local function labels()
 local result={}
 for _,entry in ipairs(a.localizedWidgets)do result[entry.key]=entry.widget:GetText()end
 return result
end
assert(labels()['GLOBAL SETTINGS']=='ALLGEMEINE EINSTELLUNGEN')
local function choose(value)
 local seen={}
 a.languageDropdown._menu(nil,{CreateRadio=function(_,label,checked,select,key)
  seen[key]=label;if key==value then select(key)end
 end})
 return seen
end
local opts=choose('en')
assert(opts.auto=='Automatisch' and opts.en=='Englisch' and opts.de=='Deutsch')
assert(a.db.language=='en' and labels()['GLOBAL SETTINGS']=='GLOBAL SETTINGS')
a:SwitchTab('regular');a:ShowCustomEditor()
a.textEditor:SetText('My saved English.');a.textEditor._script_OnTextChanged(a.textEditor)
choose('de')
assert(a.db.items[118].sayLines[1]=='My saved English.','switch did not flush English text')
assert(a.editorLanguage=='de' and a.textEditor:GetText()~='My saved English.')
a.textEditor:SetText('Mein eigener deutscher Spruch.');a.textEditor._script_OnTextChanged(a.textEditor)
choose('en')
assert(a.db.items[118].deSayLines[1]=='Mein eigener deutscher Spruch.')
assert(a.textEditor:GetText()=='My saved English.')
a.textEditor:SetText(string.rep('ü',101));a.textEditor._script_OnTextChanged(a.textEditor)
choose('de')
assert(a.db.language=='en' and a.editorLanguage=='en' and a.editorDirty)
assert(a.textEditor:GetText()==string.rep('ü',101) and a.db.editorDraft.language=='en')
StaticPopupDialogs.FOREVERRP_DISCARD_INVALID.OnAccept()
choose('de')
assert(a.db.language=='de' and a.textEditor:GetText()=='Mein eigener deutscher Spruch.')
assert(labels()['Edit custom phrases']=='Eigene Texte bearbeiten')
assert(a.itemMeta:GetText():find('Deutsch',1,true))
local valid,err=a:ParseLines(string.rep('ü',101),'item')
assert(not valid and err:find('Zeile 1',1,true))
choose('auto');assert(a.db.languageMode=='auto' and a.languageDropdown._caption=='Auto: Deutsch')
GetLocale=function()return 'enGB' end
a:InitLanguage();a:BuildConfig();a:SelectItem(118)
assert(a.db.language=='en' and a.languageDropdown._caption=='Auto: English')
assert(a.db.items[118].sayLines[1]=='My saved English.' and a.db.items[118].deSayLines[1]=='Mein eigener deutscher Spruch.')
print('PASS bilingual UI: dropdown labels, live translation, autosave, invalid-draft blocking and reload')
