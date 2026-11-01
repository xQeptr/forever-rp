local A=ForeverRP
A.Classes={
 WARRIOR={color={0.78,0.61,0.43}},
 PALADIN={color={0.96,0.55,0.73}},
 HUNTER={color={0.67,0.83,0.45}},
 ROGUE={color={1,0.95,0.55}},
 PRIEST={color={0.92,0.92,0.92}},
 SHAMAN={color={0.15,0.48,0.87}},
 MAGE={color={0.45,0.8,0.92}},
 WARLOCK={color={0.69,0.49,0.87}},
 DRUID={color={1,0.49,0.04}},
}
function A:GetPlayerClass()
 if type(UnitClass)~='function' then return nil end
 local ok,_,file=pcall(UnitClass,'player')
 if not ok then return nil end
 if type(issecretvalue)=='function' and issecretvalue(file) then return nil end
 if type(file)=='string' and self.Classes[file] then return file end
 return nil
end
