---Startup sequence
function onModLoaded()
    tm.physics.AddTexture("data_static/terminal_Icon.png", "icon")
    if tm.os.IsSingleplayer() then
        tm.playerUI.AddSubtleMessageForAllPlayers("terminalMod", "Not available in singleplayer.", 3.0, "")
        return
    end

    adminId = 0
    playerList = {}
    tm.os.Log("Mod started.")
    --tm.playerUI.AddSubtleMessageForPlayer(adminId, "terminalMod", "Mod started.", 3.0, "")

    blacklist = {}
    for line in string.gmatch(tm.os.ReadAllText_Dynamic("blacklist.csv"), "[^\n]+") do
        local temp = {}
        for str in string.gmatch(line, "[^,]+") do
            table.insert(temp, str)
        end
        table.insert(blacklist, temp)
    end

    ---CONSTANTS, DO NOT CHANGE AT RUNTIME
    blacklistId = 1
    blacklistUsername = 2
    blacklistReason = 3
end
onModLoaded()

---Registers new players
function PlayerJoin(player)
    local Id = player.playerId
    local Name = tm.players.GetPlayerName(Id)
    local ProfileId = tm.players.GetPlayerProfileId(Id)

    table.insert(playerList, Id)
    tm.os.Log("New player joined. Name: " .. Name .. ", id: " .. Id .. ", profile: " .. ProfileId)

    for i = 1, #blacklist do
        if ProfileId == blacklist[i][blacklistId] then
            tm.os.Log("Kicked: On blacklist.")
            tm.players.Kick(Id)
            tm.playerUI.AddSubtleMessageForPlayer(adminId, "terminalMod", "Blacklisted player kicked.", 3.0, "icon")
            return
        end
    end

    tm.physics.AddTexture("data_static/terminal_Icon.png", "icon")
    tm.playerUI.AddSubtleMessageForPlayer(adminId, "terminalMod", Name .." joined.", 3.0, "icon")
end
tm.players.OnPlayerJoined.add(PlayerJoin)

---Removes player values from relevant locations
function playerLeaving(player)
    local pName = tm.players.GetPlayerName(player.playerId)
    local pId = player.playerId

    tm.os.Log("Player left server. Name: " .. pName .. ". id: " .. pId)

    if pId == adminId then
        adminId = 0
        tm.playerUI.AddSubtleMessageForAllPlayers("terminalMod", "Admin is now: " .. tm.players.GetPlayerName(adminId), 3.0, "")
        tm.os.Log("Admin set to " .. adminId)
    end

    for i = 1, #playerList do
        if playerList[i] == pId then
            table.remove(playerList, i)
        end
    end
end
tm.players.OnPlayerLeft.add(playerLeaving)

