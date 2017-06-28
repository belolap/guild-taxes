--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

-- Build settings
local VERSION = "0.0.1"
local DEVELOPMENT = true
local SLASH_COMMAND = "gt"
local CHAT_PREFIX = "|cffb0c4de" .. GT_CHAT_PREFIX .. ":|r "
local MESSAGE_PREFIX = "GT"

local DEFAULTS = {
	profile = {
		version = 1;
		debug = false;
		verbose = false;
		logging = true;
		rate = 0.05;
		amount = 0;
	}
}


-- Instantiate
GuildTaxes = LibStub("AceAddon-3.0"):NewAddon("GuildTaxes", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")


------------------------
-- Initialization
------------------------
function GuildTaxes:OnInitialize()
	-- User's settings
	self.db = LibStub("AceDB-3.0"):New("GuildTaxesDB", DEFAULTS, true)

	-- Local state vars
	self.isMailOpened = false
	self.isBankOpened = false
end


------------------------
-- Utilites
------------------------
function GuildTaxes:PrintAmount()
end

function GuildTaxes:LogTransaction()
end

function GuildTaxes:Debug(message, n)
	if (DEVELOPMENT or self.db.debug) then
		self:Print(CHAT_PREFIX .. "... " .. message)
	end
end

function GuildTaxes:UpdateGuildInfo()
	if (IsInGuild() and false) then
		if not guild_id then
			-- returns: guildName, guildRankName, guildRankIndex
			guild, realm = GetGuildInfo("player"), GetRealmName()

			if guild and realm then
				guild_id = format("%s-%s", guild, realm):lower()
			end
		end

		if guild_id then
			PAY_MY_TAX_SV[guild_id] = PAY_MY_TAX_SV[guild_id] or 0
			TAX_MOD = PAY_MY_TAX_SV["pmt_tax_mod"]

			pmt:print(format("Платим %i%% налогов в гильдию |cffffff00%s|r из мира %s", 100 * TAX_MOD, guild, realm))
			self:print_tax()
		end
	else
		guild_id = nil
	end
end


------------------------
-- Slash command
------------------------
function GuildTaxes:OnSlashCommand(input)
	self:Debug("Slash command: " .. input)

	local cmd = {}
	for word in input:gmatch("%S+") do
		table.insert(cmd, word)
	end

	local idx, operation = next(cmd)

	if operation == nil then
	else
		self:Debug("Unknown command: " .. operation)
	end

end


------------------------
-- Communication events
------------------------
GuildTaxes.CommEvents = {}

function GuildTaxes:OnCommReceived(prefix, message, distribution, sender)
	self:Debug("Communication message recieved")
end


------------------------
-- WoW events handlers
------------------------
function GuildTaxes:PLAYER_ENTERING_WORLD()
	self:Debug("Player entering world")
end

function GuildTaxes:PLAYER_MONEY( ... )
	self:Debug("Player money")
end

function GuildTaxes:GUILDBANKFRAME_OPENED( ... )
	self:Debug("Guild bank opened")
end

function GuildTaxes:GUILDBANKFRAME_CLOSED( ... )
	self:Debug("Guild bank closed")
end

function GuildTaxes:MAIL_SHOW( ... )
	self.isMailOpened = true
end

function GuildTaxes:MAIL_CLOSED( ... )
	self.isMailOpened = false
end

function GuildTaxes:PLAYER_GUILD_UPDATE(unit)
	self:Debug("Player change guild")
end


------------------------
-- Register events
------------------------
GuildTaxes:RegisterChatCommand(SLASH_COMMAND, "OnSlashCommand")
GuildTaxes:RegisterComm(MESSAGE_PREFIX)
GuildTaxes:RegisterEvent("PLAYER_ENTERING_WORLD")
GuildTaxes:RegisterEvent("PLAYER_MONEY")
GuildTaxes:RegisterEvent("GUILDBANKFRAME_OPENED")
GuildTaxes:RegisterEvent("GUILDBANKFRAME_CLOSED")
GuildTaxes:RegisterEvent("MAIL_SHOW")
GuildTaxes:RegisterEvent("MAIL_CLOSED")
GuildTaxes:RegisterEvent("PLAYER_GUILD_UPDATE")
