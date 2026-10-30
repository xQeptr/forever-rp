local A=ForeverRP
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
        return nil,'Line '..sourceLine..': maximum '..self.MAX_LINES_PER_ITEM..' phrases per text pool.'
      end
      if #line>200 then
        return nil,'Line '..sourceLine..': maximum 200 bytes per phrase ('..#line..' bytes).'
      end
      -- Never allow a user-supplied WoW hyperlink to bypass the real {item} link.
      if line:find('|H',1,true) or line:find('|h',1,true) then
        return nil,'Line '..sourceLine..': paste plain text, not item hyperlinks; {item} is optional.'
      end
      if type(itemLink)=='string' and itemLink~='' and line:find('{item}',1,true) then
        local rendered=line:gsub('{item}',function()return itemLink end)
        if #rendered>255 then
          return nil,'Line '..sourceLine..': rendered item link makes the message '..#rendered..' bytes (max. 255).'
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
    if type(line)=='string' and self:ParseLines(line) and not line:find('[\r\n]') then
      valid[#valid+1]=line
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
A.OutputModes={me='Only /me',say='Only /say',mixed='Mixed /me + /say'}
A.OutputOrder={'me','say','mixed'}
function A:GetAvailableChannels(cfg,lang,isStock)
  local mode=self.OutputModes[cfg.outputMode] and cfg.outputMode or 'me'
  local result={}
  for _,channel in ipairs({'me','say'}) do
    local lines=self:GetPhrases(cfg,lang,channel,isStock)
    if #lines>0 and (mode=='mixed' or mode==channel) then result[#result+1]=channel end
  end
  return result
end
function A:Pick(id,lines,language,channel,isStock)
  local key=tostring(id)..':'..language..':'..channel..(isStock and ':stock' or ':normal')
  local shuffle=self.shuffles[key]
  if not shuffle or shuffle.length~=#lines or #shuffle.deck==0 then
    shuffle=shuffle or {previous=nil}
    shuffle.length=#lines
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
  local n=table.remove(shuffle.deck)
  shuffle.previous=n
  return lines[n]
end
function A:SendForItem(id,link,isStock)
  local cfg=self:GetSettings(id)
  if not cfg or not cfg.enabled then
    self.last.result='confirmed_item_disabled'
    return
  end
  local language=self.db.language=='de' and 'de' or 'en'
  local channels=self:GetAvailableChannels(cfg,language,isStock)
  if #channels==0 then
    self.last.result='confirmed_no_phrases_for_language_or_mode'
    return
  end
  local allowed,scopeReason=self:CanSendInContext(id)
  if not allowed then
    self.last.result='confirmed_scope_suppressed_'..tostring(scopeReason)
    return
  end
  -- /say automated outdoors requires a hardware event. Never silently fall
  -- back to /me against the player's mode choice.
  local eligible={}
  local inInstance=type(IsInInstance)=='function' and IsInInstance() or false
  for _,ch in ipairs(channels) do
    if ch=='me' or inInstance then eligible[#eligible+1]=ch end
  end
  if #eligible==0 then
    self.last.result='confirmed_say_hardware_restricted_outdoors_no_send'
    self:Debug('/say needs manual input outdoors; no automatic message sent.')
    return
  end
  local channel=eligible[math.random(#eligible)]
  local lines=self:GetPhrases(cfg,language,channel,isStock)
  local template=self:Pick(id,lines,language,channel,isStock)
  if template:find('{item}',1,true)
     and (type(link)~='string' or not link:find('|Hitem:',1,true)) then
    self.last.result='confirmed_missing_genuine_item_link_no_send'
    return
  end
  local message=template:gsub('{item}',function() return link end)
  self.last.text=message
  self.last.channel=channel
  self.last.echo='none'
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
  if not (C_ChatInfo and C_ChatInfo.SendChatMessage) then
    self.last.result='confirmed_chat_api_unavailable'
    return
  end
  local secs=self.db.globalCooldown or 30
  local elapsed=(type(time)=='function' and time() or math.floor(self:Now()))-(self.db.globalLastEmoteAt or 0)
  if secs>0 and elapsed>=0 and elapsed<secs then
    self.last.result='confirmed_shared_cooldown_'..(secs-elapsed)..'s_no_send'
    self:Debug('Shared RP throttle suppressed message: '..(secs-elapsed)..'s left.')
    return false
  end
  local probe={at=self:Now(),start=message:match('^([^|]+)') or '',observed=false,itemID=id,channel=channel}
  self.lastProbe=probe
  self.last.result='confirmed_send_attempted_no_echo_yet'
  local ok,err=pcall(C_ChatInfo.SendChatMessage,message,channel=='say' and 'SAY' or 'EMOTE')
  if not ok then
    self.lastProbe=nil
    self.last.result='confirmed_send_rejected'
    self:Say('RP message rejected: '..tostring(err))
    return
  end
  -- Throttle only when the chat API accepted the send attempt.
  -- A local chat echo confirms reception later; delivery to others is unverified.
  self.db.globalLastEmoteAt=(type(time)=='function' and time() or math.floor(self:Now()))
  self.last.stock=isStock and 'out_of_stock' or 'normal'
  self:Debug('Automatic /'..(channel=='say' and 'say' or 'me')..' attempted, item '..id)
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
  if event~=(p.channel=='say' and 'CHAT_MSG_SAY' or 'CHAT_MSG_EMOTE') then return end
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
  p.observed=true
  self.last.echo='observed'
  self.last.result='confirmed_own_'..p.channel..'_echo_observed'
  self:Debug('Own '..p.channel..' chat event observed. External delivery not verified.')
end
