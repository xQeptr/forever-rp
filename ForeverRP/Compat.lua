-- Forever RP: read-only runtime compatibility diagnostics.
-- Forever 1.60.x and Retail 12.x both use the Mainline API architecture.
local A=ForeverRP
function A:CompatInfo()
  local version,build,_,interface='unknown','unknown',nil,0
  if type(GetBuildInfo)=='function' then
    local ok,v,b,_,i=pcall(GetBuildInfo)
    if ok then version=v or version; build=b or build; interface=tonumber(i) or 0 end
  end
  local project=type(WOW_PROJECT_ID)=='number' and WOW_PROJECT_ID or nil
  local mainline=type(WOW_PROJECT_MAINLINE)=='number' and WOW_PROJECT_MAINLINE or nil
  local flavor='unknown'
  if interface>=16000 and interface<17000 then flavor='Forever (1.60.x candidate)'
  elseif interface>=120000 then flavor='Retail (12.x candidate)'
  end
  local capabilities={
    {'Bag slots', C_Container and type(C_Container.GetContainerNumSlots)=='function'},
    {'Bag item info', C_Container and type(C_Container.GetContainerItemInfo)=='function'},
    {'Item spell', C_Item and type(C_Item.GetItemSpell)=='function'},
    {'Item class', C_Item and type(C_Item.GetItemInfoInstant)=='function'},
    {'Chat emote API', C_ChatInfo and type(C_ChatInfo.SendChatMessage)=='function'},
    {'Tooltip API (optional)', C_TooltipInfo and type(C_TooltipInfo.GetBagItem)=='function'},
  }
  local ok=true
  for i=1,#capabilities do
    if i<6 and not capabilities[i][2] then ok=false end
  end
  return {version=version,build=build,interface=interface,project=project,
    mainline=mainline,flavor=flavor,capabilities=capabilities,coreReady=ok}
end
function A:PrintCompat()
  local info=self:CompatInfo()
  self:Say('Client: '..info.flavor..' | version='..tostring(info.version)..' | build='..tostring(info.build)..' | interface='..tostring(info.interface))
  self:Say('Project ID='..tostring(info.project)..' | Mainline ID='..tostring(info.mainline)..' | Core APIs='..(info.coreReady and 'present' or 'INCOMPLETE'))
  for _,cap in ipairs(info.capabilities) do
    self:Say(cap[1]..': '..(cap[2] and 'OK' or 'MISSING'))
  end
  local race=self:GetPlayerRace()
  local class=self.GetPlayerClass and self:GetPlayerClass() or nil
  self:Say('RP identity: '..tostring(race or 'unknown')..' / '..tostring(class or 'unknown'))
  self:Say('Note: API availability does not prove that automatic chat delivery works. Verify in game.')
end
