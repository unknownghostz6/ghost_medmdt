VORPCore = {}

TriggerEvent("getCore", function(core)
    VORPCore = core
end)

RegisterCommand(""..Config.Command.."", function(source, args)
    local _source = source
	local User = VORPCore.getUser(_source)
    local Character = User.getUsedCharacter
    local job = Character.job
	local jobgrade = Character.jobGrade
	local officername = (Character.firstname.. " " ..Character.lastname)
    local job_access = false
        for k,v in pairs(Config.Jobs) do
            if job == v then
                job_access = true
				exports.ghmattimysql:execute("SELECT * FROM (SELECT * FROM `mdt_med_reports` ORDER BY `id` DESC LIMIT 6) sub ORDER BY `id` DESC", {}, function(reports)
					for r = 1, #reports do
						reports[r].charges = json.decode(reports[r].charges)
					end
					exports.ghmattimysql:execute("SELECT * FROM (SELECT * FROM `mdt_med_warrants` ORDER BY `id` DESC LIMIT 6) sub ORDER BY `id` DESC", {}, function(warrants)
						for w = 1, #warrants do
							warrants[w].charges = json.decode(warrants[w].charges)
						end
						exports.ghmattimysql:execute("SELECT * FROM (SELECT * FROM `mdt_med_telegrams` ORDER BY `id` DESC LIMIT 6) sub ORDER BY `id` DESC", {}, function(note)
							for n = 1, #note do
								note[n].charges = json.decode(note[n].charges)
							end
						TriggerClientEvent('ghost_medmdt:toggleVisibilty', _source, reports, warrants, officername, job, jobgrade, note)

					end)
				end)
			end)
            end
        end
        if job_access == false then
            return false
        end
end)

RegisterServerEvent("ghost_medmdt:getOffensesAndOfficer")
AddEventHandler("ghost_medmdt:getOffensesAndOfficer", function()
	local usource = source
	local Character = VORPCore.getUser(usource).getUsedCharacter
	local officername = (Character.firstname.. " " ..Character.lastname)

	local charges = {}
	exports.ghmattimysql:execute('SELECT * FROM med_types', {}, function(fines)
		for j = 1, #fines do
			if fines[j].category == 0 or fines[j].category == 1 or fines[j].category == 2 or fines[j].category == 3 then
				table.insert(charges, fines[j])
			end
		end

		TriggerClientEvent("ghost_medmdt:returnOffensesAndOfficer", usource, charges, officername)
	end)
end)

