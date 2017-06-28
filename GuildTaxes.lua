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

-- Instantiate
GuildTaxes = LibStub("AceAddon-3.0"):NewAddon("GuildTaxes", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")


------------------------
-- Initialization
------------------------
function GuildTaxes:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GuildTaxesDB")
end


------------------------
-- Utilites
------------------------
function GuildTaxes:LogTransaction()
end


function GuildTaxes:Debug(message, n)
	if (DEVELOPMENT or self.debugging) then
		self:Print(CHAT_PREFIX .. "... " .. message)
	end
end


------------------------
-- Slash command
------------------------
function GuildTaxes:OnSlashCommand(input)
	self:Debug("Slash command: " .. input)
end


------------------------
-- Communication events
------------------------
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
	self:Debug("Open mailbox")
end

function GuildTaxes:MAIL_CLOSED( ... )
	self:Debug("Close mailbox")
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
