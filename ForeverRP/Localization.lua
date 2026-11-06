-- Locale selection is independent from chat destination and saved phrase pools.
local A=ForeverRP
A.LanguageNames={en='English',de='Deutsch'}
local de={}
de[ [==[Language]==] ]=[==[Sprache]==]
de[ [==[Automatic]==] ]=[==[Automatisch]==]
de[ [==[Auto: %s]==] ]=[==[Auto: %s]==]
de[ [==[Language: %s]==] ]=[==[Sprache: %s]==]
de[ [==[English]==] ]=[==[Englisch]==]
de[ [==[Deutsch]==] ]=[==[Deutsch]==]
de[ [==[GLOBAL SETTINGS]==] ]=[==[ALLGEMEINE EINSTELLUNGEN]==]
de[ [==[Enable automatic RP]==] ]=[==[Automatisches RP aktivieren]==]
de[ [==[Send in]==] ]=[==[Ausgabe in]==]
de[ [==[Cooldown]==] ]=[==[Abklingzeit]==]
de[ [==[Show minimap icon]==] ]=[==[Minikartensymbol anzeigen]==]
de[ [==[INVENTORY & SAVED ITEMS]==] ]=[==[INVENTAR & GESPEICHERTE ITEMS]==]
de[ [==[Rescan Bags]==] ]=[==[Taschen prüfen]==]
de[ [==[Find]==] ]=[==[Suche]==]
de[ [==[No matching usable items.]==] ]=[==[Keine passenden Verbrauchsitems.]==]
de[ [==[Click ON/OFF to toggle RP.  --: not in bags]==] ]=[==[AN/AUS schaltet RP um.  --: nicht in den Taschen]==]
de[ [==[Select an item]==] ]=[==[Item auswählen]==]
de[ [==[Select an item from the left]==] ]=[==[Links ein Item auswählen]==]
de[ [==[Category]==] ]=[==[Kategorie]==]
de[ [==[Healthstone]==] ]=[==[Gesundheitsstein]==]
de[ [==[Potion]==] ]=[==[Trank]==]
de[ [==[Drink]==] ]=[==[Getränk]==]
de[ [==[Food]==] ]=[==[Essen]==]
de[ [==[Alcohol (optional RP)]==] ]=[==[Alkohol (optionales RP)]==]
de[ [==[Buff food]==] ]=[==[Stärkende Speise]==]
de[ [==[Elixir / Flask]==] ]=[==[Elixier / Fläschchen]==]
de[ [==[Bandage]==] ]=[==[Verband]==]
de[ [==[Hearthstone / Teleport]==] ]=[==[Ruhestein / Teleport]==]
de[ [==[Other consumable]==] ]=[==[Sonstiges Verbrauchsitem]==]
de[ [==[Other]==] ]=[==[Sonstiges]==]
de[ [==[Groups (all)]==] ]=[==[Gruppen (alle)]==]
de[ [==[Dungeons]==] ]=[==[Dungeons]==]
de[ [==[Raids]==] ]=[==[Schlachtzüge]==]
de[ [==[Disabled]==] ]=[==[Deaktiviert]==]
de[ [==[Use global setting]==] ]=[==[Globale Einstellung]==]
de[ [==[All items]==] ]=[==[Alle Items]==]
de[ [==[In bags]==] ]=[==[In den Taschen]==]
de[ [==[Enabled]==] ]=[==[Aktiviert]==]
de[ [==[No phrases yet]==] ]=[==[Ohne Texte]==]
de[ [==[Not in bags]==] ]=[==[Nicht in den Taschen]==]
de[ [==[Last item RP (1 to 0)]==] ]=[==[RP beim letzten Exemplar (1 auf 0)]==]
de[ [==[Group speech only - channel selected automatically]==] ]=[==[Nur Gruppentext – Chatkanal automatisch]==]
de[ [==[Regular RP]==] ]=[==[Normale Sprüche]==]
de[ [==[Last Item RP]==] ]=[==[Letztes Exemplar]==]
de[ [==[Defaults are active automatically]==] ]=[==[Standardtexte automatisch aktiv]==]
de[ [==[Group speech]==] ]=[==[Gruppentexte]==]
de[ [==[{item} inserts an item link (optional)]==] ]=[==[{item} fügt einen Itemlink ein (optional)]==]
de[ [==[Edit custom phrases]==] ]=[==[Eigene Texte bearbeiten]==]
de[ [==[Custom phrases]==] ]=[==[Eigene Texte]==]
de[ [==[Local Preview]==] ]=[==[Lokale Vorschau]==]
de[ [==[Auto-save after 0.7s. Enter = new phrase; {item} optional.]==] ]=[==[Speichert nach 0,7 s. Enter = neuer Spruch; {item} optional.]==]
de[ [==[Edit preserved matches as own texts]==] ]=[==[Alte Texte als eigene Texte bearbeiten]==]
de[ [==[Valid edits save automatically. Invalid drafts are preserved on reload.]==] ]=[==[Gültige Texte speichern automatisch. Fehlerhafte Entwürfe bleiben erhalten.]==]
de[ [==[Automatic group speech: PARTY / RAID / INSTANCE_CHAT. No output while solo.]==] ]=[==[Automatische Gruppentexte: Gruppe / Schlachtzug / Instanzchat. Solo keine Ausgabe.]==]
de[ [==[Consumption: successful spell + bag decrease. Last item replaces regular RP.]==] ]=[==[Verbrauch: Zaubererfolg + Bestandsabnahme. Letztes Exemplar ersetzt normalen Spruch.]==]
de[ [==[ON]==] ]=[==[AN]==]
de[ [==[OFF]==] ]=[==[AUS]==]
de[ [==[ON = active; OFF = disabled for every item in this category and phrase pool.]==] ]=[==[AN = aktiv; AUS = für alle Items dieser Kategorie und dieses Textpools deaktiviert.]==]
de[ [==[Legacy empty-pool opt-out: click to enable defaults for this item/pool.]==] ]=[==[Alter leerer Textpool: Klicken aktiviert die Standardtexte für diesen Pool.]==]
de[ [==[Recovered unsaved draft. Correct errors to save, or close to discard explicitly.]==] ]=[==[Ungespeicherter Entwurf wiederhergestellt. Fehler beheben oder beim Schließen bewusst verwerfen.]==]
de[ [==[Item selected. Valid edits save automatically.]==] ]=[==[Item ausgewählt. Gültige Änderungen speichern automatisch.]==]
de[ [==[Bags rescanned. No RP emitted.]==] ]=[==[Taschen geprüft. Es wurde kein RP gesendet.]==]
de[ [==[Please enter a phrase.]==] ]=[==[Bitte einen Spruch eingeben.]==]
de[ [==[Preserved matches shown. Saving explicitly claims these as own texts, independent of default disables.]==] ]=[==[Alte Texte angezeigt. Speichern übernimmt sie als eigene Texte, unabhängig von deaktivierten Standardtexten.]==]
de[ [==[Forever RP: Your current text has an error and was not saved. Discard these unsaved changes?]==] ]=[==[Forever RP: Der aktuelle Text enthält einen Fehler und wurde nicht gespeichert. Ungespeicherte Änderungen verwerfen?]==]
de[ [==[Discard changes]==] ]=[==[Änderungen verwerfen]==]
de[ [==[Keep editing]==] ]=[==[Weiter bearbeiten]==]
de[ [==[Correct or discard the current draft before changing language.]==] ]=[==[Bitte den aktuellen Entwurf vor dem Sprachwechsel korrigieren oder bewusst verwerfen.]==]
de[ [==[%d shown / %d remembered]==] ]=[==[%d angezeigt / %d gespeichert]==]
de[ [==[%d seconds]==] ]=[==[%d Sekunden]==]
de[ [==[ID: %d    |    In bags: %d    |    %s]==] ]=[==[ID: %d    |    In den Taschen: %d    |    %s]==]
de[ [==[Detected: %s (%s)]==] ]=[==[Erkannt: %s (%s)]==]
de[ [==[Active: %d general / %d racial / %d class / %d custom.  Mix: %s]==] ]=[==[Aktiv: %d allgemein / %d Volk / %d Klasse / %d eigene.  Mix: %s]==]
de[ [==[custom only]==] ]=[==[nur eigene Texte]==]
de[ [==[%s - %s group speech]==] ]=[==[%s – %s, Gruppentexte]==]
de[ [==[Regular]==] ]=[==[Normal]==]
de[ [==[Last Item]==] ]=[==[Letztes Exemplar]==]
de[ [==[Saved %d %s phrases.]==] ]=[==[%d %s Sprüche gespeichert.]==]
de[ [==[last-item]==] ]=[==[für das letzte Exemplar]==]
de[ [==[regular]==] ]=[==[normale]==]
de[ [==[Cannot switch or save: %s]==] ]=[==[Wechseln oder Speichern nicht möglich: %s]==]
de[ [==[Last-item RP %s. Choose Last Item and add phrases if needed.]==] ]=[==[RP beim letzten Exemplar %s. Texte bei Bedarf unter „Letztes Exemplar“ ergänzen.]==]
de[ [==[enabled]==] ]=[==[aktiviert]==]
de[ [==[disabled]==] ]=[==[deaktiviert]==]
de[ [==[Click: open configuration]==] ]=[==[Klicken: Einstellungen öffnen]==]
de[ [==[Drag: move around minimap]==] ]=[==[Ziehen: Position an der Minikarte ändern]==]
de[ [==[LOCAL group speech preview ONLY: %s]==] ]=[==[NUR LOKALE Vorschau: %s]==]
de[ [==[Automatic group RP enabled]==] ]=[==[Automatisches Gruppen-RP aktiviert]==]
de[ [==[Automatic group RP disabled]==] ]=[==[Automatisches Gruppen-RP deaktiviert]==]
de[ [==[Language options: auto, en, de]==] ]=[==[Sprachauswahl: auto, en, de]==]
de[ [==[item subclass]==] ]=[==[Item-Unterklasse]==]
de[ [==[tooltip (heuristic)]==] ]=[==[Tooltip (Schätzung)]==]
de[ [==[name / tooltip (heuristic)]==] ]=[==[Name / Tooltip (Schätzung)]==]
de[ [==[food & drink subclass (uncertain)]==] ]=[==[Essen-/Getränkeklasse (unsicher)]==]
de[ [==[fallback]==] ]=[==[allgemeine Zuordnung]==]
de[ [==[not yet identified]==] ]=[==[noch nicht erkannt]==]
de[ [==[manual]==] ]=[==[manuell]==]
de[ [==[auto]==] ]=[==[automatisch]==]
de[ [==[use spell]==] ]=[==[Benutzungszauber]==]
de[ [==[item name / use spell]==] ]=[==[Itemname / Benutzungszauber]==]
de[ [==[known Hearthstone item]==] ]=[==[bekannter Ruhestein]==]
de[ [==[Auto]==] ]=[==[Auto]==]
de[ [==[Global group output: %s]==] ]=[==[Globale Gruppenausgabe: %s]==]
de[ [==[v%s loaded. /frp config opens the editor. New items are OFF by default.]==] ]=[==[v%s geladen. /frp config öffnet die Einstellungen. Neue Items sind zunächst AUS.]==]
de[ [==[Line %d: maximum %d phrases per text pool.]==] ]=[==[Zeile %d: höchstens %d Sprüche pro Textpool.]==]
de[ [==[Line %d: maximum 200 bytes per phrase (%d bytes).]==] ]=[==[Zeile %d: höchstens 200 Byte pro Spruch (%d Byte).]==]
de[ [==[Line %d: paste plain text, not item hyperlinks; {item} is optional.]==] ]=[==[Zeile %d: Nur normalen Text einfügen, keine Itemlinks; {item} ist optional.]==]
de[ [==[Line %d: rendered item link makes the message %d bytes (max. 255).]==] ]=[==[Zeile %d: Mit dem Itemlink wird die Nachricht %d Byte lang (höchstens 255).]==]
de[ [==[RP %s for %s. Saved automatically.]==] ]=[==[RP %s für %s. Automatisch gespeichert.]==]
de[ [==[Unknown item]==] ]=[==[Unbekanntes Item]==]
de[ [==[Commands: /frp config | scan | status | minimap on/off | compat | preview | language auto/en/de | auto on/off | groups groups/dungeons/raids/disabled | cooldown 0/15/30/60/120 | debug on/off]==] ]=[==[Befehle: /frp config | scan | status | minimap on/off | compat | preview | language auto/en/de | auto on/off | groups groups/dungeons/raids/disabled | cooldown 0/15/30/60/120 | debug on/off]==]
de[ [==[Click to enable / disable automatic RP for this item]==] ]=[==[Klicken aktiviert oder deaktiviert das automatische RP für dieses Item.]==]
de[ [==[Please wait until login completes.]==] ]=[==[Bitte warten, bis die Anmeldung abgeschlossen ist.]==]
de[ [==[Bag scan complete. %s. /frp config for items.]==] ]=[==[Taschen geprüft. %s. Items unter /frp config.]==]
de[ [==[%d usable consumables found, %d enabled]==] ]=[==[%d nutzbare Verbrauchsitems gefunden, %d aktiviert]==]
de[ [==[Shared RP cooldown set to %ds]==] ]=[==[Gemeinsame RP-Abklingzeit: %d s]==]
de[ [==[Allowed cooldowns: 0, 15, 30, 60, 120 seconds.]==] ]=[==[Mögliche Abklingzeiten: 0, 15, 30, 60, 120 Sekunden.]==]
de[ [==[Group options: groups, dungeons, raids, disabled]==] ]=[==[Gruppenauswahl: groups, dungeons, raids, disabled]==]
de[ [==[Debug enabled]==] ]=[==[Diagnose aktiviert]==]
de[ [==[Debug disabled]==] ]=[==[Diagnose deaktiviert]==]
de[ [==[Minimap button shown]==] ]=[==[Minikartensymbol eingeblendet]==]
de[ [==[Minimap button hidden]==] ]=[==[Minikartensymbol ausgeblendet]==]
de[ [==[No confirmed consumption yet.]==] ]=[==[Noch kein bestätigter Verbrauch.]==]
de[ [==[Auto: %s | Group setting: %s | Last item: %s | Spell: %s | Result: %s | Own echo: %s | Language: %s | Source: %s | Trigger: %s | RP cooldown: %ss | Last stock: %s | Destination: %s]==] ]=[==[Auto: %s | Gruppeneinstellung: %s | Letztes Item: %s | Zauber: %s | Ergebnis: %s | Eigenes Echo: %s | Sprache: %s | Textquelle: %s | Auslöser: %s | RP-Abklingzeit: %ss | Letzter Bestand: %s | Ziel: %s]==]
A.GermanUI=de
function A:L(text,...)
  local value=(self.db and self.db.language=='de' and de[text]) or text
  if select('#',...)>0 then return string.format(value,...) end
  return value
