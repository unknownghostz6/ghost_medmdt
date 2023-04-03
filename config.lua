--[[....................................]]--
--[[       Config by i3ucky#4415        ]]--
--[[            wildfired.de            ]]--
--[[....................................]]--

Config = {}

--[[ Command ]]--
Config.Command = "mdt"

--[[ Allowed Jobs ]]--
Config.Jobs = {"doctor","doctor2","doctor3","doctor4","doctorsb","doctorbw"}

--[[ Offices ]]--
Config.UseOffice = false
Config.Open = { 
	['key'] = 0xCEFD9220, -- E
	['text'] = "~e~[E] ~q~to open archive",
	} 
Config.Office = {
    [1] = {
        coords={-304.10, 829.9, 120.0}, -- Valentine
    },
    [2] = {
        coords={-325.81, 819.8, 118.0}, -- Valentine 2
    }
}

--[[ Notifys ]]--
Config.Notify = {  
	['1'] = "Changes have been saved.", 
	['2'] = "Changes to the report saved.",
	['3'] = "Report was deleted successfully.",
	['4'] = "A new report has been submitted.",
	['5'] = "", 
	['6'] = "",
	['7'] = "This report cannot be found.",
	['8'] = "Telegram Saved.",
	['9'] = "Telegram Deleted.",
	} 