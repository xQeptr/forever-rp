-- Forever RP v0.9.11: Eternal Ink badge; transparent ring, no extra frame.
local A=ForeverRP
local ICON='Interface\\AddOns\\ForeverRP\\Media\\ForeverRP_Icon.tga'
local function relocate(b)
  if not (b and Minimap and A.db) then return end
  local angle=math.rad(A.db.minimapAngle or 220)
  -- Center of button is slightly outside map. The 32px circular badge overlaps
  -- the map edge by ~6px, as typical minimap addon icons do.
  local width=(Minimap.GetWidth and Minimap:GetWidth()) or 140
  local height=(Minimap.GetHeight and Minimap:GetHeight()) or width
  if width<=0 then width=140 end
  if height<=0 then height=width end
  local radius=math.min(width,height)/2 + 10
  b:ClearAllPoints()
  b:SetPoint('CENTER',Minimap,'CENTER',math.cos(angle)*radius,math.sin(angle)*radius)
end
function A:UpdateMinimapVisibility()
  if not self.db then return end
  if not self.minimapButton then self:SetupMinimap(); return end
  if self.db.showMinimap then self.minimapButton:Show() else self.minimapButton:Hide() end
end
function A:SetupMinimap()
  if not Minimap or not self.db then return end
  if self.minimapButton then self:UpdateMinimapVisibility(); return end
  local b=CreateFrame('Button','ForeverRPMinimapButton',Minimap)
  b:SetFrameStrata('MEDIUM')
  b:SetFrameLevel(Minimap:GetFrameLevel()+8)
  b:SetSize(32,32)
  b:RegisterForClicks('LeftButtonUp')
  b:RegisterForDrag('LeftButton')
  -- No MiniMap-TrackingBorder: its painted ring is offset within the
  -- atlas, so it misaligns with centered icon textures (the v0.9.9 bug).
  -- Our artwork includes the gold ring and transparent corners.
  local icon=b:CreateTexture(nil,'ARTWORK')
  icon:SetAllPoints(b)
  icon:SetTexture(ICON)
  icon:SetTexCoord(0,1,0,1)
  b.icon=icon
  b:SetScript('OnClick',function()
    if A.configFrame and A.configFrame:IsShown() then A.configFrame:Hide()
    else A:ShowConfig() end
  end)
  b:SetScript('OnEnter',function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,'ANCHOR_LEFT')
    GameTooltip:SetText('Forever RP')
    GameTooltip:AddLine(A.L and A:L('Click: open configuration') or 'Click: open configuration',1,1,1)
    GameTooltip:AddLine(A.L and A:L('Drag: move around minimap') or 'Drag: move around minimap',0.7,0.7,0.7)
    GameTooltip:Show()
  end)
  b:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
  b:SetScript('OnDragStart',function(self)
    self:SetScript('OnUpdate',function(self)
      if not Minimap or not GetCursorPosition then return end
      local x,y=GetCursorPosition()
      local mx,my=Minimap:GetCenter()
      if not x or not mx then return end
      local scale=Minimap:GetEffectiveScale()
      if not scale or scale==0 then return end
      x=x/scale-mx; y=y/scale-my
      local atan2=math.atan2 or function(yy,xx)
        if xx==0 then return yy>=0 and math.pi/2 or -math.pi/2 end
        local v=math.atan(yy/xx)
        return xx<0 and v+(yy>=0 and math.pi or -math.pi) or v
      end
      A.db.minimapAngle=math.deg(atan2(y,x))
      relocate(self)
    end)
  end)
  b:SetScript('OnDragStop',function(self) self:SetScript('OnUpdate',nil) end)
  self.minimapButton=b
  if Minimap.HookScript then
    Minimap:HookScript('OnSizeChanged',function() relocate(b) end)
  end
  relocate(b)
  self:UpdateMinimapVisibility()
end