end
function A:BindLocalizedText(widget,key)
  if not key or key=='' then return end
  self.localizedWidgets=self.localizedWidgets or {}
  self.localizedWidgets[#self.localizedWidgets+1]={widget=widget,key=key}
end
function A:DetectedLanguage()
  if type(GetLocale)=='function' then
    local ok,locale=pcall(GetLocale)
    if ok and not (type(issecretvalue)=='function' and issecretvalue(locale)) and locale=='deDE' then return 'de' end
  end
  return 'en'
end
local function backup(db,key,value)
  if type(db.invalidSavedValues)~='table' then db.invalidSavedValues={} end
  db.invalidSavedValues[key]=value
end
function A:SyncLanguageDrafts(previous)
  local db=self.db
  local draft=db.editorDraft
  if type(draft)=='table' and draft.language==nil then draft.language=previous=='de' and 'de' or 'en' end
  if type(db.languageDrafts)~='table' then
    if db.languageDrafts~=nil then backup(db,'languageDrafts',db.languageDrafts) end
    db.languageDrafts={}
  end
  for _,lang in ipairs({'en','de'}) do
    if type(db.languageDrafts[lang])~='table' then
      if db.languageDrafts[lang]~=nil then backup(db,'languageDrafts:'..lang,db.languageDrafts[lang]) end
      db.languageDrafts[lang]={}
    end
  end
  if type(draft)=='table' and (draft.language=='en' or draft.language=='de') and draft.language~=db.language then
    table.insert(db.languageDrafts[draft.language],draft);db.editorDraft=nil
  end
  if db.editorDraft==nil then
    local drafts=db.languageDrafts[db.language]
    if #drafts>0 then db.editorDraft=table.remove(drafts) end
  end
end
function A:InitLanguage()
  local db=self.db
  local previous=db.language
  if db.languageMode==nil then
    -- Historical English was forced by Core; a legacy German choice was explicit.
    db.languageMode=previous=='de' and 'de' or 'auto'
  elseif db.languageMode~='auto' and db.languageMode~='en' and db.languageMode~='de' then
    backup(db,'languageMode',db.languageMode);db.languageMode='auto'
  end
  db.language=db.languageMode=='auto' and self:DetectedLanguage() or db.languageMode
  self:SyncLanguageDrafts(previous)
end
function A:LanguageCaption()
  local selected=self:L(self.LanguageNames[self.db.language] or 'English')
  return self.db.languageMode=='auto' and self:L('Auto: %s',selected) or selected
end
function A:SetLanguageMode(mode)
  if mode~='auto' and mode~='en' and mode~='de' then return false end
  if self.SaveEditor and not self:SaveEditor() then
    self:Say(self:L('Correct or discard the current draft before changing language.'))
    return false
  end
  self.db.languageMode=mode
  self:InitLanguage()
  self.autoSaveRevision=(self.autoSaveRevision or 0)+1
  self.manualDraft=nil;self.lastProbe=nil
  self.shuffles={}
  if self.localizedWidgets then
    for _,entry in ipairs(self.localizedWidgets) do entry.widget:SetText(self:L(entry.key)) end
  end
  if type(StaticPopupDialogs)=='table' and StaticPopupDialogs.FOREVERRP_DISCARD_INVALID then
    local popup=StaticPopupDialogs.FOREVERRP_DISCARD_INVALID
    popup.text=self:L('Forever RP: Your current text has an error and was not saved. Discard these unsaved changes?')
    popup.button1=self:L('Discard changes');popup.button2=self:L('Keep editing')
  end
  if self.textEditor then self:ReloadEditor() end
  if self.configFrame then
    self:RefreshConfig()
    if self.db.editorDraft then self:ShowCustomEditor() end
  end
  return true
end
