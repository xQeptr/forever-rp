-- Skyborne and class pool integration (Lua 5.1/5.4).
local frame={RegisterEvent=function()end,RegisterUnitEvent=function()end,SetScript=function()end}
function CreateFrame() return setmetatable({},{__index=frame}) end
SlashCmdList={}
function GetTime()return 1000 end
function time()return 1000 end
function IsInGroup()return true end
function IsInInstance()return true,'party' end
C_ChatInfo={SendChatMessage=function()end}
local race,class='Skyborne','PALADIN'
function UnitRace()return 'Localized',race,777 end
function UnitClass()return 'Localized',class,2 end
for line in io.lines('ForeverRP/ForeverRP.toc') do if line:match('%.lua$') then dofile('ForeverRP/'..line) end end
local a=ForeverRP;a.SetupMinimap=function()end;a.ScanBags=function()return {},{}end;a.Say=function()end
ForeverRPDB={items={[118]={enabled=true,autoCategory='potion',librarySchema=1}},defaultScope='always',globalCooldown=0}
a:Init()
assert(a:GetPlayerRace()=='Skyborne' and a:GetPlayerClass()=='PALADIN')
local u,r,k=a:GetLibraryEntries(118,'en','me',false)
assert(#u>0 and #r>0 and #k>0,'missing source pool')
assert(a.Races.Skyborne.color[3]>.9 and a.Races.Skyborne.color[2]>.7)
assert(a.Classes.PALADIN.color[1]>.9)
local ids={};for _,pool in ipairs({a.DefaultEntries,a.RaceEntries,a.ClassEntries})do for _,e in ipairs(pool)do assert(not ids[e.id],'duplicate id '..e.id);ids[e.id]=true end end
local function countSource(n)
 local result={u=0,r=0,k=0}
 local rs,ks={},{}
 for _,e in ipairs(r) do rs[e.text]=true end
 for _,e in ipairs(k) do ks[e.text]=true end
 for i=1,n do local s=a:PickLibrary(118,'en','me');if rs[s] then result.r=result.r+1 elseif ks[s] then result.k=result.k+1 else result.u=result.u+1 end end
 return result
end
math.randomseed(421)
local draws=countSource(10000)
assert(draws.u>4000 and draws.u<7000 and draws.r>1700 and draws.r<4000 and draws.k>600 and draws.k<3000,'nominal 50/30/20 source weighting with single-line no-repeat fallback: '..draws.u..'/'..draws.r..'/'..draws.k)
local selected=r[1];a:SetDefaultDisabled(selected.id,true);assert(a:IsDefaultDisabled(selected.id));a:Init();assert(a:IsDefaultDisabled(selected.id))
assert(a:GetLibraryEntries(6948,'en','me',true)~=nil)
race='Skybourne';assert(a:GetPlayerRace()=='Skyborne')
race='Unknown';assert(a:GetPlayerRace()==nil)
local uu,rr,kk=a:GetLibraryEntries(118,'en','me',false);assert(#uu>0 and #rr==0 and #kk>0)
class='UNKNOWN';assert(a:GetPlayerClass()==nil)
local _,_,absent=a:GetLibraryEntries(118,'en','me',false);assert(#absent==0)
print('PASS identity sources: Skyborne aliases, 50/30/20, class fallback, disabled stability')
