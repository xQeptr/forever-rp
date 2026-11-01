-- Shared immutable defaults + per-item custom text. No import/materialization.
local A=ForeverRP
local regular={en_me='lines',en_say='sayLines',de_me='deMeLines',de_say='deSayLines'}
local last={en_me='outMeLines',en_say='outSayLines',de_me='outDeMeLines',de_say='outDeSayLines'}
function A:PhraseField(lang,ch,stock)
  return (stock and last or regular)[(lang=='de' and 'de' or 'en')..'_'..(ch=='say' and 'say' or 'me')]
end
function A:InitLibrary()
  local db=self.db
  if type(db.defaultDisabled)~='table' then
    if db.defaultDisabled~=nil then db.invalidSavedValues.defaultDisabled=db.defaultDisabled end
    db.defaultDisabled={}
  end
  -- Only existing explicit empty pools imply a legacy per-item opt-out.
  -- Record once before inventory discovery creates new empty custom pools.
  for _,cfg in pairs(db.items) do
    if type(cfg)=='table' and cfg.librarySchema==nil then
      local empty=type(cfg.libraryLegacyEmpty)=="table" and cfg.libraryLegacyEmpty or {}
      for _,language in ipairs({'en','de'}) do
        for _,channel in ipairs({'me','say'}) do
          for _,stock in ipairs({false,true}) do
            local field=self:PhraseField(language,channel,stock)
            if type(cfg[field])=='table' and #self:GetPhrases(cfg,language,channel,stock)==0 then empty[field]=true end
          end
        end
      end
      cfg.libraryLegacyEmpty=empty
      cfg.librarySchema=1
    end
  end
