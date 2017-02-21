function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end

function ListModifiers(hUnit)

    if not hUnit then
        print('Failed to find unit to  list modifiers.')
        return
    end

    print('Modifiers for '..hUnit:GetUnitName())

    local count = hUnit:GetModifierCount()
    for i=0,count-1 do
        print(hUnit:GetModifierNameByIndex(i))
    end
end

function Quadric (a,b,c)  --解一元二次方程 输出最大值
   local a2 = 2*a
   local d = math.sqrt(b^2 - 4*a*c)
   x1 = (-b + d)/a2
   x2 = (-b - d)/a2
   if x1>x2 then
     return x1
   else
     return x2
   end
end



-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'





function ReportHeroAbilities(hHero)
  if IsValidEntity(hHero) then
    for i=1,20 do
        local ability=hHero:GetAbilityByIndex(i-1)
        if ability then
            print("Abilities Report: "..hHero:GetUnitName().."ability["..i.."] is "..ability:GetAbilityName())
        else
            print("Abilities Report: "..hHero:GetUnitName().."ability["..i.."] is empty")
        end
    end
  end
end



--============ Copyright (c) Valve Corporation, All rights reserved. ==========
--
--
--=============================================================================

--/////////////////////////////////////////////////////////////////////////////
-- Debug helpers
--
--  Things that are really for during development - you really should never call any of this
--  in final/real/workshop submitted code
--/////////////////////////////////////////////////////////////////////////////

-- if you want a table printed to console formatted like a table (dont we already have this somewhere?)
scripthelp_LogDeepPrintTable = "Print out a table (and subtables) to the console"
logFile = "log/log.txt"

function LogDeepSetLogFile( file )
	logFile = file
end

function LogEndLine ( line )
	AppendToLogFile(logFile, line .. "\n")
end

function _LogDeepPrintMetaTable( debugMetaTable, prefix )
	_LogDeepPrintTable( debugMetaTable, prefix, false, false )
	if getmetatable( debugMetaTable ) ~= nil and getmetatable( debugMetaTable ).__index ~= nil then
		_LogDeepPrintMetaTable( getmetatable( debugMetaTable ).__index, prefix )
	end
end

