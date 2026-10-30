-- Forever RP v0.9.17: cursor-follow scrolling in multiline RP editor.
-- Global settings above the persistent inventory; item controls and real-looking tabs on right.
-- Combat triggers, item verification, throttling and saved variable field names unchanged.
local A = ForeverRP
local ROW_HEIGHT = 34
local ITEM_WIDTH = 258

local function label(parent, text, x, y, font)
  local fs = parent:CreateFontString(nil, 'OVERLAY', font or 'GameFontHighlightSmall')
  fs:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
  fs:SetText(text or '')
  return fs
end
-- No red UI-Panel button textures: use slate, subtle bronze edges and golden text.
local function surface(parent, x, y, w, h, fill, border)
  local bg = parent:CreateTexture(nil, 'BACKGROUND')
  bg:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
  bg:SetSize(w, h)
  bg:SetColorTexture(fill[1], fill[2], fill[3], fill[4] or 1)
  local function edge(dx, dy, ew, eh)
    local tex=parent:CreateTexture(nil,'BORDER')
    tex:SetPoint('TOPLEFT',parent,'TOPLEFT',x+dx,y+dy)
    tex:SetSize(ew,eh)
    tex:SetColorTexture(border[1],border[2],border[3],border[4] or 1)
  end
  edge(0,0,w,1); edge(0,-h+1,w,1); edge(0,0,1,h); edge(w-1,0,1,h)
  return bg
end
local function button(parent, text, width, height, x, y, callback)
  local b=CreateFrame('Button',nil,parent)
  b:SetSize(width,height)
  b:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y)
  b.background=b:CreateTexture(nil,'BACKGROUND')
  b.background:SetAllPoints(b)
  b.background:SetColorTexture(.19,.24,.29,.97)
  local rim=b:CreateTexture(nil,'BORDER')
  rim:SetPoint('TOPLEFT',b,'TOPLEFT',0,0)
  rim:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',0,0)
  rim:SetColorTexture(.43,.37,.26,.65)
  b.rim=rim
  local inner=b:CreateTexture(nil,'ARTWORK')
  inner:SetPoint('TOPLEFT',b,'TOPLEFT',1,-1)
  inner:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',-1,1)
  inner:SetColorTexture(.19,.24,.29,.98)
  b.inner=inner
  local caption=b:CreateFontString(nil,'OVERLAY','GameFontNormalSmall')
  caption:SetPoint('CENTER')
  caption:SetText(text or '')
  caption:SetTextColor(.97,.81,.54)
  b:SetFontString(caption)
  b:SetScript('OnEnter',function(self) self.inner:SetColorTexture(.25,.33,.39,1) end)
  b:SetScript('OnLeave',function(self) self.inner:SetColorTexture(.19,.24,.29,.98) end)
  if callback then b:SetScript('OnClick',callback) end
  return b
end
-- Actual selectable tabs: selected page joins the blue/slate content area.
local function navTab(parent, title, x, y, w, h, callback, compact)
  local b=CreateFrame('Button',nil,parent)
  b:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y)
  b:SetSize(w,h)
  local bg=b:CreateTexture(nil,'BACKGROUND')
  bg:SetAllPoints(b)
  local line=b:CreateTexture(nil,'ARTWORK')
  line:SetPoint('BOTTOMLEFT',b,'BOTTOMLEFT',0,0)
  line:SetPoint('BOTTOMRIGHT',b,'BOTTOMRIGHT',0,0)
  line:SetHeight(compact and 2 or 3)
  local caption=b:CreateFontString(nil,'OVERLAY',compact and 'GameFontNormalSmall' or 'GameFontNormal')
  caption:SetPoint('CENTER',b,'CENTER',0,1)
  caption:SetText(title)
  b._selected=false
  function b:SetSelected(yes)
    self._selected=not not yes
    if yes then
      bg:SetColorTexture(.20,.31,.40,1)
      line:SetColorTexture(.24,.78,.82,1)
      caption:SetTextColor(1,.85,.53)
    else
      bg:SetColorTexture(.12,.17,.23,.87)
      line:SetColorTexture(.45,.37,.23,.40)
      caption:SetTextColor(.68,.75,.79)
    end
  end
  b:SetSelected(false)
  b:SetScript('OnEnter',function(self)
    if not self._selected then bg:SetColorTexture(.23,.29,.36,.99) end
  end)
  b:SetScript('OnLeave',function(self)
    if not self._selected then bg:SetColorTexture(.12,.17,.23,.87) end
  end)
  b:SetScript('OnClick',callback)
  return b
end
local function nameFor(id, cfg, meta)
  return (meta and meta.name) or cfg.name or ('Item ' .. tostring(id))
end
local function formatLines(lines)
  return table.concat(lines or {}, '\n')
