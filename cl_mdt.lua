local isVisible = false
local prop = nil
local JournalOuvert = false

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    SetTextFontForCurrentCommand(15) 
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    DisplayText(str, x, y)
end
    Citizen.CreateThread(function()   
        if Config.UseOffice == true then 
        while true do 
            Citizen.Wait(1)
            local coords = GetEntityCoords(PlayerPedId())
            for k,v in pairs(Config.Office) do
                if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.coords[1], v.coords[2], v.coords[3], false) < 1.0  then
                DrawTxt(Config.Open['text'], 0.50, 0.95, 0.7, 0.5, true, 223, 44, 53, 255, true)
                if IsControlJustPressed(0, Config.Open['key']) then
                    ExecuteCommand(""..Config.Command.."")                
                end    
            end
        end
    end
        end
    end)

--TriggerServerEvent("ghost_medmdt:getOffensesAndOfficer")

RegisterNetEvent("ghost_medmdt:toggleVisibilty")
AddEventHandler("ghost_medmdt:toggleVisibilty", function(reports, warrants, officer, job, grade, note)
    local playerPed = PlayerPedId()
    if not isVisible then
        TriggerServerEvent("ghost_medmdt:getOffensesAndOfficer")
        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
        Wait(1000)
        Citizen.InvokeNative(0x524B54361229154F, PlayerPedId(), GetHashKey("world_human_write_notebook"), 9999999999,true,false, false, false)
    else
        FreezeEntityPosition(PlayerPedId(), false)
        Wait(1000)
        ClearPedSecondaryTask(PlayerPedId())
        ClearPedTasks(PlayerPedId())        
    end
    if #warrants == 0 then warrants = false end
    if #reports == 0 then reports = false end
    if #note == 0 then note = false end
    SendNUIMessage({
        type = "recentReportsAndWarrantsLoaded",
        reports = reports,
        warrants = warrants,
        officer = officer,
        department = job,
        rank = grade,
        note = note,
    })
    ToggleGUI()
end)

RegisterNUICallback("close", function(data, cb)
    FreezeEntityPosition(PlayerPedId(), false)
	ClearPedSecondaryTask(PlayerPedId())
	ClearPedTasks(PlayerPedId())
	SetCurrentPedWeapon(PlayerPedId(), 0xA2719263, true)
    ToggleGUI(false)
    cb('ok')
end)

RegisterNUICallback("performOffenderSearch", function(data, cb)
    TriggerServerEvent("ghost_medmdt:performOffenderSearch", data.query)
    TriggerServerEvent("ghost_medmdt:getOffensesAndOfficer")
    cb('ok')
end)

RegisterNUICallback("viewOffender", function(data, cb)
    TriggerServerEvent("ghost_medmdt:getOffenderDetails", data.offender)
    cb('ok')
end)

RegisterNUICallback("saveOffenderChanges", function(data, cb)
    TriggerServerEvent("ghost_medmdt:saveOffenderChanges", data.id, data.changes, data.identifier)
    cb('ok')
end)

RegisterNUICallback("submitNewReport", function(data, cb)
    TriggerServerEvent("ghost_medmdt:submitNewReport", data)
    cb('ok')
end)

RegisterNUICallback("submitNote", function(data, cb)
    TriggerServerEvent("ghost_medmdt:submitNote", data)
    cb('ok')
end)

RegisterNUICallback("performReportSearch", function(data, cb)
    TriggerServerEvent("ghost_medmdt:performReportSearch", data.query)
    cb('ok')
end)

RegisterNUICallback("getOffender", function(data, cb)
    TriggerServerEvent("ghost_medmdt:getOffenderDetailsById", data.char_id)
    cb('ok')
end)

RegisterNUICallback("deleteReport", function(data, cb)
    TriggerServerEvent("ghost_medmdt:deleteReport", data.id)
    cb('ok')
end)

RegisterNUICallback("deleteNote", function(data, cb)
    TriggerServerEvent("ghost_medmdt:deleteNote", data.id)
    cb('ok')
end)

