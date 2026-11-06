local A=ForeverRP
local function fmt(key,...)
  return A.L and A:L(key,...) or string.format(key,...)
end
A.MAX_LINES_PER_ITEM=100
A.shuffles={}
A.lastProbe=nil
local DEFAULTS={
  'crunches a {item} between his teeth. "A touch gritty. Another, please."',
  'finishes a {item} and brushes the dust from his armor. "My compliments to the chef."',
  'consumes a {item} with impeccable manners. "I do believe a refill is in order."',
  'swallows a {item} without ceremony. "The afterlife is terribly demanding."',
  'helps himself to a {item}. "One must maintain certain standards, even in death."',
  'takes a bite of a {item}, then nods approvingly at the warlock. "Exquisite."',
  'polishes off a {item}. "A pity they never serve these with wine."',
  'devours a {item}. "I assure you, this is strictly medicinal."',
  'finishes a {item} and sighs. "I shall require another before the next catastrophe."',
  'crushes a {item} in his jaws. "Still preferable to dying a second time."',
}
function A:GetLucienPack()
  local lines={}
  for i=1,#DEFAULTS do lines[i]=DEFAULTS[i] end
  return lines
end
-- One entered newline defines a phrase. Soft visual line wraps do not.
-- Optional {item} placeholders are expanded only when actually present.
-- Item links can be longer than their placeholder: validate the rendered text
-- when the genuine item hyperlink is currently known as well as at send time.
function A:ParseLines(text,itemLink)
  local lines={}
  local sourceLine=0
  text=tostring(text or ''):gsub('\r\n','\n'):gsub('\r','\n')
  for line in (text..'\n'):gmatch('(.-)\n') do
    sourceLine=sourceLine+1
    line=line:match('^%s*(.-)%s*$')
    if line~='' then
      if #lines>=self.MAX_LINES_PER_ITEM then
        return nil,fmt('Line %d: maximum %d phrases per text pool.',sourceLine,self.MAX_LINES_PER_ITEM)
      end
      if #line>200 then
        return nil,fmt('Line %d: maximum 200 bytes per phrase (%d bytes).',sourceLine,#line)
      end
      -- Never allow a user-supplied WoW hyperlink to bypass the real {item} link.
      if line:find('|H',1,true) or line:find('|h',1,true) then
        return nil,fmt('Line %d: paste plain text, not item hyperlinks; {item} is optional.',sourceLine)
      end
      if type(itemLink)=='string' and itemLink~='' and line:find('{item}',1,true) then
        local rendered=line:gsub('{item}',function()return itemLink end)
        if #rendered>255 then
          return nil,fmt('Line %d: rendered item link makes the message %d bytes (max. 255).',sourceLine,#rendered)
        end
      end
      lines[#lines+1]=line
    end
  end
  return lines,nil
end
-- Legacy cfg.lines is intentionally kept for English /me to preserve saved settings.
function A:GetPhrases(cfg,language,kind,isStock)
  if not cfg then return {} end
  local key=(language=='de' and 'de' or 'en') .. '_' .. (kind=='say' and 'say' or 'me')
  local field=isStock and ({en_me='outMeLines',en_say='outSayLines',de_me='outDeMeLines',de_say='outDeSayLines'})[key]
    or ({en_me='lines',en_say='sayLines',de_me='deMeLines',de_say='deSayLines'})[key]
  local pool=cfg[field]
  if type(pool)~='table' then return {} end
  -- Invalid persisted phrases stay stored, but never reach string operations.
  local valid={}
  for _,line in ipairs(pool) do
    if type(line)=='string' and not line:find('[\r\n]') then
      local parsed=self:ParseLines(line)
      if parsed and #parsed==1 then valid[#valid+1]=parsed[1] end
    end
  end
  return valid
end
function A:SetPhrases(cfg,language,kind,lines,isStock)
  local key=(language=='de' and 'de' or 'en') .. '_' .. (kind=='say' and 'say' or 'me')
  local field=isStock and ({en_me='outMeLines',en_say='outSayLines',de_me='outDeMeLines',de_say='outDeSayLines'})[key]
    or ({en_me='lines',en_say='sayLines',de_me='deMeLines',de_say='deSayLines'})[key]
  cfg[field]=lines
end
A.OutputModes={me='Action text',say='Speech text',mixed='Mixed action + speech'}
A.OutputOrder={'me','say','mixed'}
function A:GetAvailableChannels(cfg,lang,isStock,id)
  if not id and self.db then
    for itemID,item in pairs(self.db.items) do if item==cfg then id=itemID; break end end
  end
  local mode=self.OutputModes[cfg.outputMode] and cfg.outputMode or 'me'
  local result={}
  for _,channel in ipairs({'me','say'}) do
    local lines=self.GetResolvedPhrases and id and self:GetResolvedPhrases(id,lang,channel,isStock) or self:GetPhrases(cfg,lang,channel,isStock)
    if #lines>0 and (mode=='mixed' or mode==channel) then result[#result+1]=channel end
  end
  return result
end
function A:Pick(id,lines,language,channel,isStock,avoidText,avoidOtherText)
  local key=tostring(id)..':'..language..':'..channel..(isStock and ':stock' or ':normal')
  local signature=table.concat(lines,"\n")
  local shuffle=self.shuffles[key]
  if not shuffle or shuffle.signature~=signature or #shuffle.deck==0 then
    shuffle=shuffle or {previous=nil}
    shuffle.length=#lines
    shuffle.signature=signature
    shuffle.deck={}
    for n=1,#lines do shuffle.deck[n]=n end
    for n=#shuffle.deck,2,-1 do
      local j=math.random(n)
      shuffle.deck[n],shuffle.deck[j]=shuffle.deck[j],shuffle.deck[n]
    end
    if #shuffle.deck>1 and shuffle.deck[#shuffle.deck]==shuffle.previous then
      shuffle.deck[#shuffle.deck],shuffle.deck[1]=shuffle.deck[1],shuffle.deck[#shuffle.deck]
    end
    self.shuffles[key]=shuffle
  end
  local function avoided(text) return (avoidText and text==avoidText) or (avoidOtherText and text==avoidOtherText) end
  if avoided(lines[shuffle.deck[#shuffle.deck]]) then
    local swapped=false
    for i=1,#shuffle.deck-1 do
      if not avoided(lines[shuffle.deck[i]]) then
        shuffle.deck[i],shuffle.deck[#shuffle.deck]=shuffle.deck[#shuffle.deck],shuffle.deck[i]
        swapped=true;break
      end
    end
    if not swapped then
      for _,text in ipairs(lines) do
        if not avoided(text) then
          shuffle.deck={}
          return self:Pick(id,lines,language,channel,isStock,avoidText,avoidOtherText)
        end
      end
    end
  end
  local n=table.remove(shuffle.deck)
  shuffle.previous=n
  return lines[n]
end
-- Manual mode only prepares text. The player opens and submits the normal chat box.
function A:OpenManualChat()
  local draft=self.manualDraft
  self.manualDraft=nil
  if not draft or self:Now()<draft.at or self:Now()-draft.at>15 then
    self:Say('No fresh RP draft. Use an enabled item first (draft expires after 15 seconds).')
    return
  end
  local cfg=self:GetSettings(draft.itemID)
  if self.db.chatDestination~='local' or not self.db.manualChat or not self.db.auto or not cfg or not cfg.enabled
    or not self:CanSendLegacyInContext(draft.itemID) then return end
  local mode=self.OutputModes[cfg.outputMode] and cfg.outputMode or 'me'
  if mode~='mixed' and mode~=draft.channel then return end
  if InCombatLockdown and InCombatLockdown() then
    self:Say('RP draft unavailable during combat.')
    return
  end
  if draft.itemID==6948 and (not self.hearthCast or self.hearthCast.state~='not_announced') then
    self:Say('Hearthstone departure draft expired when the cast ended.')
    return
  end
  if C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown() then return end
  local now=type(time)=='function' and time() or math.floor(self:Now())
  local elapsed=now-(self.db.globalLastEmoteAt or 0)
  local secs=self.db.globalCooldown or 30
  if secs>0 and elapsed>=0 and elapsed<secs then return end
  if draft.itemID==6948 and now-(self.db.hearthLastAnnounceAt or 0)<120 then return end
  local getActive=ChatFrameUtil and ChatFrameUtil.GetActiveWindow or ChatEdit_GetActiveWindow
  local active=type(getActive)=='function' and getActive()
  if active then
    self:Say('Finish your current chat draft first; RP text was not inserted.')
    return
  end
  local open=ChatFrameUtil and ChatFrameUtil.OpenChat or ChatFrame_OpenChat
  if type(open)~='function' then
    self:Say('Chat draft API unavailable. Local preview: '..draft.text)
    return
  end
  local ok=pcall(open,(draft.channel=='say' and '/say ' or '/emote ')..draft.text)
  if not ok then self.last.result='manual_chat_draft_rejected'; return end
  self.lastProbe={at=self:Now(),start=draft.text,observed=false,itemID=draft.itemID,
    channel=draft.channel,manual=true}
  self.last.result='manual_chat_draft_opened_press_enter'
  -- No send timestamp here: opening/cancelling an edit box does not send chat.
end
-- Group destination is independent of context scope and phrase-pool selection.
function A:GetGroupChatDestination()
  local _,destination=self:GetGroupContext()
  return destination
end
function A:GetGroupSpeechChannels(cfg,lang,stock,id)
  if not id and self.db then for itemID,item in pairs(self.db.items) do if item==cfg then id=itemID;break end end end
  local lines=self.GetResolvedPhrases and id and self:GetResolvedPhrases(id,lang,'say',stock) or self:GetPhrases(cfg,lang,'say',stock)
  return #lines>0 and {'say'} or {}
end
-- Public automatic path: speech only, regardless of dormant legacy settings.
function A:SendForItem(id,link,isStock)
  if self.IsQuestItem and self:IsQuestItem(id) then
    self.last.result='quest_item_excluded_no_send'; return
  end
  return self:SendLegacyForItem(id,link,isStock,true)
end
-- Retained local /me and /say implementation for possible future client support.
function A:SendLegacyForItem(id,link,isStock,groupSpeech)
  self.manualDraft=nil
  local cfg=self:GetSettings(id)
  self:Debug('RP selection item='..id..' text='..(groupSpeech and 'group speech' or tostring(cfg and cfg.outputMode or 'me'))..' lastItem='..tostring(not not isStock))
  if not cfg or not cfg.enabled then
    self.last.result='confirmed_item_disabled'
    return
  end
  local language=self.db.language=='de' and 'de' or 'en'
  local channels=groupSpeech and self:GetGroupSpeechChannels(cfg,language,isStock,id) or self:GetAvailableChannels(cfg,language,isStock,id)
  if #channels==0 then
    self.last.result='confirmed_no_phrases_for_language_or_mode'
    return
  end
  local allowed,scopeReason
  if groupSpeech then allowed,scopeReason=self:CanSendInContext(id)
  else allowed,scopeReason=self:CanSendLegacyInContext(id) end
  if not allowed then
    self.last.result='confirmed_scope_suppressed_'..tostring(scopeReason)
    return
  end
  local groupOutput=groupSpeech or self.db.chatDestination~='local'
  local destination=groupOutput and self:GetGroupChatDestination() or nil
  self.last.destination=destination or (groupOutput and 'none' or 'local')
  if groupOutput and not destination and self.db.auto then
    self.last.result='confirmed_no_group_no_send'
    return
  end
  -- /say automated outdoors requires a hardware event. Never silently fall
  -- back to /me against the player's mode choice.
  local eligible={}
  local inInstance=type(IsInInstance)=='function' and IsInInstance() or false
  for _,ch in ipairs(channels) do
    if groupOutput or self.db.manualChat or ch=='me' or inInstance then eligible[#eligible+1]=ch end
  end
  if #eligible==0 then
    self.last.result='confirmed_say_hardware_restricted_outdoors_no_send'
    self:Debug('/say needs manual input outdoors; no automatic message sent.')
    return
  end
  local channel=eligible[math.random(#eligible)]
  local lines=self:GetPhrases(cfg,language,channel,isStock)
  local template
  if self.PickLibrary then
    template=self:PickLibrary(id,language,channel,isStock)
    self.last.textSource=self.lastLibrarySource
    self:Debug('Text source='..tostring(self.lastLibrarySource)..' (general/racial/class default weights 50/30/20)')
  else template=self:Pick(id,lines,language,channel,isStock) end
  if not template then self.last.result="confirmed_no_phrases_for_language_or_mode"; return end
  if template:find('{item}',1,true)
     and (type(link)~='string' or not link:find('|Hitem:',1,true)) then
    self.last.result='confirmed_missing_genuine_item_link_no_send'
    return
  end
  local message=template:gsub('{item}',function() return link end)
  if groupOutput and channel=='me' then
    local name=type(UnitName)=='function' and UnitName('player') or nil
    if type(issecretvalue)=='function' and issecretvalue(name) then name=nil end
    if type(name)~='string' or name=='' then
      self.last.result='confirmed_player_name_unavailable_no_send'; return
    end
    message=name..' '..message
  end
  self.last.text=message
  self.last.channel=channel
  self.last.echo='none'
  self:Debug('RP prepared pool='..channel..' destination='..tostring(destination or 'local')..' bytes='..#message)
  if #message>255 then
    self.last.result='confirmed_message_exceeds_chat_limit_no_send'
    self:Say('RP text exceeds 255 chat bytes for item '..id..'.')
    return
  end
  if not self.db.auto then
    self.last.result='confirmed_auto_off_preview_only'
    self:Say('Local preview ('..channel..'): '..message)
    return
  end
  if C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown() then
    self.last.result='confirmed_chat_lockdown_no_send'
    self:Say('Chat lockdown. Local preview: '..message)
    return
  end
  local secs=self.db.globalCooldown or 30
  local elapsed=(type(time)=='function' and time() or math.floor(self:Now()))-(self.db.globalLastEmoteAt or 0)
  if secs>0 and elapsed>=0 and elapsed<secs then
    self.last.result='confirmed_shared_cooldown_'..(secs-elapsed)..'s_no_send'
    self:Debug('Shared RP throttle suppressed message: '..(secs-elapsed)..'s left.')
    return false
  end
  if not groupOutput and self.db.manualChat then
    self.manualDraft={at=self:Now(),itemID=id,channel=channel,text=message}
    self.last.result='confirmed_manual_draft_ready_no_send'
    self:Say('RP ready: /frp send opens the text; press Enter to send (15 seconds).')
    return false
  end
  if not (C_ChatInfo and C_ChatInfo.SendChatMessage) then
    self.last.result='confirmed_chat_api_unavailable'
    return
  end
  destination=destination or (channel=='say' and 'SAY' or 'EMOTE')
  self.last.destination=destination
  local probe={at=self:Now(),start=message:match('^([^|]+)') or '',observed=false,itemID=id,channel=channel,destination=destination}
  self.lastProbe=probe
  self.last.result='confirmed_send_attempted_no_echo_yet'
  local ok,err=pcall(C_ChatInfo.SendChatMessage,message,destination)
  if not ok or err==false then
    self.lastProbe=nil
    self.last.result='confirmed_send_rejected'
    self:Say('RP message rejected: '..tostring(err))
    return
  end
  -- Throttle only when the chat API accepted the send attempt.
  -- A local chat echo confirms reception later; delivery to others is unverified.
  self.db.globalLastEmoteAt=(type(time)=='function' and time() or math.floor(self:Now()))
  self.last.stock=isStock and 'out_of_stock' or 'normal'
  self:Debug('RP send attempted to '..destination..', item '..id)
  if C_Timer and C_Timer.After then
    C_Timer.After(3,function()
      if A.lastProbe==probe and not probe.observed then
        A.last.result='confirmed_send_no_local_echo_unverified'
        A:Debug('No own chat echo detected.')
      end
    end)
  end
  return true
end
function A:OnChatEcho(event,message,author,_,_,_,_,_,_,_,_,_,guid)
  local p=self.lastProbe
  if not p or p.observed or self:Now()-p.at>8 then return end
  local expected=p.destination and ('CHAT_MSG_'..p.destination) or (p.channel=='say' and 'CHAT_MSG_SAY' or 'CHAT_MSG_EMOTE')
  if event~=expected and not (p.destination=='RAID' and event=='CHAT_MSG_RAID_LEADER')
    and not (p.destination=='PARTY' and event=='CHAT_MSG_PARTY_LEADER')
    and not (p.destination=='INSTANCE_CHAT' and event=='CHAT_MSG_INSTANCE_CHAT_LEADER') then return end
  if type(issecretvalue)=='function' then
    if issecretvalue(message) or issecretvalue(author) or issecretvalue(guid) then return end
  end
  if type(message)~='string' then return end
  local ownGUID=UnitGUID('player')
  if type(guid)=='string' and guid~='' then
    if guid~=ownGUID then return end
  elseif type(author)~='string' or author:match('^[^-]+')~=UnitName('player') then
    return
  end
  if #p.start>=8 and not message:find(p.start,1,true) then return end
  if p.manual and not message:find(p.start,1,true) then return end
  p.observed=true
  if p.manual then
    local now=type(time)=='function' and time() or math.floor(self:Now())
    self.db.globalLastEmoteAt=now
    if p.itemID==6948 then self.db.hearthLastAnnounceAt=now end
  end
  self.last.echo='observed'
  self.last.result='confirmed_own_'..p.channel..'_echo_observed'
  self:Debug('Own '..p.channel..' chat event observed. External delivery not verified.')
end