---Options for the help command arguments
helpOtions = {"list", "clear", "set", "kick", "blacklist", "admin", "stringEnd"}
---Help text blurbs
helpOptions = {
    list = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "Command: list")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Lists all of the")
        tm.playerUI.AddUILabel(adminId, "Terminal", "specified thing")
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Available argument:")
        for i = 1, #listOptions do
            tm.playerUI.AddUILabel(adminId, "Terminal", "- " .. listOptions[i])
        end
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Call with::")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /list [argument]")
    end,

    clear = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "Command: clear")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Clears all of specified.")
        tm.playerUI.AddUILabel(adminId, "Terminal", "argument. No argument")
        tm.playerUI.AddUILabel(adminId, "Terminal", "clears the UI.")
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Available values:")
        for i = 1, #clearOptions do
            tm.playerUI.AddUILabel(adminId, "Terminal", "- " .. clearOptions[i])
        end
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Call with:")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /clear")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /clear [argument]")
    end,

    set = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "Command: set")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Sets [argument] to")
        tm.playerUI.AddUILabel(adminId, "Terminal", "[value].")
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Available arguments:")
        for i = 1, #setOptions do
            tm.playerUI.AddUILabel(adminId, "Terminal", "- " .. setOptions[i])
        end
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Call with:")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /set [argument] [value]")
    end,

    kick = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "Command: kick")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Kicks player from server.")
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Call with:")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /kick [id of player]")
        tm.playerUI.AddUILabel(adminId, "Terminal", "(The number next to their name.)")
    end,

    blacklist = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "Command: kick")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Kicks player from server")
        tm.playerUI.AddUILabel(adminId, "Terminal", "and adds them to a blacklist.")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Blacklisted players are")
        tm.playerUI.AddUILabel(adminId, "Terminal", "automatically kicked.")
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Available arguments:")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- add [id of player] <reason>")
        tm.playerUI.AddUILabel(adminId, "Terminal", "(The number next to their name,")
        tm.playerUI.AddUILabel(adminId, "Terminal", "     reason is optional)")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- remove [name on blacklist]")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- clear")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- show")
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Call with:")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /blacklist [argument]")
    end,

    admin = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "Value: admin")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Determines who can call")
        tm.playerUI.AddUILabel(adminId, "Terminal", "commands, change with:")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- set admin [id of player]")
        tm.playerUI.AddUILabel(adminId, "Terminal", "(The number next to their name.)")
    end,

    stringEnd = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "Execute commands by sending")
        tm.playerUI.AddUILabel(adminId, "Terminal", "/[command name] in chat, adding")
        tm.playerUI.AddUILabel(adminId, "Terminal", "any parameters at the end.")
        tm.playerUI.AddUILabel(adminId, "Terminal", "(Separated with a space.)")
        tm.playerUI.AddUILabel(adminId, "Terminal", "Text after latest argument")
        tm.playerUI.AddUILabel(adminId, "Terminal", "is ignored.")
        tm.playerUI.AddUILabel(adminId, "Terminal", "-------------------------------------------------------")
        tm.playerUI.AddUILabel(adminId, "Terminal", "For information on commands")
        tm.playerUI.AddUILabel(adminId, "Terminal", "or values send")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /help [name of command]")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /help [name of value]")
        tm.playerUI.AddUILabel(adminId, "Terminal", "- /list all")
    end
}

---Options for list command
listOptions = {"all", "commands", "values"}
---Functions for list command
listActions = {
    all = function ()
        listActions["commands"]()
        listActions["values"]()
    end,

    commands = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "LIST OF COMMANDS:")
        for i = 1, #commandNames do
            tm.playerUI.AddUILabel(adminId, "Terminal", "- " .. commandNames[i])
        end
    end,

    values = function ()
        tm.playerUI.AddUILabel(adminId, "Terminal", "LIST OF CHANGABLE VALUES:")
        for i = 1, #valueNames do
            tm.playerUI.AddUILabel(adminId, "Terminal", "- " .. valueNames[i])
        end
    end
}

---Options for clear command
clearOptions = {"all", "spawns", "builds", "stringEnd"}
---Functions for clear command
clearActions = {
    all = function ()
        clearActions["spawns"]()
        clearActions["builds"]()
        clearActions["stringEnd"]()
    end,

    spawns = function ()
        tm.physics.ClearAllSpawns()
    end,

    builds = function ()
        for i = 1, #playerList do
            local structures = tm.players.GetPlayerStructures(playerList[i])
            for j = 1, #structures do
                structures[j].Dispose()
            end
        end
    end,

    stringEnd = function ()
        tm.playerUI.ClearUI(adminId)
    end
}

---Options for set command
setOptions = {"admin"}
---Functions for set command
setActions = {
    admin = function (words)
        local id = tonumber(words[3])
        if not id then
            tm.os.Log("Ignored: Not a number.")
            tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid id", "Id must be a number.", 3.0, "icon")
            return
        end

        id = id -1

        for i = 1, #playerList do
            if id == playerList[i] then
                tm.playerUI.ClearUI(adminId)
                adminId = id
                tm.playerUI.AddSubtleMessageForAllPlayers("terminalMod", "Admin is now: " .. tm.players.GetPlayerName(adminId), 3.0, "icon")
                tm.os.Log("Admin set to " .. adminId)
                return
            end
        end

        tm.os.Log("Ignored: Not a player.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid id", "Player does not exist.", 3.0, "icon")
    end
}