function _LogDeepPrintTable(debugInstance, prefix, isOuterScope, chaseMetaTables ) 
    prefix = prefix or ""
    local string_accum = ""
    if debugInstance == nil then 
		LogEndLine( prefix .. "<nil>" )
		return
    end
	local terminatescope = false
	local oldPrefix = ""
    if isOuterScope then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" then 
            LogEndLine( prefix .. "{" )
			oldPrefix = prefix
            prefix = prefix .. "   "
			terminatescope = true
        else 
            LogEndLine( prefix .. " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance))
        end
    end
    local debugOver = debugInstance

	-- First deal with metatables
	if chaseMetaTables == true then
		if getmetatable( debugOver ) ~= nil and getmetatable( debugOver ).__index ~= nil then
			local thisMetaTable = getmetatable( debugOver ).__index 
			if vlua.find(_LogDeepprint_alreadyseen, thisMetaTable ) ~= nil then 
				LogEndLine( string.format( "%s%-32s\t= %s (table, already seen)", prefix, "metatable", tostring( thisMetaTable ) ) )
			else
				LogEndLine(prefix .. "metatable = " .. tostring( thisMetaTable ) )
				LogEndLine(prefix .. "{")
				table.insert( _LogDeepprint_alreadyseen, thisMetaTable )
				_LogDeepPrintMetaTable( thisMetaTable, prefix .. "   ", false )
				LogEndLine(prefix .. "}")
			end
		end
	end

	-- Now deal with the elements themselves
	-- debugOver sometimes a string??
    for idx, data_value in pairs(debugOver) do
        if type(data_value) == "table" then 
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then 
                LogEndLine( string.format( "%s%-32s\t= %s (table, already seen)", prefix, idx, tostring( data_value ) ) )
            else
                local is_array = #data_value > 0
				local test = 1
				for idx2, val2 in pairs(data_value) do
					if type( idx2 ) ~= "number" or idx2 ~= test then
						is_array = false
						break
					end
					test = test + 1
				end
				local valtype = type(data_value)
				if is_array == true then
					valtype = "array table"
				end
                LogEndLine( string.format( "%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), valtype ) )
                LogEndLine(prefix .. (is_array and "[" or "{"))
                table.insert(_LogDeepprint_alreadyseen, data_value)
                _LogDeepPrintTable(data_value, prefix .. "   ", false, true)
                LogEndLine(prefix .. (is_array and "]" or "}"))
            end
		elseif type(data_value) == "string" then 
            LogEndLine( string.format( "%s%-32s\t= \"%s\" (%s)", prefix, idx, data_value, type(data_value) ) )
		else 
            LogEndLine( string.format( "%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), type(data_value) ) )
        end
    end
	if terminatescope == true then
		LogEndLine( oldPrefix .. "}" )
	end
end


function LogDeepPrintTable( debugInstance, prefix, isPublicScriptScope ) 
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    _LogDeepPrintTable(debugInstance, prefix, true, isPublicScriptScope )
end


--/////////////////////////////////////////////////////////////////////////////
-- Fancy new LogDeepPrint - handles instances, and avoids cycles
--
--/////////////////////////////////////////////////////////////////////////////

-- @todo: this is hideous, there must be a "right way" to do this, im dumb!
-- outside the recursion table of seen recurses so we dont cycle into our components that refer back to ourselves
_LogDeepprint_alreadyseen = {}


-- the inner recursion for the LogDeep print
function _LogDeepToString(debugInstance, prefix) 
    local string_accum = ""
    if debugInstance == nil then 
        return "LogDeep Print of NULL" .. "\n"
    end
    if prefix == "" then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" or type(debugInstance) == "table" or type(debugInstance) == "UNKNOWN" or type(debugInstance) == "table" then 
            string_accum = string_accum .. (type(debugInstance) == "table" and "[" or "{") .. "\n"
            prefix = "   "
        else 
            return " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance) .. "\n"
        end
    end
    local debugOver = type(debugInstance) == "UNKNOWN" and getclass(debugInstance) or debugInstance
    for idx, val in pairs(debugOver) do
        local data_value = debugInstance[idx]
        if type(data_value) == "table" or type(data_value) == "table" or type(data_value) == "UNKNOWN" or type(data_value) == "table" then 
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then 
                string_accum = string_accum .. prefix .. idx .. " ALREADY SEEN " .. "\n"
            else 
                local is_array = type(data_value) == "table"
                string_accum = string_accum .. prefix .. idx .. " = ( " .. type(data_value) .. " )" .. "\n"
                string_accum = string_accum .. prefix .. (is_array and "[" or "{") .. "\n"
                table.insert(_LogDeepprint_alreadyseen, data_value)
                string_accum = string_accum .. _LogDeepToString(data_value, prefix .. "   ")
                string_accum = string_accum .. prefix .. (is_array and "]" or "}") .. "\n"
            end
        else 
            --string_accum = string_accum .. prefix .. idx .. "\t= " .. (type(data_value) == "string" and ("\"" .. data_value .. "\"") or data_value) .. "\n"
			string_accum = string_accum .. prefix .. idx .. "\t= " .. "\"" .. tostring(data_value) .. "\"" .. "\n"
        end
    end
    if prefix == "   " then 
        string_accum = string_accum .. (type(debugInstance) == "table" and "]" or "}") .. "\n" -- hack for "proving" at end - this is DUMB!
    end
    return string_accum
end


scripthelp_LogDeepString = "Convert a class/array/instance/table to a string"

function LogDeepToString(debugInstance, prefix) 
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    return _LogDeepToString(debugInstance, prefix)
end


scripthelp_LogDeepPrint = "Print out a class/array/instance/table to the console"

function LogDeepPrint(debugInstance, prefix) 
    prefix = prefix or ""
    LogEndLine(LogDeepToString(debugInstance, prefix))
end



NHLog = function( ... )  
    local tv = "\n"  
    local xn = 0  
    local function tvlinet(xn)  
        -- body  
        for i=1,xn do  
            tv = tv.."\t"  
        end  
    end  
  
    local function printTab(i,v)  
        -- body  
        if type(v) == "table" then  
            tvlinet(xn)  
            xn = xn + 1  
            tv = tv..""..i..":Table{\n"  
            table.foreach(v,printTab)  
            tvlinet(xn)  
            tv = tv.."}\n"  
            xn = xn - 1  
        elseif type(v) == nil then  
            tvlinet(xn)  
            tv = tv..i..":nil\n"  
        else  
            tvlinet(xn)  
            tv = tv..i..":"..tostring(v).."\n"   
        end  
    end  
    local function dumpParam(tab)  
        for i=1, #tab do    
            if tab[i] == nil then   
                tv = tv.."nil\t"  
            elseif type(tab[i]) == "table" then   
                xn = xn + 1  
                tv = tv.."\ntable{\n"  
                table.foreach(tab[i],printTab)  
                tv = tv.."\t}\n"  
            else  
                tv = tv..tostring(tab[i]).."\t"  
            end  
        end  
    end  
    local x = ...  
    if type(x) == "table" then  
        table.foreach(x,printTab)  
    else  
        dumpParam({...})  
        -- table.foreach({...},printTab)  
    end  
    print(tv)  
end  


function LevelUpAbility(unit,sAbilityName)
    print("sAbilityName "..sAbilityName)
    local ability=unit:FindAbilityByName(sAbilityName)
    if ability~=nil then
        local currentLevel=ability:GetLevel()
        print("currentLevel "..currentLevel)
        local maxLevel=ability:GetMaxLevel()
        print("maxLevel "..maxLevel)
        if currentLevel<maxLevel then
           ability:SetLevel(currentLevel+1)
           print("LevelUpAbility "..sAbilityName.." Success")
        end
    end
end


function RemoveAllAbilities(hHero)
  if IsValidEntity(hHero) then
    for i=1,24 do
        local ability=hHero:GetAbilityByIndex(i-1)
        if ability then
            hHero:RemoveAbility(ability:GetAbilityName())
        end
    end
  end
end



function RandomPosition(event)
    local caster = event.caster
    local target = event.target
    local range = event.range
    local min = 200
    if event.min then
        min = event.min
    end
    local vec = RandomVector(1.0)
    local vec2 = Vector(vec[1],vec[2],0):Normalized()*math.random(min,range)

    if event.circledynamic and event.circledynamic > 0 and caster then
        local i = 1
        if event.clockwise and caster:GetHealth() / caster:GetMaxHealth() < 0.75 and caster:GetHealth() / caster:GetMaxHealth() > 0.25 then
            i = -1
        end
        if caster.circle_array then
            caster.circle_array = caster.circle_array + i
        else
            caster.circle_array = 1
        end
        if caster.circle_array > event.circledynamic then
            caster.circle_array = 1
        end
        if caster.circle_array < 1 then
            caster.circle_array = event.circledynamic
        end
        local vecs = {}
        local offset_degree = 360 / event.circledynamic
        local offset_start = 0
        if event.degreeoffset then
            offset_start = event.degreeoffset
        end
       

        vec2 = Vector(range*math.cos(math.rad(offset_start+offset_degree*caster.circle_array)), range*math.sin(math.rad(offset_start+offset_degree*caster.circle_array)), 0)

    end
    target:SetAbsOrigin(caster:GetAbsOrigin()+vec2)
end