end
local function fitName(fontString, raw, limit, measurer)
  raw = tostring(raw or '')
  measurer = measurer or fontString
  measurer:SetText(raw)
  local widthOf = measurer.GetUnboundedStringWidth or measurer.GetStringWidth
  if not widthOf or widthOf(measurer) <= limit then
    fontString:SetText(raw)
    return
  end
  local chars, pos = {}, 1
  while pos <= #raw do
    local b = raw:byte(pos)
    local n = (b < 128 and 1) or (b < 224 and 2) or (b < 240 and 3) or 4
    chars[#chars + 1] = raw:sub(pos, pos + n - 1)
    pos = pos + n
  end
  local low, high, best = 0, #chars, '...'
  while low <= high do
    local mid = math.floor((low + high) / 2)
    local candidate = table.concat(chars, '', 1, mid) .. '...'
    measurer:SetText(candidate)
    if widthOf(measurer) <= limit then
      best, low = candidate, mid + 1
    else
      high = mid - 1
    end
  end
  fontString:SetText(best)
end
local function dropdown(parent, x, y, width, placeholder, entries, choose, current)
  local result, ok
  ok, result = pcall(CreateFrame, 'DropdownButton', nil, parent, 'WowStyle1DropdownTemplate')
  if ok and result and type(result.SetupMenu) == 'function' then
    result:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    result:SetSize(width, 28)
    result:SetDefaultText(placeholder)
    result:SetupMenu(function(_, root)
      for _, entry in ipairs(entries()) do
        local key = entry.key
        root:CreateRadio(entry.label, function(value) return current() == value end,
          function(value) choose(value) end, key)
      end
    end)
    result.SetCaption = function(self, text)
      if self.OverrideText then self:OverrideText(text) end
    end
  else
    result = button(parent, placeholder, width, 25, x, y, function(owner)
      if not (MenuUtil and MenuUtil.CreateContextMenu) then return end
      MenuUtil.CreateContextMenu(owner, function(_, root)
        for _, entry in ipairs(entries()) do
          local key = entry.key
          root:CreateRadio(entry.label, function(value) return current() == value end,
            function(value) choose(value) end, key)
        end
      end)
    end)
    result.SetCaption = function(self, text) self:SetText(text) end
  end
  return result
end
local function attachItemTooltip(row)
  if not GameTooltip then return end
  GameTooltip:SetOwner(row, 'ANCHOR_RIGHT')
  local meta = row.itemID and A.inventory[row.itemID]
  if meta and meta.link then
    GameTooltip:SetHyperlink(meta.link)
  else
    GameTooltip:SetText(row.fullName or 'Unknown item')
  end
  GameTooltip:Show()
end

function A:ConfigItems()
  local output = {}
  local query = (self.searchQuery or ''):lower()
  local filter = self.itemFilter or 'all'
  for id, cfg in pairs(self.db.items) do
    local meta = self.inventory[id]
    local title = nameFor(id, cfg, meta)
    local anyPhrases = false
    for _, language in ipairs({'en', 'de'}) do
      for _, channel in ipairs({'me', 'say'}) do
        if #self:GetResolvedPhrases(id, language, channel) > 0
          or #self:GetResolvedPhrases(id, language, channel, true) > 0 then
          anyPhrases = true
        end
      end
    end
    local count = meta and meta.count or 0
    local include = filter == 'all'
      or (filter == 'enabled' and cfg.enabled)
      or (filter == 'disabled' and not cfg.enabled)
      or (filter == 'unconfigured' and not anyPhrases)
      or (filter == 'inbags' and count > 0)
      or (filter == 'saved' and count == 0)
    if include and (query == '' or title:lower():find(query, 1, true)
      or tostring(id):find(query, 1, true)) then
      output[#output + 1] = {id=id, cfg=cfg, meta=meta, title=title, count=count}
    end
  end
  table.sort(output, function(a, b)
    if (a.count > 0) ~= (b.count > 0) then return a.count > 0 end
    if a.title ~= b.title then return a.title < b.title end
    return a.id < b.id
  end)
  return output
end
function A:CountRemembered()
  local n = 0
  for _ in pairs(self.db.items) do n = n + 1 end
  return n
end
function A:ToggleItemEnabled(id)
  local cfg=self.db and self.db.items[id]
  if not cfg then return end
  cfg.enabled=not cfg.enabled
  if cfg.enabled then
    if id==6948 then
      cfg.outOfStockEnabled=false
    elseif cfg.outOfStockEnabled==nil then
      cfg.outOfStockEnabled=true
    end
  end
  self:RefreshConfig()
  if self.editorStatus then self.editorStatus:SetText('RP '..(cfg.enabled and 'enabled' or 'disabled')..' for '..nameFor(id,cfg,self.inventory[id])..'. Saved automatically.') end
end
function A:NewInventoryRow(parent, index)
  local row = button(parent, '', ITEM_WIDTH, ROW_HEIGHT - 2, 0, -(index-1)*ROW_HEIGHT, function(self)
    if self.itemID then A:SelectItem(self.itemID) end
  end)
  -- The left ON/OFF segment is a real button, independently clickable
  -- without selecting the row or opening another checkbox in item details.
  row.status=CreateFrame('Button',nil,row)
  row.status:SetSize(34,ROW_HEIGHT-4)
  row.status:SetPoint('LEFT',row,'LEFT',2,0)
  row.statusShade=row.status:CreateTexture(nil,'BACKGROUND')
  row.statusShade:SetAllPoints(row.status)
  row.statusShade:SetColorTexture(.09,.14,.18,.94)
  row.statusText=row.status:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
  row.statusText:SetPoint('CENTER',row.status,'CENTER',0,0)
  row.statusText:SetWidth(32)
  row.status:SetScript('OnClick',function()
    if row.itemID then A:ToggleItemEnabled(row.itemID) end
  end)
  row.status:SetScript('OnEnter',function()
    row.statusShade:SetColorTexture(.25,.33,.41,.99)
    if GameTooltip then
      GameTooltip:SetOwner(row.status,'ANCHOR_RIGHT')
      GameTooltip:SetText('Click to enable / disable automatic RP for this item')
      GameTooltip:Show()
    end
  end)
  row.status:SetScript('OnLeave',function()
    row.statusShade:SetColorTexture(.09,.14,.18,.94)
    if GameTooltip then GameTooltip:Hide() end
  end)
  -- Keep icon above the row's hover/selected ARTWORK fill.
  row.icon = row:CreateTexture(nil, 'OVERLAY', nil, 3)
  row.icon:SetDrawLayer('OVERLAY', 3)
  row.icon:SetSize(18, 18)
  row.icon:SetPoint('LEFT', row, 'LEFT', 34, 0)
  row.name = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  row.name:SetPoint('LEFT', row, 'LEFT', 58, 0)
  row.name:SetWidth(142)
  row.name:SetJustifyH('LEFT')
  if row.name.SetWordWrap then row.name:SetWordWrap(false) end
  if row.name.SetMaxLines then row.name:SetMaxLines(1) end
  row.measurer = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  row.measurer:Hide()
  row.quantity = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  row.quantity:SetPoint('RIGHT', row, 'RIGHT', -7, 0)
  row.quantity:SetWidth(39)
  row.quantity:SetJustifyH('RIGHT')
  row.activeLine=row:CreateTexture(nil,'OVERLAY')
  row.activeLine:SetPoint('TOPLEFT',row,'TOPLEFT',0,-1)
  row.activeLine:SetSize(3,ROW_HEIGHT-4)
  function row:SetSelected(yes)
    if yes then
      self.inner:SetColorTexture(.18,.33,.43,1)
      self.activeLine:SetColorTexture(.22,.79,.85,1)
    else
      self.inner:SetColorTexture(.14,.20,.26,.96)
      self.activeLine:SetColorTexture(.38,.33,.24,.5)
    end
  end
  row:SetSelected(false)
  row:SetScript('OnEnter', function(self)
    self.inner:SetColorTexture(.23,.35,.44,1)
    attachItemTooltip(self)
  end)
  row:SetScript('OnLeave', function(self)
    self:SetSelected(self.itemID==A.selectedID)
    if GameTooltip then GameTooltip:Hide() end
  end)
  return row
end

-- The existing saved fields are kept exactly as in v0.9.12:
--  lines, sayLines, outMeLines, outSayLines; no data migration required.
-- One draft is enough: invalid input blocks every context change.
-- Persist it immediately so /reload cannot silently discard an invalid edit.
function A:RememberEditorDraft()
  if self.selectedID and self.editorDirty then
    self.db.editorDraft={item=self.selectedID,tab=self.activeTab,channel=self.activeChannel,text=self.textEditor:GetText()}
  end
end
function A:ShowCustomEditor()
  local draft=self.db.editorDraft
  if type(draft)=='table' and type(draft.item)=='number' and self.db.items[draft.item]
    and type(draft.text)=='string' and (draft.tab=='regular' or draft.tab=='last')
    and (draft.channel=='me' or draft.channel=='say') and not self.editorDirty then
    self:SelectItem(draft.item)
    self.activeTab,self.activeChannel=draft.tab,draft.channel
    self:ReloadEditor()
    self.loadingEditor=true;self.textEditor:SetText(draft.text);self.loadingEditor=false
    self.editorDirty=true;self:RefreshDetails()
    self.editorStatus:SetText('Recovered unsaved draft. Correct errors to save, or close to discard explicitly.')
  end
  if not self.selectedID then return end
  self.customEditor:Show()
end
function A:SaveEditor()
  if not self.selectedID or not self.textEditor or not self.editorDirty then return true end
  local cfg = self.db.items[self.selectedID]
  if not cfg then return true end
  local meta = self.inventory and self.inventory[self.selectedID]
  local link = meta and meta.link
  local lines, err = self:ParseLines(self.textEditor:GetText(),link)
  if not lines then
    self.editorStatus:SetText('|cffff7777Cannot switch or save: ' .. err .. '|r')
    return false
  end
  local stock = self.activeTab == 'last'
  self:SetCustomPhrases(self.selectedID, 'en', self.activeChannel or 'me', lines, stock)
  self.editorDirty = false
  self.db.editorDraft=nil
  self:RefreshTextInfo()
  self.shuffles = {}
  self.editorStatus:SetText('|cff92db9eSaved ' .. #lines .. ' /' .. (self.activeChannel or 'me') ..
    ' ' .. (stock and 'last-item' or 'regular') .. ' phrases.|r')
  return true
end
function A:ReloadEditor()
  if not self.textEditor then return end
  local cfg = self.selectedID and self.db.items[self.selectedID]
  local lines = cfg and self:GetCustomPhrases(self.selectedID, 'en', self.activeChannel or 'me', self.activeTab == 'last') or {}
  self.loadingEditor = true
  self.textEditor:SetText(formatLines(lines))
  self.textEditor:SetCursorPosition(0)
  if self.editorScroll then self.editorScroll:SetVerticalScroll(0) end
  self.loadingEditor = false
  self.editorDirty = false
  self:RefreshTextInfo()
end
function A:SwitchTab(tab)
  if tab ~= 'regular' and tab ~= 'last' then return end
  if self.activeTab == tab then return end
  if not self:SaveEditor() then return end
  self.activeTab = tab
  self:ReloadEditor()
  self:RefreshDetails()
end
function A:SwitchChannel(channel)
  if channel ~= 'me' and channel ~= 'say' then return end
  if self.activeChannel == channel then return end
  if not self:SaveEditor() then return end
  self.activeChannel = channel
  self:ReloadEditor()
  self:RefreshDetails()
end
function A:SelectItem(id)
  if self.selectedID == id then return end
  if not self:SaveEditor() then return end
  if not self.db.items[id] then return end
  self.selectedID = id
  -- Clicking an item shows its phrases immediately, not a separate Items tab.
  self.activeTab = 'regular'
  self:ReloadEditor()
  self.editorStatus:SetText('Item selected. Valid edits save automatically.')
  self:RefreshConfig()
end
function A:RefreshTextInfo()
  if not self.textCount then return end
  local id=self.selectedID
  if not id then self.textCount:SetText('');return end
  local u,r,c=self:GetLibrarySources(id,'en',self.activeChannel or 'me',self.activeTab=='last')
  self.textCount:SetText('Current: '..(#u+#r)..' active defaults / '..#c..' custom.  Regular: '..#self:GetResolvedPhrases(id,'en','me')..' /me, '..
    #self:GetResolvedPhrases(id,'en','say')..' /say | Last: '..
    #self:GetResolvedPhrases(id,'en','me',true)..' /me, '..#self:GetResolvedPhrases(id,'en','say',true)..' /say')
end
A.exampleItemNames = {
  healthstone='Healthstone', potion='Minor Healing Potion', drink='Ice Cold Milk',
  food='Spiced Bread', bufffood='Smoked Bear Meat', elixir='Elixir of Fortitude',
  bandage='Linen Bandage', other='Mysterious Artifact',
  hearthstone='Hearthstone', alcohol='Dwarven Stout'
}
function A:PreviewTemplateLine(template, category)
  category = category or (self.selectedID and self:GetCategory(self.selectedID)) or 'other'
  local name = self.exampleItemNames[category] or 'Item'
  if self.selectedID and self:GetCategory(self.selectedID) == category then
    local meta, cfg = self.inventory[self.selectedID], self.db.items[self.selectedID]
    name = (meta and meta.name) or (cfg and cfg.name) or name
  end
  local substitution = '|cffffd15b[' .. name .. ']|r'
  -- gsub also returns a replacement count; never pass it as a native UI color.
  local preview = tostring(template or ''):gsub('{item}', function() return substitution end)
  return preview
end
function A:RefreshDefaultLibrary()
  if not self.libraryContent then return end
  for _,row in ipairs(self.libraryRows or {}) do row:Hide() end
  self.libraryRows=self.libraryRows or {}
  if not self.selectedID then return end
  local u,r=self:GetLibraryEntries(self.selectedID,'en',self.activeChannel or 'me',self.activeTab=='last')
  local _,info=self:GetPlayerRace()
  local y,n=0,0
  local function nextRow()
    n=n+1
    local row=A.libraryRows[n]
    if not row then
      row=CreateFrame('Button',nil,A.libraryContent)
      row:SetSize(616,30)
      row.display=label(row,'',30,-7)
      row.display:SetWidth(580);row.display:SetJustifyH('LEFT')
      row.checkbox=CreateFrame('CheckButton',nil,row,'UICheckButtonTemplate')
      row.checkbox:SetSize(25,25);row.checkbox:SetPoint('LEFT',row,'LEFT',0,0)
      row.checkbox:SetScript('OnClick',function(cb)
        if row.entry then
          A:SetDefaultDisabled(row.entry.id,not cb:GetChecked())
          A:RefreshDefaultLibrary(); A:RefreshTextInfo()
        end
      end)
      row:SetScript('OnEnter',function()
        if row.entry and GameTooltip then
          GameTooltip:SetOwner(row,'ANCHOR_RIGHT')
          GameTooltip:SetText(A:PreviewTemplateLine(row.entry.text))
          GameTooltip:Show()
        end
      end)
      row:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
      A.libraryRows[n]=row
    end
    row:ClearAllPoints();row:SetPoint('TOPLEFT',A.libraryContent,'TOPLEFT',0,-y)
    y=y+30;row:Show();row.entry=nil
    return row
  end
  for index,entries in ipairs({u,r}) do
    for _,entry in ipairs(entries) do
      local item=nextRow();item.entry=entry
      item.checkbox:Show();item.checkbox:SetChecked(not self:IsDefaultDisabled(entry.id))
      local color=index==2 and info and info.color or {1,1,1}
      item.display:SetTextColor(color[1],color[2],color[3])
      item.display:SetText(entry.text)
      if item.display.SetWordWrap then item.display:SetWordWrap(true) end
      local height=math.max(30,(item.display:GetStringHeight() or 16)+14)
      item:SetHeight(height);y=y+height-30
      item:SetScript('OnClick',function()
        A:SetDefaultDisabled(entry.id,not A:IsDefaultDisabled(entry.id));A:RefreshDefaultLibrary();A:RefreshTextInfo()
      end)
    end
  end
  local cfg=self.db.items[self.selectedID]
  local field=self:PhraseField('en',self.activeChannel or 'me',self.activeTab=='last')
  if type(cfg.libraryLegacyEmpty)=='table' and cfg.libraryLegacyEmpty[field] then
    local row=nextRow();row.checkbox:Hide();row.display:SetText('Legacy empty-pool opt-out: click to enable defaults for this item/pool.')
    row.display:SetTextColor(.78,.81,.82)
    row:SetHeight(44);y=y+14
    row:SetScript('OnClick',function() cfg.libraryLegacyEmpty[field]=nil;A:RefreshDefaultLibrary();A:RefreshTextInfo() end)
  end
  self.libraryContent:SetHeight(math.max(y,100))
  if self.libraryScroll.UpdateScrollChildRect then self.libraryScroll:UpdateScrollChildRect() end
end
function A:RefreshDetails()
  if not self.configFrame then return end
  local cfg = self.selectedID and self.db.items[self.selectedID]
  if cfg then
    local meta = self.inventory[self.selectedID]
    self.nameHeader:SetText(nameFor(self.selectedID, cfg, meta))
    self.itemMeta:SetText('ID: ' .. self.selectedID .. '    |    In bags: ' ..
      (meta and meta.count or 0) .. '    |    English')
    local category, method = self:GetCategory(self.selectedID)
    self.categoryInfo:SetText('Detected: ' .. (self.categoryNames[category] or 'Other') ..
      ' (' .. tostring(method) .. ')')
    self.categoryDropdown:SetCaption(self.categoryNames[category] or 'Other')
    local scope = cfg.scopeOverride
    self.itemScopeDropdown:SetCaption(scope and self.ScopeNames[scope] or 'Use global setting')
    self.modeDropdown:SetCaption(self.OutputModes[cfg.outputMode] or self.OutputModes.me)
    self.stockCheck:SetChecked(not not cfg.outOfStockEnabled)
    self.stockCheck:SetEnabled(self.selectedID ~= 6948)
  else
    self.nameHeader:SetText('Select an item from the left')
    self.itemMeta:SetText('')
    self.categoryInfo:SetText('')
    self.categoryDropdown:SetCaption('Category')
    self.itemScopeDropdown:SetCaption('Use global setting')
    self.modeDropdown:SetCaption('Only /me')
  end
  for tab, b in pairs(self.tabButtons or {}) do
    b:SetSelected(tab == self.activeTab)
    if self.customTabButtons then self.customTabButtons[tab]:SetSelected(tab==self.activeTab) end
  end
  for channel, b in pairs(self.channelButtons or {}) do
    b:SetSelected(channel == self.activeChannel)
    if self.customChannelButtons then self.customChannelButtons[channel]:SetSelected(channel==self.activeChannel) end
  end
  self.editorPane:Show()
  if self.customEditorTitle then
    self.customEditorTitle:SetText((cfg and nameFor(self.selectedID,cfg,self.inventory[self.selectedID]) or 'Select an item')..
      ' - '..(self.activeTab=='last' and 'Last Item' or 'Regular')..' /'..(self.activeChannel or 'me'))
  end
  self:RefreshDefaultLibrary()
  self:RefreshTextInfo()
end
function A:RefreshConfig()
  if not self.configFrame then return end
  local rows = self:ConfigItems()
  self.configRows = rows
  self.summaryText:SetText(#rows .. ' shown / ' .. self:CountRemembered() .. ' remembered')
  self.globalScopeDropdown:SetCaption(self.ScopeNames[self.db.defaultScope] or 'Only in groups')
  local cd = self.db.globalCooldown or 30
  self.cooldownDropdown:SetCaption(cd == 0 and 'Disabled' or (cd .. ' seconds'))
  self.autoCheck:SetChecked(self.db.auto)
  self.minimapCheck:SetChecked(self.db.showMinimap)
  self.filterDropdown:SetCaption(({all='All items', inbags='In bags', enabled='Enabled',
    disabled='Disabled', unconfigured='No phrases yet', saved='Not in bags'})[self.itemFilter or 'all'] or 'All items')
  self.emptyLabel:SetShown(#rows==0)
  for i, entry in ipairs(rows) do
    local row = self.listButtons[i]
    if not row then row = self:NewInventoryRow(self.listContent, i); self.listButtons[i]=row end
    row.itemID, row.fullName = entry.id, entry.title
    row.statusText:SetText(entry.cfg.enabled and 'ON' or 'OFF')
    row.statusText:SetTextColor(entry.cfg.enabled and 0.37 or 0.7, entry.cfg.enabled and 0.94 or 0.7, entry.cfg.enabled and 0.58 or 0.7)
    fitName(row.name, entry.title, 142, row.measurer)
    row.quantity:SetText(entry.count > 0 and ('x' .. entry.count) or '--')
    row.quantity:SetTextColor(entry.count>0 and 1 or 0.5, entry.count>0 and 0.82 or 0.5, entry.count>0 and 0.43 or 0.5)
    row.icon:SetTexture(entry.meta and entry.meta.icon or 'Interface\\Icons\\INV_Misc_QuestionMark')
    row:Show()
    row:SetSelected(entry.id == self.selectedID)
  end
  for i=#rows+1, #self.listButtons do self.listButtons[i]:Hide() end
  self.listContent:SetHeight(math.max(260, #rows*ROW_HEIGHT))
  if self.listScroll.UpdateScrollChildRect then self.listScroll:UpdateScrollChildRect() end
  self:RefreshDetails()
end

function A:BuildConfig()
  local f=CreateFrame('Frame','ForeverRPConfigFrame',UIParent)
  f:SetSize(1050,760)
  f:SetPoint('CENTER')
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag('LeftButton')
  f:SetScript('OnDragStart',f.StartMoving)
  f:SetScript('OnDragStop',f.StopMovingOrSizing)
  f:SetClampedToScreen(true)
  f:SetFrameStrata('DIALOG')
  if type(UISpecialFrames)=='table' then
    UISpecialFrames[#UISpecialFrames+1]='ForeverRPConfigFrame'
  end
  local background=f:CreateTexture(nil,'BACKGROUND')
  background:SetAllPoints(f)
  background:SetTexture('Interface\\AddOns\\ForeverRP\\Media\\ForeverRP_Background.tga')
  f:Hide()
  self.configFrame=f
  self.activeTab='regular'
  self.activeChannel='me'
  self.editorDirty=false
  self.listButtons={}

  local icon=f:CreateTexture(nil,'ARTWORK')
  icon:SetSize(39,39)
  icon:SetPoint('TOPLEFT',f,'TOPLEFT',21,-36)
  icon:SetTexture('Interface\\AddOns\\ForeverRP\\Media\\ForeverRP_Icon.tga')
  label(f,'FOREVER RP    |    v0.9.16    |    ETERNAL INK',73,-18,'GameFontNormal')
  button(f,'X',26,25,1005,-13,function() f:Hide() end)
  label(f,'GLOBAL SETTINGS',20,-92,'GameFontNormalLarge')
  surface(f,17,-111,293,143,{.16,.21,.27,.88},{.46,.38,.24,.52})
  self.autoCheck=CreateFrame('CheckButton',nil,f,'UICheckButtonTemplate')
  self.autoCheck:SetPoint('TOPLEFT',f,'TOPLEFT',20,-114)
  label(f,'Enable automatic RP',53,-121)
  self.autoCheck:SetScript('OnClick',function(c) A.db.auto=not not c:GetChecked() end)
  label(f,'Output',24,-157)
  self.globalScopeDropdown=dropdown(f,112,-145,184,'Only in groups',function()
    local result={}
    for _,value in ipairs(A.ScopeOrder) do result[#result+1]={key=value,label=A.ScopeNames[value]} end
    return result
  end,function(value) A.db.defaultScope=value; A:RefreshConfig() end,
    function() return A.db.defaultScope end)
  label(f,'Cooldown',24,-188)
  self.cooldownDropdown=dropdown(f,112,-176,184,'30 seconds',function()
    return {{key=0,label='Disabled'},{key=15,label='15 seconds'},
      {key=30,label='30 seconds'},{key=60,label='60 seconds'},{key=120,label='120 seconds'}}
  end,function(value) A.db.globalCooldown=value; A:RefreshConfig() end,
    function() return A.db.globalCooldown or 30 end)
  self.minimapCheck=CreateFrame('CheckButton',nil,f,'UICheckButtonTemplate')
  self.minimapCheck:SetPoint('TOPLEFT',f,'TOPLEFT',20,-217)
  label(f,'Show minimap icon',53,-223)
  self.minimapCheck:SetScript('OnClick',function(c)
    A.db.showMinimap=not not c:GetChecked()
    if A.UpdateMinimapVisibility then A:UpdateMinimapVisibility() end
  end)

  label(f,'INVENTORY & SAVED ITEMS',20,-269,'GameFontNormal')
  self.summaryText=label(f,'',20,-293)
  button(f,'Rescan Bags',119,25,191,-280,function()
    A:ResetInventory(); A:RefreshConfig()
    A.editorStatus:SetText('Bags rescanned. No RP emitted.')
  end)
  label(f,'Find',20,-331)
  self.searchBox=CreateFrame('EditBox',nil,f,'InputBoxTemplate')
  self.searchBox:SetSize(218,25)
  self.searchBox:SetPoint('TOPLEFT',f,'TOPLEFT',82,-322)
  self.searchBox:SetAutoFocus(false)
  self.searchBox:SetScript('OnEscapePressed',function(b) b:ClearFocus() end)
  self.searchBox:SetScript('OnTextChanged',function(b)
    A.searchQuery=b:GetText()
    if A.listScroll then A.listScroll:SetVerticalScroll(0); A:RefreshConfig() end
  end)
  self.filterDropdown=dropdown(f,20,-355,275,'All items',function()
    return {{key='all',label='All items'}, {key='inbags',label='In bags'},
      {key='enabled',label='Enabled'}, {key='disabled',label='Disabled'},
      {key='unconfigured',label='No phrases yet'}, {key='saved',label='Not in bags'}}
  end,function(value)
    A.itemFilter=value; A.listScroll:SetVerticalScroll(0); A:RefreshConfig()
  end,function() return A.itemFilter or 'all' end)
  local listFrame=CreateFrame('Frame',nil,f)
  listFrame:SetPoint('TOPLEFT',f,'TOPLEFT',19,-394)
  listFrame:SetSize(291,304)
  surface(listFrame,0,0,291,304,{.11,.18,.24,.80},{.42,.36,.26,.52})
  local listScroll=CreateFrame('ScrollFrame',nil,listFrame,'UIPanelScrollFrameTemplate')
  listScroll:SetPoint('TOPLEFT',listFrame,'TOPLEFT',6,-5)
  listScroll:SetPoint('BOTTOMRIGHT',listFrame,'BOTTOMRIGHT',-26,5)
  local content=CreateFrame('Frame',nil,listScroll)
  content:SetSize(ITEM_WIDTH,295)
  listScroll:SetScrollChild(content)
  self.listScroll,self.listContent=listScroll,content
  self.emptyLabel=label(listFrame,'No matching usable items.',12,-18)
  self.emptyLabel:Hide()
  label(f,'Click ON/OFF to toggle RP.  --: not in bags',21,-707):SetWidth(295)

  local sep=f:CreateTexture(nil,'ARTWORK')
  sep:SetColorTexture(.55,.43,.24,.65)
  sep:SetSize(1,655)
  sep:SetPoint('TOPLEFT',f,'TOPLEFT',326,-83)
  surface(f,338,-107,675,110,{.15,.21,.27,.65},{.47,.40,.29,.35})

  -- Item details: always visible above the text/template tabs.
  self.nameHeader=label(f,'Select an item',345,-51,'GameFontNormalLarge')
  self.nameHeader:SetWidth(650)
  self.itemMeta=label(f,'',345,-77)
  self.categoryInfo=label(f,'',345,-96)
  self.categoryInfo:SetWidth(650)
  label(f,'Category',345,-126)
  self.categoryDropdown=dropdown(f,420,-115,220,'Category',function()
    local r={{key='auto',label='Auto-detect'}}
    for _,k in ipairs(A.categoryOrder) do r[#r+1]={key=k,label=A.categoryNames[k]} end
    return r
  end,function(value)
    if not A.selectedID then return end
    local cfg=A.db.items[A.selectedID]
    cfg.categoryOverride=(value=='auto') and nil or value
    A.templateSelection={}
    A.templatePreviewNumber=1
    A:RefreshDetails()
  end,function()
    local cfg=A.selectedID and A.db.items[A.selectedID]
    return (cfg and cfg.categoryOverride) or 'auto'
  end)
  label(f,'Output scope',655,-126)
  self.itemScopeDropdown=dropdown(f,755,-115,248,'Use global setting',function()
    local r={{key='inherit',label='Use global setting'}}
    for _,k in ipairs(A.ScopeOrder) do r[#r+1]={key=k,label=A.ScopeNames[k]} end
    return r
  end,function(value)
    if not A.selectedID then return end
    A.db.items[A.selectedID].scopeOverride=(value=='inherit') and nil or value
    A:RefreshDetails()
  end,function()
    local cfg=A.selectedID and A.db.items[A.selectedID]
    return (cfg and cfg.scopeOverride) or 'inherit'
  end)
  -- Regular RP ON/OFF is toggled in the inventory row (no duplicate checkbox).
  self.stockCheck=CreateFrame('CheckButton',nil,f,'UICheckButtonTemplate')
  self.stockCheck:SetPoint('TOPLEFT',f,'TOPLEFT',342,-152)
  label(f,'Last item RP (1 to 0)',376,-159)
  self.stockCheck:SetScript('OnClick',function(c)
    if not A.selectedID then return end
    local cfg=A.db.items[A.selectedID]
    cfg.outOfStockEnabled=(A.selectedID~=6948 and not not c:GetChecked())
    A:RefreshDetails()
    A.editorStatus:SetText('Last-item RP ' .. (cfg.outOfStockEnabled and 'enabled' or 'disabled') ..
      '. Choose Last Item and add phrases if needed.')
  end)
  label(f,'Mode',760,-159)
  self.modeDropdown=dropdown(f,808,-147,197,'Only /me',function()
    local r={}
    for _,k in ipairs(A.OutputOrder) do r[#r+1]={key=k,label=A.OutputModes[k]} end
    return r
  end,function(value)
    if not A.selectedID then return end
    A.db.items[A.selectedID].outputMode=value
    A:RefreshDetails()
  end,function()
    local cfg=A.selectedID and A.db.items[A.selectedID]
    return (cfg and cfg.outputMode) or 'me'
  end)
  self.textCount=label(f,'',345,-192)
  self.textCount:SetWidth(657)

  -- Classic game-option-style tabs, distinct from action buttons.
  surface(f,342,-237,665,33,{.12,.17,.23,.78},{.45,.37,.24,.4})
  self.tabButtons={}
  self.tabButtons.regular=navTab(f,'Regular RP',344,-237,208,32,function() A:SwitchTab('regular') end)
  self.tabButtons.last=navTab(f,'Last Item RP',554,-237,208,32,function() A:SwitchTab('last') end)
  label(f,'Defaults are active automatically',773,-248)
  self.channelButtons={}
  self.channelButtons.me=navTab(f,'/me',346,-277,107,25,function() A:SwitchChannel('me') end,true)
  self.channelButtons.say=navTab(f,'/say',456,-277,107,25,function() A:SwitchChannel('say') end,true)
  label(f,'{item} inserts an item link (optional)',580,-283)

  -- One shared region switches content without ever hiding the inventory.
  local editorPane=CreateFrame('Frame',nil,f)
  editorPane:SetPoint('TOPLEFT',f,'TOPLEFT',343,-302)
  editorPane:SetSize(664,342)
  self.editorPane=editorPane
  self.editCustomButton=button(editorPane,'Edit custom phrases',190,27,0,-4,function() A:ShowCustomEditor() end)
  local custom=CreateFrame('Frame','ForeverRPCustomEditor',UIParent)
  custom:SetSize(710,530);custom:SetPoint('CENTER');custom:SetFrameStrata('FULLSCREEN_DIALOG')
  custom:SetMovable(true);custom:EnableMouse(true);custom:RegisterForDrag('LeftButton')
  custom:SetScript('OnDragStart',custom.StartMoving);custom:SetScript('OnDragStop',custom.StopMovingOrSizing)
  custom:SetClampedToScreen(true)
  surface(custom,0,0,710,530,{.105,.17,.215,1},{.42,.39,.29,1})
  self.customEditor=custom
  self.customEditorTitle=label(custom,'Custom phrases',18,-18,'GameFontNormal')
  self.customEditorTitle:SetWidth(630)
  button(custom,'X',26,25,672,-8,function() custom:Hide() end)
  if type(UISpecialFrames)=='table' then UISpecialFrames[#UISpecialFrames+1]='ForeverRPCustomEditor' end
  self.customTabButtons={}
  self.customChannelButtons={}
  self.customTabButtons.regular=navTab(custom,'Regular RP',18,-48,160,30,function() A:SwitchTab('regular') end)
  self.customTabButtons.last=navTab(custom,'Last Item RP',180,-48,160,30,function() A:SwitchTab('last') end)
  self.customChannelButtons.me=navTab(custom,'/me',365,-48,100,30,function() A:SwitchChannel('me') end,true)
  self.customChannelButtons.say=navTab(custom,'/say',467,-48,100,30,function() A:SwitchChannel('say') end,true)
  local editorBorder=CreateFrame('Frame',nil,custom)
  editorBorder:SetPoint('TOPLEFT',custom,'TOPLEFT',18,-90)
  editorBorder:SetSize(662,280)
  surface(editorBorder,0,0,662,280,{.105,.17,.215,.90},{.42,.39,.29,.52})
  local editorScroll=CreateFrame('ScrollFrame',nil,editorBorder,'UIPanelScrollFrameTemplate')
  editorScroll:SetPoint('TOPLEFT',editorBorder,'TOPLEFT',11,-10)
  editorScroll:SetPoint('BOTTOMRIGHT',editorBorder,'BOTTOMRIGHT',-29,9)
  local edit=CreateFrame('EditBox',nil,editorScroll)
  edit:SetMultiLine(true)
  edit:SetAutoFocus(false)
  edit:SetFontObject('ChatFontNormal')
  edit:SetWidth(605)
  edit:SetHeight(96)
  edit:SetMaxBytes(36000)
  edit:SetScript('OnEscapePressed',function(e) e:ClearFocus() end)
  edit:SetScript('OnEditFocusLost',function()
    A.autoSaveRevision=(A.autoSaveRevision or 0)+1
    if A.editorDirty then A:SaveEditor() end
  end)
  -- In a multiline EditBox, visual wrapping and the ScrollFrame are separate:
  -- resizing the child does not automatically scroll to the caret after Enter.
  -- OnCursorChanged gives coordinates relative to the edit box (negative Y).
  -- Keep the caret inside the visible scroll viewport with a small margin.
  edit:SetScript('OnCursorChanged',function(e, x, y, cursorWidth, cursorHeight)
    if A.loadingEditor or not y then return end
    local activeItem,activeTab,activeChannel=A.selectedID,A.activeTab,A.activeChannel
    local function followCursor()
      if A.loadingEditor or A.textEditor~=e or A.selectedID~=activeItem
        or A.activeTab~=activeTab or A.activeChannel~=activeChannel
        or not custom:IsShown() then return end
      local viewport=editorScroll:GetHeight() or 0
      if viewport<=0 then return end
      local top=math.max(0,-y)
      local bottom=top+math.max(cursorHeight or 16,16)
      local current=editorScroll:GetVerticalScroll() or 0
      local margin=8
      local target=current
      if top<current+margin then
        target=math.max(0,top-margin)
      elseif bottom>current+viewport-margin then
        target=math.max(0,bottom-viewport+margin)
      end
      if math.abs(target-current)>0.5 then editorScroll:SetVerticalScroll(target) end
    end
    followCursor()
    -- Delay one frame as the edit box may gain a line of height after Enter.
    if C_Timer and C_Timer.After then C_Timer.After(0,followCursor) end
  end)
  edit:SetScript('OnTextChanged',function(e)
    if e.GetStringHeight then e:SetHeight(math.max(96,(e:GetStringHeight() or 0)+30)) end
    if A.loadingEditor then return end
    A.editorDirty=true
    A:RememberEditorDraft()
    A.autoSaveRevision=(A.autoSaveRevision or 0)+1
    local revision=A.autoSaveRevision
    local item,tab,channel=A.selectedID,A.activeTab,A.activeChannel
    if C_Timer and C_Timer.After then
      C_Timer.After(.7,function()
        if A.autoSaveRevision==revision and A.selectedID==item and A.activeTab==tab
          and A.activeChannel==channel and A.editorDirty then
          A:SaveEditor()
        end
      end)
    else
      -- Some Forever clients lack C_Timer; keep data safe at next blur/switch.
      A:SaveEditor()
    end
  end)
  editorScroll:SetScrollChild(edit)
  self.editorScroll=editorScroll
  self.textEditor=edit
  button(custom,'Local Preview',137,27,18,-382,function()
    if not A.selectedID then return end
    local currentMeta=A.inventory and A.inventory[A.selectedID]
    local lines,err=A:ParseLines(A.textEditor:GetText(),currentMeta and currentMeta.link)
    if not lines or #lines==0 then A.editorStatus:SetText(err or 'Please enter a phrase.');return end
    local meta=A.inventory[A.selectedID]
    local link=meta and meta.link or ('[Item '..A.selectedID..']')
    local phrase=lines[math.random(#lines)]:gsub('{item}',function()return link end)
    A:Say('LOCAL /'..A.activeChannel..' preview ONLY: '..phrase)
  end)
  label(custom,'Auto-save after 0.7s. Enter = new phrase; {item} optional.',170,-389):SetWidth(506)

  self.recoverCustomButton=button(custom,'Edit preserved matches as own texts',270,23,18,-421,function()
    if not A.selectedID or not A:SaveEditor() then return end
    local cfg=A.db.items[A.selectedID]
    local raw=A:GetPhrases(cfg,'en',A.activeChannel or 'me',A.activeTab=='last')
    A.loadingEditor=true;A.textEditor:SetText(formatLines(raw));A.loadingEditor=false
    A.editorDirty=true
    A:RememberEditorDraft()
    A.editorStatus:SetText('Preserved matches shown. Saving explicitly claims these as own texts, independent of default disables.')
  end)
  local libraryScroll=CreateFrame('ScrollFrame',nil,editorPane,'UIPanelScrollFrameTemplate')
  libraryScroll:SetPoint('TOPLEFT',editorPane,'TOPLEFT',0,-40)
  libraryScroll:SetSize(635,300)
  local content=CreateFrame('Frame',nil,libraryScroll);content:SetSize(616,300)
  libraryScroll:SetScrollChild(content)
  self.libraryContent,self.libraryScroll=content,libraryScroll

  self.editorStatus=label(custom,'Valid edits save automatically. Invalid drafts are preserved on reload.',18,-465)
  self.editorStatus:SetWidth(652)
  self.editorStatus:SetJustifyH('LEFT')
  label(f,'/say may be restricted by the client; /me remains the preferred RP output.',345,-685):SetWidth(650)
  label(f,'Consumption: successful spell + bag decrease. Last item replaces regular RP.',345,-709):SetWidth(650)
  -- An invalid unsaved draft must never vanish silently on close or ESC.
  -- Show the native WoW confirmation; users explicitly choose discard vs edit.
  custom:SetScript('OnHide',function()
    if not A.selectedID or A:SaveEditor() then return end
    if type(StaticPopupDialogs)=='table' and type(StaticPopup_Show)=='function' then
      if not StaticPopupDialogs.FOREVERRP_DISCARD_INVALID then
        StaticPopupDialogs.FOREVERRP_DISCARD_INVALID={
          text='Forever RP: Your current text has an error and was not saved. Discard these unsaved changes?',
          button1='Discard changes',
          button2='Keep editing',
          OnAccept=function()
            A.editorDirty=false
            A.db.editorDraft=nil
            A:ReloadEditor()
          end,
          OnCancel=function() custom:Show() end,
          timeout=0, whileDead=true, hideOnEscape=false, preferredIndex=3,
        }
      end
      StaticPopup_Show('FOREVERRP_DISCARD_INVALID')
    else
      -- Safer fallback on clients without StaticPopup: leave the draft open.
      custom:Show()
    end
  end)
  custom:Hide()
  self:RefreshConfig()
  if type(self.db.editorDraft)=='table' then self:ShowCustomEditor() end
  return f
end

function A:ShowConfig()
  if not self.db then self:Say('Please wait until login completes.');return end
  if not self.configFrame then self:BuildConfig() end
  self:ResetInventory()
  self:RefreshConfig()
  if not self.selectedID then
    local items=self:ConfigItems()
    if items[1] then self:SelectItem(items[1].id) end
  end
  self.configFrame:Show()
end