RegisterNUICallback("saveReportChanges", function(data, cb)
    TriggerServerEvent("ghost_medmdt:saveReportChanges", data)
    cb('ok')
end)

RegisterNUICallback("getWarrants", function(data, cb)
    TriggerServerEvent("ghost_medmdt:getWarrants")
end)

RegisterNUICallback("submitNewWarrant", function(data, cb)
    TriggerServerEvent("ghost_medmdt:submitNewWarrant", data)
    cb('ok')
end)

RegisterNUICallback("deleteWarrant", function(data, cb)
    TriggerServerEvent("ghost_medmdt:deleteWarrant", data.id)
    cb('ok')
end)

RegisterNUICallback("deleteWarrant", function(data, cb)
    TriggerServerEvent("ghost_medmdt:deleteWarrant", data.id)
    cb('ok')
end)

RegisterNUICallback("getReport", function(data, cb)
    TriggerServerEvent("ghost_medmdt:getReportDetailsById", data.id)
    cb('ok')
end)

RegisterNUICallback("getNotes", function(data, cb)
    TriggerServerEvent("ghost_medmdt:getNoteDetailsById", data.id)
    cb('ok')
end)

RegisterNetEvent("ghost_medmdt:returnOffenderSearchResults")
AddEventHandler("ghost_medmdt:returnOffenderSearchResults", function(results)
    SendNUIMessage({
        type = "returnedPersonMatches",
        matches = results
    })
end)

RegisterNetEvent("ghost_medmdt:closeModal")
AddEventHandler("ghost_medmdt:closeModal", function()
    SendNUIMessage({
        type = "closeModal"
    })
end)

RegisterNetEvent("ghost_medmdt:returnOffenderDetails")
AddEventHandler("ghost_medmdt:returnOffenderDetails", function(data)
    SendNUIMessage({
        type = "returnedOffenderDetails",
        details = data
    })
end)

RegisterNetEvent("ghost_medmdt:returnOffensesAndOfficer")
AddEventHandler("ghost_medmdt:returnOffensesAndOfficer", function(data, name)
    SendNUIMessage({
        type = "offensesAndOfficerLoaded",
        offenses = data,
        name = name
    })
end)

RegisterNetEvent("ghost_medmdt:returnReportSearchResults")
AddEventHandler("ghost_medmdt:returnReportSearchResults", function(results)
    SendNUIMessage({
        type = "returnedReportMatches",
        matches = results
    })
end)

RegisterNetEvent("ghost_medmdt:returnWarrants")
AddEventHandler("ghost_medmdt:returnWarrants", function(data)
    SendNUIMessage({
        type = "returnedWarrants",
        warrants = data
    })
end)

RegisterNetEvent("ghost_medmdt:completedWarrantAction")
AddEventHandler("ghost_medmdt:completedWarrantAction", function(data)
    SendNUIMessage({
        type = "completedWarrantAction"
    })
end)

RegisterNetEvent("ghost_medmdt:returnReportDetails")
AddEventHandler("ghost_medmdt:returnReportDetails", function(data)
    SendNUIMessage({
        type = "returnedReportDetails",
        details = data
    })
end)

RegisterNetEvent("ghost_medmdt:returnNoteDetails")
AddEventHandler("ghost_medmdt:returnNoteDetails", function(data)
    SendNUIMessage({
        type = "returnedNoteDetails",
        details = data
    })
end)

RegisterNetEvent("ghost_medmdt:sendNUIMessage")
AddEventHandler("ghost_medmdt:sendNUIMessage", function(messageTable)
    SendNUIMessage(messageTable)
end)

RegisterNetEvent("ghost_medmdt:sendNotification")
AddEventHandler("ghost_medmdt:sendNotification", function(message)
    SendNUIMessage({
        type = "sendNotification",
        message = message
    })
end)

function ToggleGUI(explicit_status)
  if explicit_status ~= nil then
    isVisible = explicit_status
  else
    isVisible = not isVisible
  end
  SetNuiFocus(isVisible, isVisible)
  SendNUIMessage({
    type = "enable",
    isVisible = isVisible
  })
end