---Options for blacklist command
blacklistOptions = {"add", "remove", "clear", "show"}
---Functions for blacklist command
blacklistActions = {
    ---Add player to blacklist and kick them
    add = function (words)
        local id = tonumber(words [3])
        if not id then
            tm.os.Log("Ignored: Not a number.")
            tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid id", "Id must be a number.", 3.0, "icon")
            return
        end

        id = id -1
        if id == 0 or id == adminId then
            tm.os.Log("Ignored: Admin.")
            tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid id", "Cant blacklist admin", 3.0, "icon")
            return
        end

        for i = 1, #playerList do
            if id == playerList[i] then
                local reason = ""
                local n = 4
                while words[n] ~= "stringEnd" do
                    reason = reason .. words[n] .. " "
                    n = n + 1
                end

                if reason == "" then
                    reason = "No reason given."
                end

                ---Remove commas so csv doesn't break, replaces spaces in names with underscores so they're a single "word"
                reason = string.gsub(reason, "%,", "")
                local name = string.gsub(tm.players.GetPlayerName(id), "%,", "")
                name = string.gsub(tm.players.GetPlayerName(id), "%s", "_")

                ---Add to blacklist table
                table.insert(blacklist, {tm.players.GetPlayerProfileId(id), name, reason})

                ---Write current blacklist to the .csv
                local newBlacklistStr = ""
                for j = 1, #blacklist do
                    for h = 1, #blacklist[j] do
                        newBlacklistStr = newBlacklistStr .. blacklist[j][h] .. ","
                    end
                    newBlacklistStr = newBlacklistStr .. "\n"
                end
                newBlacklistStr = newBlacklistStr .. "\n" --empty string does not write to file
                tm.os.WriteAllText_Dynamic("blacklist.csv", newBlacklistStr)

                tm.players.Kick(id)
                tm.playerUI.AddSubtleMessageForPlayer(adminId, "Player blacklisted", "Player was also kicked", 3.0, "icon")
                return
            end
        end

        tm.os.Log("Ignored: Not a player.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid id", "Player does not exist.", 3.0, "icon")
    end,

    ---Removes all instance of a player from blacklist
    remove = function (words)
        local found = false
        for i = 1, #blacklist do
            if words[3] == blacklist[i][blacklistUsername] then
                table.remove(blacklist, i)
                found = true
                tm.os.Log("Removed from blacklist")
            end
        end

        if found then
            tm.playerUI.AddSubtleMessageForPlayer(adminId, "Succes", "Player removed from blacklist", 3.0, "icon")
        else
            tm.playerUI.AddSubtleMessageForPlayer(adminId, "Error", "Player not in blacklist", 3.0, "icon")
            tm.os.Log("Ignored: not found")
            return
        end

        ---Write current blacklist to the .csv
        local newBlacklistStr = ""
        for j = 1, #blacklist do
            for h = 1, #blacklist[j] do
                newBlacklistStr = newBlacklistStr .. blacklist[j][h] .. ","
            end
            newBlacklistStr = newBlacklistStr .. "\n"
        end
        newBlacklistStr = newBlacklistStr .. "\n" --empty string does not write to file
        tm.os.WriteAllText_Dynamic("blacklist.csv", newBlacklistStr)
    end,

    ---Clear the blacklist
    clear = function (words)
        tm.os.WriteAllText_Dynamic("blacklist.csv", "\n")
        blacklist = {}
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Blacklist cleared", "", 3.0, "icon")
    end,

    ---List out the blacklist
    show = function (words)
        tm.playerUI.ClearUI(adminId)
        tm.playerUI.AddUILabel(adminId, "Terminal", "Blacklisted accounts:")
        tm.playerUI.AddUILabel(adminId, "Terminal", "[Username], [Reason]")
        for i = 1, #blacklist do
            tm.playerUI.AddUILabel(adminId, "Terminal", blacklist[i][blacklistUsername] .. ", " .. blacklist[i][blacklistReason])
        end
    end
}

