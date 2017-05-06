local function getmodifiedstring(topic_tab, modifier)
	if type(modifier) == "table" then
		local ret = topic_tab
		for i,v in ipairs(modifier) do
			if ret == nil then
				return nil
			end
			ret = ret[v]
		end
		return ret
	else
		return (modifier ~= nil and topic_tab[modifier])
			or topic_tab.GENERIC
			or (#topic_tab > 0 and topic_tab[math.random(#topic_tab)] or nil)
	end
end

local function getcharacterstring(tab, item, modifier)
    if tab == nil then
        return
    end

    local topic_tab = tab[item]
    if topic_tab == nil then
        return
    elseif type(topic_tab) == "string" then
        return topic_tab
    elseif type(topic_tab) ~= "table" then
        return
    end

	if type(modifier) == "table" then
		for i,v in ipairs(modifier) do
			v = string.upper(v)
		end
	else
		modifier = modifier ~= nil and string.upper(modifier) or nil
	end

	return getmodifiedstring(topic_tab, modifier)
end

function GetGenderStrings(charactername)
    for gender,characters in pairs(CHARACTER_GENDERS) do
        if table.contains(characters, charactername) then
            return gender
        end
    end
    return "DEFAULT"
end

---------------------------------------------------------
--"Oooh" string stuff
local Oooh_endings = { "h", "oh", "ohh" }
local Oooh_punc = { ".", "?", "!" }

local function ooohstart(isstart)
    local str = isstart and "O" or "o"
    local l = math.random(2, 4)
    for i = 2, l do
        str = str..(math.random() > 0.3 and "o" or "O")
    end
    return str
end

local function ooohspace()
    local c = math.random()
    local str =
        (c <= .1 and "! ") or
        (c <= .2 and ". ") or
        (c <= .3 and "? ") or
        (c <= .4 and ", ") or
        " "
    return str, c <= .3
end

local function ooohend()
    return Oooh_endings[math.random(#Oooh_endings)]
end

local function ooohpunc()
    return Oooh_punc[math.random(#Oooh_punc)]
end

local function CraftOooh() -- Ghost speech!
    local isstart = true
    local length = math.random(6)
    local str = ""
    for i = 1, length do
        str = str..ooohstart(isstart)..ooohend()
        if i ~= length then
            local space
            space, isstart = ooohspace()
            str = str..space
        end
    end
    return str..ooohpunc()
end

--V2C: Left this here as a global util function so mods or other characters can use it easily.
function Umlautify(string)
    if not Profile:IsWathgrithrFontEnabled() then
        return string
    end

    local ret = ""
    local last = false
    for i = 1, #string do
        local c = string:sub(i,i)
        if not last and (c == "o" or c == "O") then
            ret = ret .. ((c == "o" and "�") or (c == "O" and "�") or c)
            last = true
        else
            ret = ret .. c
            last = false
        end
    end
    return ret
end

---------------------------------------------------------

local wilton_sayings =
{
    "Ehhhhhhhhhhhhhh.",
    "Eeeeeeeeeeeer.",
    "Rattle.",
    "click click click click",
    "Hissss!",
    "Aaaaaaaaa.",
    "mooooooooooooaaaaan.",
    "...",
}

function GetSpecialCharacterString(character)
    if character == nil then
        return nil
    end

    character = string.lower(character)

    return (character == "mime" and "")
        or (character == "ghost" and CraftOooh())
        or (character == "wilton" and wilton_sayings[math.random(#wilton_sayings)])
        or nil
end

--V2C: Deprecated, set talker.mod_str_fn in character prefab definitions instead
--     Kept for backward compatibility with mods
function GetSpecialCharacterPostProcess(character, string)
    return string
end

-- When calling GetString, must pass actual instance of entity if it might be used when ghost
-- Otherwise, handing inst.prefab directly to the function call is okay
function GetString(inst, stringtype, modifier)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    character = character ~= nil and string.upper(character) or nil
    stringtype = stringtype ~= nil and string.upper(stringtype) or nil
	if type(modifier) == "table" then
		for i,v in ipairs(modifier) do
			v = string.upper(v)
		end
	else
		modifier = modifier ~= nil and string.upper(modifier) or nil
	end

    local specialcharacter =
        type(inst) == "table"
        and ((inst:HasTag("mime") and "mime") or
        (inst:HasTag("playerghost") and "ghost"))
        or character

    return GetSpecialCharacterString(specialcharacter)
        or getcharacterstring(STRINGS.CHARACTERS[character], stringtype, modifier)
        or getcharacterstring(STRINGS.CHARACTERS.GENERIC, stringtype, modifier)
        or ("UNKNOWN STRING: "..(character or "").." "..(stringtype or "").." "..(modifier or ""))
end

function GetActionString(action, modifier)
    return getcharacterstring(STRINGS.ACTIONS, action, modifier) or "ACTION"
end

-- When calling GetDescription, must pass actual instance of entity if it might be used when ghost
-- Otherwise, handing inst.prefab directly to the function call is okay
function GetDescription(inst, item, modifier)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    character = character ~= nil and string.upper(character) or nil
    local itemname = item.nameoverride or item.components.inspectable.nameoverride or item.prefab or nil
    itemname = itemname ~= nil and string.upper(itemname) or nil
	if type(modifier) == "table" then
		for i,v in ipairs(modifier) do
			v = string.upper(v)
		end
	else
		modifier = modifier ~= nil and string.upper(modifier) or nil
	end

    local specialcharacter =
        type(inst) == "table"
        and ((inst:HasTag("mime") and "mime") or
            (inst:HasTag("playerghost") and "ghost"))
        or character

    local ret = GetSpecialCharacterString(specialcharacter)
    if ret ~= nil then
        return ret
    end

    if character ~= nil and STRINGS.CHARACTERS[character] ~= nil then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].DESCRIBE, itemname, modifier)
        if ret ~= nil then
            if item ~= nil and item.components.repairable ~= nil and not item.components.repairable.noannounce and item.components.repairable:NeedsRepairs() then
                return ret..(getcharacterstring(STRINGS.CHARACTERS[character], "ANNOUNCE_CANFIX", modifier) or "")
            end
            return ret
        end
    end

    ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.DESCRIBE, itemname, modifier)

    if item ~= nil and item.components.repairable ~= nil and not item.components.repairable.noannounce and item.components.repairable:NeedsRepairs() then
        if ret ~= nil then
            return ret..(getcharacterstring(STRINGS.CHARACTERS.GENERIC, "ANNOUNCE_CANFIX", modifier) or "")
        end
        ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC, "ANNOUNCE_CANFIX", modifier)
        if ret ~= nil then
            return ret
        end
    end

    return ret or STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC
end

-- When calling GetActionFailString, must pass actual instance of entity if it might be used when ghost
-- Otherwise, handing inst.prefab directly to the function call is okay
function GetActionFailString(inst, action, reason)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    local specialcharacter =
        type(inst) == "table"
        and ((inst:HasTag("playerghost") and "ghost") or
            (inst:HasTag("mime") and "mime"))
        or character

    local ret = GetSpecialCharacterString(specialcharacter)
    if ret ~= nil then
        return ret
    end

    character = string.upper(character)

    return (STRINGS.CHARACTERS[character] ~= nil and getcharacterstring(STRINGS.CHARACTERS[character].ACTIONFAIL, action, reason))
        or getcharacterstring(STRINGS.CHARACTERS.GENERIC.ACTIONFAIL, action, reason)
        or STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC
end

function FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end

function TrimString( s )
   return string.match( s, "^()%s*$" ) and "" or string.match( s, "^%s*(.*%S)" )
end

-- usage:
-- subfmt("this is my {adjective} string, read it {number} times!", {adjective="cool", number="five"})
-- => "this is my cool string, read it five times"
function subfmt(s, tab)
  return (s:gsub('(%b{})', function(w) return tab[w:sub(2, -2)] or w end))
end
