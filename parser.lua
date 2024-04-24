

BRH.parser = {}
parser = BRH.parser

function parser.addParentheses(match)
    if (match == "%s") then
        return "(.+)"
    else
        return "(" .. match .. ")"
    end
end

BRH.parser.fr = {}

function parser.periodicSpellDamage(msg)
    local target, damage, damageType, source, spellName

    local gs = string.gsub(PERIODICAURADAMAGEOTHEROTHER, "%%s", function(match) return "(.+)" end)
    gs = string.gsub(gs, "%%d", function(match) return "(%d+)" end)

    if (GetLocale() == "frFR") then
        gs = string.gsub(PERIODICAURADAMAGEOTHEROTHER, "%%%d$s", function(match) return "(.+)" end)
        gs = string.gsub(gs, "%%%d$d", function(match) return "(%d+)" end)
    end

    if (string.find(msg, gs)) then
        if(GetLocale() == "frFR") then
            _, _, spellName, source, target, damage, damageType = string.find(msg, gs)
        else
            _, _, target, damage, damageType, source, spellName = string.find(msg, gs)
        end
    else 
        gs = string.gsub(PERIODICAURADAMAGESELFOTHER, "%%s", function(match) return "(.+)" end)
        gs = string.gsub(gs, "%%d", function(match) return "(%d+)" end)
    
        if (GetLocale() == "frFR") then
            gs = string.gsub(PERIODICAURADAMAGESELFOTHER, "%%%d$s", function(match) return "(.+)" end)
            gs = string.gsub(gs, "%%%d$d", function(match) return "(%d+)" end)
        end

        if (string.find(msg, gs)) then
            source = UnitName("player")
            if(GetLocale() == "frFR") then
                _, _, spellName, damage, damageType, target = string.find(msg, gs)
            else
                _, _, target, damage, damageType, spellName = string.find(msg, gs)
            end
        end
    end

    damage = tonumber(damage)

    return target, damage, damageType, source, spellName
end

function parser.partySpellDamage(msg)
	local target, damage, damageSchool, source, spellName, damageType

    local crit = string.gsub(SPELLLOGCRITSCHOOLOTHEROTHER, "%(", function(match) return "%(" end)
    crit = string.gsub(crit, "%)", function(match) return "%)" end)
    crit = string.gsub(crit, "%%s", function(match) return "(.+)" end)
    crit = string.gsub(crit, "%%d", function(match) return "(%d+)" end)

    local hit = string.gsub(SPELLLOGSCHOOLOTHEROTHER, "%%s", function(match) return "(.+)" end)
    hit = string.gsub(hit, "%%d", function(match) return "(%d+)" end)

	if (string.find(msg, crit)) then 
		damageType = "crit"
		_, _, source, spellName, target, damage, damageSchool = string.find(msg, crit)
	elseif (string.find(msg, hit)) then
		damageType = "hit"
		_, _, source, spellName, target, damage, damageSchool = string.find(msg, hit)
	end

    damage = tonumber(damage)

    return target, damage, damageSchool, source, spellName, damageType
end

function parser.selfSpellDamage(msg)
	local target, damage, damageSchool, source, spellName, damageType

    local crit = string.gsub(SPELLLOGCRITSCHOOLSELFOTHER, "%(", function(match) return "%(" end)
    crit = string.gsub(crit, "%)", function(match) return "%)" end)
    crit = string.gsub(crit, "%%s", function(match) return "(.+)" end)
    crit = string.gsub(crit, "%%d", function(match) return "(%d+)" end)

    local hit = string.gsub(SPELLLOGSCHOOLSELFOTHER, "%%s", function(match) return "(.+)" end)
    hit = string.gsub(hit, "%%d", function(match) return "(%d+)" end)

	if (string.find(msg, crit)) then 
		damageType = "crit"
		_, _, spellName, target, damage, damageSchool = string.find(msg, crit)
	elseif (string.find(msg, hit)) then
		damageType = "hit"
		_, _, spellName, target, damage, damageSchool = string.find(msg, hit)
	end

	source = UnitName("Player")
    damage = tonumber(damage)

    return target, damage, damageSchool, source, spellName, damageType
end

function parser.cdStringToSeconds(str)
    local _, _, number = string.find(str, "(%d+)");
    
    if (number == nil) then return 0 end

    if (string.find(str, "sec")) then
        return tonumber(number)
    else 
        return tonumber(number) * 60
    end
end