end
function A:GetLibraryEntries(id,lang,ch,stock)
  local category=self:GetCategory(id)
  if stock and (id==6948 or category=='hearthstone') then return {},{},{} end
  local race=self:GetPlayerRace()
  local class=self.GetPlayerClass and self:GetPlayerClass() or nil
  local universal,racial,classes={},{},{}
  for _,entries in ipairs({self.DefaultEntries,self.RaceEntries,self.ClassEntries or {}}) do
    for _,entry in ipairs(entries) do
      if entry.category==category and entry.language==lang and entry.channel==ch
        and entry.stock==not not stock then
        if entry.source=='universal' then universal[#universal+1]=entry
        elseif race and entry.source==race then racial[#racial+1]=entry
        elseif class and entry.source==class then classes[#classes+1]=entry end
      end
    end
  end
  return universal,racial,classes
end
function A:SetDefaultDisabled(id,disabled)
  if type(self.db.defaultDisabled)~='table' then self.db.defaultDisabled={} end
  self.db.defaultDisabled[id]=disabled and true or nil
  self.shuffles={}
end
function A:IsDefaultDisabled(id)
  return type(self.db.defaultDisabled)=='table' and self.db.defaultDisabled[id]==true
end
function A:GetLibrarySources(id,lang,ch,stock)
  local cfg=self:GetSettings(id)
  if not cfg then return {},{},{},{} end
  local field=self:PhraseField(lang,ch,stock)
  local u,r,k=self:GetLibraryEntries(id,lang,ch,stock)
  local universal,racial,classes,custom={},{},{},{}
  local known={}
  -- Match every historical category, so a category override cannot turn an
  -- imported sample into an ungoverned custom phrase. Saved text is untouched.
  for _,e in ipairs(self.DefaultEntries) do
    if e.migrationMatch~=false and e.language==lang and e.channel==ch and e.stock==not not stock then known[e.text]=true; if e.legacyText then known[e.legacyText]=true end end
  end
  local owned=type(cfg.libraryCustom)=='table' and cfg.libraryCustom[field]
  for _,text in ipairs(self:GetPhrases(cfg,lang,ch,stock)) do
    if not known[text] or (type(owned)=='table' and owned[text]==true) then custom[#custom+1]=text end
  end
  local empty=type(cfg.libraryLegacyEmpty)=='table' and cfg.libraryLegacyEmpty[field]
  if not empty then
    for _,e in ipairs(u) do if not self:IsDefaultDisabled(e.id) then universal[#universal+1]=e.text end end
    for _,e in ipairs(r) do if not self:IsDefaultDisabled(e.id) then racial[#racial+1]=e.text end end
    for _,e in ipairs(k) do if not self:IsDefaultDisabled(e.id) then classes[#classes+1]=e.text end end
  end
  -- Explicit custom ownership can intentionally duplicate a default: emit it
  -- once per pool, still respecting a default's disable flag unless reclaimed.
  local seen={}
  for _,text in ipairs(custom) do seen[text]=true end
  for _,pool in ipairs({universal,racial,classes}) do
    for n=#pool,1,-1 do if seen[pool[n]] then table.remove(pool,n) else seen[pool[n]]=true end end
  end
  return universal,racial,classes,custom
end
function A:GetResolvedPhrases(id,lang,ch,stock)
  local result={}
  local u,r,k,c=self:GetLibrarySources(id,lang,ch,stock)
  for _,pool in ipairs({u,r,k,c}) do for _,line in ipairs(pool) do result[#result+1]=line end end
  return result
end
function A:GetCustomPhrases(id,lang,ch,stock)
  local _,_,_,custom=self:GetLibrarySources(id,lang,ch,stock)
  return custom
end
function A:PickLibrary(id,lang,ch,stock)
  local u,r,k,c=self:GetLibrarySources(id,lang,ch,stock)
  local defaults=#u+#r+#k
  -- Each custom phrase has the same aggregate chance as one default phrase.
  -- Conditional on choosing defaults, preserve the 70:30 source split.
  local pool,source
  if #c>0 and (defaults==0 or math.random(defaults+#c)<=#c) then pool,source=c,'custom'
  else
    local choices={{u,'universal',50},{r,'race',30},{k,'class',20}}
    local total=0
    for _,v in ipairs(choices) do if #v[1]>0 then total=total+v[3] end end
    if total>0 then
      local draw=math.random(total)
      for _,v in ipairs(choices) do if #v[1]>0 then draw=draw-v[3];if draw<=0 then pool,source=v[1],v[2];break end end end
    end
  end
  if not pool then return nil end
  local key=tostring(id)..':'..lang..':'..ch..':'..tostring(not not stock)
  self.libraryPrevious=self.libraryPrevious or {}
  local previous=self.libraryPrevious[key]
  -- If users leave only one line in a source, no-repeat takes precedence when
  -- another source is available. Normal shipped racial pools have >=2 lines.
  if #pool==1 and pool[1]==previous then
    for _,candidate in ipairs({{u,'universal'},{r,'race'},{k,'class'},{c,'custom'}}) do
      if #candidate[1]>0 and (#candidate[1]>1 or candidate[1][1]~=previous) then
        pool,source=candidate[1],candidate[2];break
      end
    end
  end
  local line=self:Pick(tostring(id)..':'..source,pool,lang,ch,stock,previous)
  self.libraryPrevious[key]=line
  return line
end

-- Editing custom text never deletes unproven legacy imports from SavedVariables.
function A:SetCustomPhrases(id,lang,ch,lines,stock)
  local cfg=self:GetSettings(id)
  local field=self:PhraseField(lang,ch,stock)
  local known={}
  for _,entry in ipairs(self.DefaultEntries) do
    if entry.migrationMatch~=false and entry.language==lang and entry.channel==ch and entry.stock==not not stock then known[entry.text]=true; if entry.legacyText then known[entry.legacyText]=true end end
  end
  local merged,entered={},{}
  for _,line in ipairs(lines) do entered[line]=true end
  local owned=type(cfg.libraryCustom)=='table' and cfg.libraryCustom[field]
  local raw=type(cfg[field])=='table' and cfg[field] or {}
  for _,line in ipairs(raw) do
    if type(line)=='string' and known[line] and not entered[line]
      and not (type(owned)=='table' and owned[line]) then merged[#merged+1]=line end
  end
  if type(cfg.libraryCustom)~='table' then cfg.libraryCustom={} end
  cfg.libraryCustom[field]={}
  for _,line in ipairs(lines) do
    merged[#merged+1]=line
    if known[line] then cfg.libraryCustom[field][line]=true end
  end
  self:SetPhrases(cfg,lang,ch,merged,stock)
  self.shuffles={}
end
