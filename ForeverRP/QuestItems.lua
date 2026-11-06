-- Positive quest metadata only; never infer quest status from a localized name.
local A=ForeverRP
local function safe(value)
  return type(issecretvalue)~='function' or not issecretvalue(value)
end
function A:IsQuestItem(id,bag,slot)
  if not safe(id) or type(id)~='number' or id==6948 then return false end
  local reason
  local bagClear,normalClass,normalBinding=false,false,false
  local questClass=Enum and Enum.ItemClass and Enum.ItemClass.Questitem or 12
  local questBinding=Enum and Enum.ItemBind and Enum.ItemBind.Quest or 4
  if safe(bag) and safe(slot) and type(bag)=='number' and type(slot)=='number'
    and bag>=0 and bag<=5 and C_Container and type(C_Container.GetContainerItemQuestInfo)=='function' then
    local ok,info=pcall(C_Container.GetContainerItemQuestInfo,bag,slot)
    if ok and safe(info) and type(info)=='table' then
      local inspected,quest,questID=pcall(function() return info.isQuestItem,info.questID end)
      if not inspected then quest,questID=nil,nil end
      if (safe(quest) and quest==true) or (safe(questID) and type(questID)=='number' and questID>0) then
        reason='bag quest association'
      elseif safe(quest) and quest==false and safe(questID) and questID==nil then
        bagClear=true
      end
    end
  end
  if C_Item and type(C_Item.GetItemInfoInstant)=='function' then
    local ok,_,_,_,_,_,class=pcall(C_Item.GetItemInfoInstant,id)
    if ok and safe(class) and type(class)=='number' then
      if class==questClass then reason='quest item class' else normalClass=true end
    end
  end
  if C_Item and type(C_Item.GetItemInfo)=='function' then
    local ok,_,_,_,_,_,_,_,_,_,_,_,class,_,binding=pcall(C_Item.GetItemInfo,id)
    if ok and safe(class) and type(class)=='number' then
      if class==questClass then reason='quest item class' else normalClass=true end
    end
    if ok and safe(binding) and type(binding)=='number' then
      if binding==questBinding then reason='quest binding' else normalBinding=true end
    end
  end
  if self.db then
    if type(self.db.questItemIDs)~='table' then
      if self.db.questItemIDs~=nil then
        if type(self.db.invalidSavedValues)~='table' then self.db.invalidSavedValues={} end
        self.db.invalidSavedValues.questItemIDs=self.db.questItemIDs
      end
      self.db.questItemIDs={}
    end
    if reason then self.db.questItemIDs[id]=reason
    elseif bagClear and normalClass and normalBinding and self.db.questItemIDs[id]=='bag quest association' then
      self.db.questItemIDs[id]=nil
    end
    -- Retain positive evidence when the item is absent or its cache is empty.
    return reason~=nil or type(self.db.questItemIDs[id])=='string'
  end
  return reason~=nil
end
function A:ArchiveQuestDraft()
  local draft=self.db and self.db.editorDraft
  if type(draft)~='table' or not self:IsQuestItem(draft.item) then return end
  if type(self.db.questEditorDrafts)~='table' then
    if self.db.questEditorDrafts~=nil then
      if type(self.db.invalidSavedValues)~='table' then self.db.invalidSavedValues={} end
      self.db.invalidSavedValues.questEditorDrafts=self.db.questEditorDrafts
    end
    self.db.questEditorDrafts={}
  end
  self.db.questEditorDrafts[#self.db.questEditorDrafts+1]=draft
  self.db.editorDraft=nil
end

function A:OnQuestItemInfoReceived(id,success)
  if not self.db or not safe(id) or type(id)~='number' or not safe(success) or success==false
    or not self.db.items[id] then return end
  local known=type(self.db.questItemIDs)=='table' and type(self.db.questItemIDs[id])=='string'
  if self:IsQuestItem(id) and not known then
    self:ResetInventory()
    self:RefreshConfig()
  end
end