RegisterServerEvent("ghost_medmdt:performOffenderSearch")
AddEventHandler("ghost_medmdt:performOffenderSearch", function(query)
	local usource = source
	local matches = {}

	exports.ghmattimysql:execute("SELECT * FROM `characters` WHERE LOWER(`firstname`) LIKE @query OR LOWER(`lastname`) LIKE @query OR CONCAT(LOWER(`firstname`), ' ', LOWER(`lastname`)) LIKE @query", {
		['@query'] = string.lower('%'..query..'%')
	}, function(result)

		for index, data in ipairs(result) do
			table.insert(matches, data)
		end

		TriggerClientEvent("ghost_medmdt:returnOffenderSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("ghost_medmdt:getOffenderDetails")
AddEventHandler("ghost_medmdt:getOffenderDetails", function(offender)
	local usource = source

	--print(offender.charidentifier)

    exports.ghmattimysql:execute('SELECT * FROM `user_med_mdt` WHERE `char_id` = ?', {offender.charidentifier}, function(result)

		if result[1] then
            offender.notes = result[1].notes
            offender.mugshot_url = result[1].mugshot_url
            offender.bail = result[1].bail
		else
			offender.notes = ""
			offender.mugshot_url = ""
			offender.bail = false
		end

        exports.ghmattimysql:execute('SELECT * FROM `user_med_convictions` WHERE `char_id` = ?', {offender.charidentifier}, function(convictions)

            if convictions[1] then
                offender.convictions = {}
                for i = 1, #convictions do
                    local conviction = convictions[i]
                    offender.convictions[conviction.offense] = conviction.count
                end
            end

            exports.ghmattimysql:execute('SELECT * FROM `mdt_med_warrants` WHERE `char_id` = ?', {offender.charidentifier}, function(warrants)

                if warrants[1] then
                    offender.haswarrant = true
                end
			
				TriggerClientEvent("ghost_medmdt:returnOffenderDetails", usource, offender)
            end)
        end)
    end)
end)

RegisterServerEvent("ghost_medmdt:getOffenderDetailsById")
AddEventHandler("ghost_medmdt:getOffenderDetailsById", function(char_id)
    local usource = source
	--print(char_id)

    exports.ghmattimysql:execute('SELECT * FROM `characters` WHERE `charidentifier` = ?', {char_id}, function(result)

        local offender = result[1]

        if not offender then
            TriggerClientEvent("ghost_medmdt:closeModal", usource)
            TriggerClientEvent("ghost_medmdt:sendNotification", usource, "This person no longer exists.")
            return
        end
    
        exports.ghmattimysql:execute('SELECT * FROM `user_med_mdt` WHERE `char_id` = ?', {char_id}, function(result)

			if result[1] then
                offender.notes = result[1].notes
                offender.mugshot_url = result[1].mugshot_url
                offender.bail = result[1].bail
			else
				offender.notes = ""
				offender.mugshot_url = ""
				offender.bail = false
			end

            exports.ghmattimysql:execute('SELECT * FROM `user_med_convictions` WHERE `char_id` = ?', {char_id}, function(convictions) 

                if convictions[1] then
                    offender.convictions = {}
                    for i = 1, #convictions do
                        local conviction = convictions[i]
                        offender.convictions[conviction.offense] = conviction.count
                    end
                end

                exports.ghmattimysql:execute('SELECT * FROM `mdt_med_warrants` WHERE `char_id` = ?', {char_id}, function(warrants)
                    
                    if warrants[1] then
                        offender.haswarrant = true
                    end

					TriggerClientEvent("ghost_medmdt:returnOffenderDetails", usource, offender)
                end)
            end)
        end)
    end)
end)

RegisterServerEvent("ghost_medmdt:saveOffenderChanges")
AddEventHandler("ghost_medmdt:saveOffenderChanges", function(charidentifier, changes, identifier)
	local usource = source

	exports.ghmattimysql:execute('SELECT * FROM `user_med_mdt` WHERE `char_id` = ?', {charidentifier}, function(result)
		if result[1] then
			exports.oxmysql:execute('UPDATE `user_med_mdt` SET `notes` = ?, `mugshot_url` = ?, `bail` = ? WHERE `char_id` = ?', {changes.notes, changes.mugshot_url, changes.bail, charidentifier})
		else
			exports.oxmysql:insert('INSERT INTO `user_med_mdt` (`char_id`, `notes`, `mugshot_url`, `bail`) VALUES (?, ?, ?, ?)', {charidentifier, changes.notes, changes.mugshot_url, changes.bail})
		end

		if changes.convictions ~= nil then
			for conviction, amount in pairs(changes.convictions) do	
				exports.oxmysql:execute('UPDATE `user_med_convictions` SET `count` = ? WHERE `char_id` = ? AND `offense` = ?', {charidentifier, amount, conviction})
			end
		end

		for i = 1, #changes.convictions_removed do
			exports.oxmysql:execute('DELETE FROM `user_med_convictions` WHERE `char_id` = ? AND `offense` = ?', {charidentifier, changes.convictions_removed[i]})
		end

		TriggerClientEvent("ghost_medmdt:sendNotification", usource, Config.Notify['1'])
	end)
end)

RegisterServerEvent("ghost_medmdt:saveReportChanges")
AddEventHandler("ghost_medmdt:saveReportChanges", function(data)
	exports.oxmysql:execute('UPDATE `mdt_med_reports` SET `title` = ?, `incident` = ? WHERE `id` = ?', {data.id, data.title, data.incident})
	TriggerClientEvent("ghost_medmdt:sendNotification", source, Config.Notify['2'])
end)

RegisterServerEvent("ghost_medmdt:deleteReport")
AddEventHandler("ghost_medmdt:deleteReport", function(id)
	exports.oxmysql:execute('DELETE FROM `mdt_med_reports` WHERE `id` = ?', {id})
	TriggerClientEvent("ghost_medmdt:sendNotification", source, Config.Notify['3'])
end)

RegisterServerEvent("ghost_medmdt:deleteNote")
AddEventHandler("ghost_medmdt:deleteNote", function(id)
	exports.oxmysql:execute('DELETE FROM `mdt_med_telegrams` WHERE `id` = ?', {id})
	TriggerClientEvent("ghost_medmdt:sendNotification", source, Config.Notify['9'])
end)

RegisterServerEvent("ghost_medmdt:submitNewReport")
AddEventHandler("ghost_medmdt:submitNewReport", function(data)
	local usource = source
	local User = VORPCore.getUser(usource)
    local Character = User.getUsedCharacter
	local officername = (Character.firstname.. " " ..Character.lastname)

	charges = json.encode(data.charges)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports.oxmysql:insert('INSERT INTO `mdt_med_reports` (`char_id`, `title`, `incident`, `charges`, `author`, `name`, `date`) VALUES (?, ?, ?, ?, ?, ?, ?)', {data.char_id, data.title, data.incident, charges, officername, data.name, data.date,}, function(id)
		TriggerEvent("ghost_medmdt:getReportDetailsById", id, usource)
		TriggerClientEvent("ghost_medmdt:sendNotification", usource, Config.Notify['4'])
	end)

	for offense, count in pairs(data.charges) do
		exports.ghmattimysql:execute('SELECT * FROM `user_med_convictions` WHERE `offense` = ? AND `char_id` = ?', {offense, data.char_id}, function(result)
			if result[1] then
				exports.oxmysql:execute('UPDATE `user_med_convictions` SET `count` = ? WHERE `offense` = ? AND `char_id` = ?', {data.char_id, offense, count + 1})
			else
				exports.oxmysql:insert('INSERT INTO `user_med_convictions` (`char_id`, `offense`, `count`) VALUES (?, ?, ?)', {data.char_id, offense, count})
			end
		end)
	end
end)

RegisterServerEvent("ghost_medmdt:submitNote")
AddEventHandler("ghost_medmdt:submitNote", function(data)
	local usource = source
	local User = VORPCore.getUser(usource)
    local Character = User.getUsedCharacter
	local officername = (Character.firstname.. " " ..Character.lastname)
	charges = json.encode(data.charges)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports.oxmysql:insert('INSERT INTO `mdt_med_telegrams` ( `title`, `incident`, `author`, `date`) VALUES (?, ?, ?, ?)', {data.title, data.note, officername, data.date,}, function(id)
		TriggerEvent("ghost_medmdt:getNoteDetailsById", id, usource)
		TriggerClientEvent("ghost_medmdt:sendNotification", usource, Config.Notify['8'])
	end)
end)

RegisterServerEvent("ghost_medmdt:performReportSearch")
AddEventHandler("ghost_medmdt:performReportSearch", function(query)
	local usource = source
	local matches = {}
	exports.ghmattimysql:execute("SELECT * FROM `mdt_med_reports` WHERE `id` LIKE @query OR LOWER(`title`) LIKE @query OR LOWER(`name`) LIKE @query OR LOWER(`author`) LIKE @query or LOWER(`charges`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			data.charges = json.decode(data.charges)
			table.insert(matches, data)
		end

		TriggerClientEvent("ghost_medmdt:returnReportSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("ghost_medmdt:getWarrants")
AddEventHandler("ghost_medmdt:getWarrants", function()
	local usource = source
	exports.ghmattimysql:execute("SELECT * FROM `mdt_med_warrants`", {}, function(warrants)
		for i = 1, #warrants do
			warrants[i].expire_time = ""
			warrants[i].charges = json.decode(warrants[i].charges)
		end
		TriggerClientEvent("ghost_medmdt:returnWarrants", usource, warrants)
	end)
end)

RegisterServerEvent("ghost_medmdt:submitNewWarrant")
AddEventHandler("ghost_medmdt:submitNewWarrant", function(data)
	local usource = source
	local User = VORPCore.getUser(usource)
    local Character = User.getUsedCharacter
	local officername = (Character.firstname.. " " ..Character.lastname)

	data.charges = json.encode(data.charges)
	data.author = officername
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports.oxmysql:insert('INSERT INTO `mdt_med_warrants` (`name`, `char_id`, `report_id`, `report_title`, `charges`, `date`, `expire`, `notes`, `author`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {data.name, data.char_id, data.report_id, data.report_title, data.charges, data.date, data.expire, data.notes, data.author}, function()
		TriggerClientEvent("ghost_medmdt:completedWarrantAction", usource)
		TriggerClientEvent("ghost_medmdt:sendNotification", usource, Config.Notify['5'])
	end)
end)

RegisterServerEvent("ghost_medmdt:deleteWarrant")
AddEventHandler("ghost_medmdt:deleteWarrant", function(id)
	local usource = source
	exports.oxmysql:execute('DELETE FROM `mdt_med_warrants` WHERE `id` = ?', {id}, function()
		TriggerClientEvent("ghost_medmdt:completedWarrantAction", usource)
	end)
	TriggerClientEvent("ghost_medmdt:sendNotification", usource, Config.Notify['6'])
end)

RegisterServerEvent("ghost_medmdt:getReportDetailsById")
AddEventHandler("ghost_medmdt:getReportDetailsById", function(query, _source)
	if _source then source = _source end
	local usource = source
	exports.ghmattimysql:execute("SELECT * FROM `mdt_med_reports` WHERE `id` = ?", {query}, function(result)
		if result and result[1] then
			result[1].charges = json.decode(result[1].charges)
			TriggerClientEvent("ghost_medmdt:returnReportDetails", usource, result[1])
		else
			TriggerClientEvent("ghost_medmdt:closeModal", usource)
			TriggerClientEvent("ghost_medmdt:sendNotification", usource, Config.Notify['7'])
		end
	end)
end)

RegisterServerEvent("ghost_medmdt:getNoteDetailsById")
AddEventHandler("ghost_medmdt:getNoteDetailsById", function(query, _source)
	if _source then source = _source end
	local usource = source
	exports.ghmattimysql:execute("SELECT * FROM `mdt_med_telegrams` WHERE `id` = ?", {query}, function(result)
		if result and result[1] then
			TriggerClientEvent("ghost_medmdt:returnNoteDetails", usource, result[1])
		else
			TriggerClientEvent("ghost_medmdt:closeModal", usource)
			TriggerClientEvent("ghost_medmdt:sendNotification", usource, Config.Notify['8'])
		end
	end)
end)