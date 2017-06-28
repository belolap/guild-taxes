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
GuildTaxes = LibStub("AceAddon-3.0"):NewAddon("GuildTaxes", "AceConsole-3.0", "AceEvent-3.0")


------------------------
-- Initialization
------------------------
function GuildTaxes:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GuildTaxesDB")
	self:RegisterComm(MESSAGE_PREFIX)
end


------------------------
-- Utilites
------------------------
function GuildTaxes:logTransaction()
end


function GuildTaxes:debug(message, n)
	if (DEVELOPMENT or self.debugging) then
		self:Print(CHAT_PREFIX .. "... " .. message)
	end
end


------------------------
-- Slash command
------------------------
function GuildTaxes:onSlashCommand(input)
	self:debug("Slash command: " .. input)
end


------------------------
-- Communication events
------------------------
function GuildTaxes:onCommReceived(prefix, message, destribution, sender)
	self:debug("Communication message recieved")
end


------------------------
-- WoW events handlers
------------------------
function GuildTaxes:PLAYER_ENTERING_WORLD()
	self:debug("Player entering world")
end

function GuildTaxes:PLAYER_MONEY( ... )
	self:debug("Player money")
end

function GuildTaxes:GUILDBANKFRAME_OPENED( ... )
	self:debug("Guild bank opened")
end

function GuildTaxes:GUILDBANKFRAME_CLOSED( ... )
	self:debug("Guild bank closed")
end

function GuildTaxes:MAIL_SHOW( ... )
	self:debug("Open mailbox")
end

function GuildTaxes:MAIL_CLOSED( ... )
	self:debug("Close mailbox")
end

function GuildTaxes:PLAYER_GUILD_UPDATE(unit)
	self:debug("Player change guild")
end


------------------------
-- Register events
------------------------
GuildTaxes:RegisterChatCommand(SLASH_COMMAND, "onSlashCommand")
GuildTaxes:RegisterEvent("PLAYER_ENTERING_WORLD")
GuildTaxes:RegisterEvent("PLAYER_MONEY")
GuildTaxes:RegisterEvent("GUILDBANKFRAME_OPENED")
GuildTaxes:RegisterEvent("GUILDBANKFRAME_CLOSED")
GuildTaxes:RegisterEvent("MAIL_SHOW")
GuildTaxes:RegisterEvent("MAIL_CLOSED")
GuildTaxes:RegisterEvent("PLAYER_GUILD_UPDATE")