---List of commands and changable values
commandNames = {"help", "list", "clear", "set", "kick", "blacklist"}
valueNames = {"admin"}
---Functions to call by their command name
commands = {
    ---Gives info about commands
    help = function (words)
        for i = 1, #helpOtions do
            if words[2] == helpOtions[i] then
                tm.playerUI.ClearUI(adminId)
                helpOptions[words[2]]()
                return
            end
        end

        tm.os.Log("Ignored: Invalid argument.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid arguments", "\"/help\" for arguments.", 3.0, "icon")
    end,

    ---List out all of a thing
    list = function (words)
        for i = 1, #listOptions do
            if words[2] == listOptions[i] then
                tm.playerUI.ClearUI(adminId)
                listActions[words[2]]()
                return
            end
        end

        tm.os.Log("Ignored: Invalid argument.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid arguments", "\"/help list\" for arguments.", 3.0, "icon")
    end,

    ---Clears the ui
    clear = function (words)
        for i = 1, #clearOptions do
            if words[2] == clearOptions[i] then
                clearActions[words[2]]()
                return
            end
        end

        tm.os.Log("Ignored: Invalid argument.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid arguments", "\"/help set\" for arguments.", 3.0, "icon")
    end,

    ---Sets values specified by user
    set = function (words)
        for i = 1, #setOptions do
            if words[2] == setOptions[i] then
                setActions[words[2]](words)
                return
            end
        end

        tm.os.Log("Ignored: Invalid argument.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid arguments", "\"/help blacklist\" for arguments.", 3.0, "icon")
    end,

    ---Kicks a player
    kick = function (words)
        local id = tonumber(words [2])
        if not id then
            tm.os.Log("Ignored: Not a number.")
            tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid id", "Id must be a number.", 3.0, "icon")
            return
        end

        id = id -1

        for i = 1, #playerList do
            if id == playerList[i] then
                tm.players.Kick(id)
                tm.playerUI.AddSubtleMessageForPlayer(adminId, "Player kicked", "", 3.0, "icon")
                return
            end
        end

        tm.os.Log("Ignored: Not a player.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid id", "Player does not exist.", 3.0, "icon")
    end,

    ---Manages a blacklist
    blacklist = function (words)
        for i = 1, #blacklistOptions do
            if words[2] == blacklistOptions[i] then
                blacklistActions[words[2]](words)
                return
            end
        end

        tm.os.Log("Ignored: Invalid argument.")
        tm.playerUI.AddSubtleMessageForPlayer(adminId, "Invalid arguments", "\"/help blacklist\" for arguments.", 3.0, "icon")
    end
}

---Reads sent chat messages and calls commands when admin types them
function chatSent(player, message)
    tm.os.Log("" .. player .. ": " .. message .. "")

    local startindex = string.find(message, "/")
    if player ~= tm.players.GetPlayerName(adminId) or startindex ~= 1 then
        return
    end

    message = string.lower(string.sub(message, 2))
    tm.os.Log("Possible command: " .. message)
    local words = {}
    for str in string.gmatch(message, "%g+") do
        table.insert(words, str)
    end
    table.insert(words, "stringEnd")

    for i = 1, #commandNames do
        if words[1] == commandNames[i] then
            commands[words[1]](words)
            return
        end
    end
    tm.os.Log("Not a command.")
    tm.playerUI.AddSubtleMessageForPlayer(adminId, "Not a command.", "\"/help\" for commands.", 3.0, "icon")
end

tm.playerUI.OnChatMessage.add(chatSent)
