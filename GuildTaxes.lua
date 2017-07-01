--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

-- Addon settings
local DEVELOPMENT = false
local SLASH_COMMAND = "gt"
local MESSAGE_PREFIX = "GT"

local DEFAULTS = {
	profile = {
		version = 1;
		debug = false;
		verbose = false;
		logging = true;
		autopay = true;
	};
	char = {
		rate = 0.10;
	};
}


-- Instantiate
GuildTaxes = LibStub("AceAddon-3.0"):NewAddon("GuildTaxes", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceHook-3.0")

getmetatable(GuildTaxes).__tostring = function (self)
	return GT_CHAT_PREFIX
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function GuildTaxes:OnInitialize()
	-- User's settings
	self.db = LibStub("AceDB-3.0"):New("GuildTaxesDB", DEFAULTS, true)

	-- Local state vars
	self.guildId = nil
	self.guildName = nil
	self.guildRealm = nil
	self.playerMoney = 0
	self.isMailOpened = false
	self.isBankOpened = false
	self.isPayingTax = false
end


--------------------------------------------------------------------------------
-- Utilites
--------------------------------------------------------------------------------
function GuildTaxes:Debug(message, n)
	if (DEVELOPMENT or self.db.profile.debug) then
		self:Print("|cff999999" .. message .. "|r")
	end
end

--------------------------------------------------------------------------------
function GuildTaxes:PrintGeneralInfo()
	if self.guildId then
		self:Printf(GT_CHAT_GENERAL_INFO, 100 * self.db.char.rate, self.guildName, self.guildRealm)
	end
end

--------------------------------------------------------------------------------
function GuildTaxes:PrintTaxes()
	local message
	if self.db.char[self.guildId].amount >= 1 then
		message = format(GT_CHAT_TAX, GetCoinTextureString(self.db.char[self.guildId].amount))
		if (self.isBankOpened and not self.db.profile.autopay) then
			message = message .. " |Hitem:GuildTaxes:create:|h|cffff8000[" .. GT_CHAT_TAX_CLICK .. "]|r|h"
		end
	else
		message = GT_CHAT_ALL_PAYED
	end
	self:Print(message)
end

--------------------------------------------------------------------------------
function GuildTaxes:PrintTransaction(income, tax)
	if self.db.profile.logging then
		self:Printf(GT_CHAT_TRANSACTION, GetCoinTextureString(income), GetCoinTextureString(tax))
	end
end

--------------------------------------------------------------------------------
function GuildTaxes:PrintPayingTaxes(value)
	self:Printf(GT_CHAT_PAYING_TAX, GetCoinTextureString(value))
end

--------------------------------------------------------------------------------
function GuildTaxes:PrintNothingToPay()
	self:Print(GT_CHAT_NOTHING_TO_PAY)
end

--------------------------------------------------------------------------------
function GuildTaxes:UpdateGuildInfo()
	if IsInGuild() then
		if not self.guildId then
			self.guildName, self.guildRealm = GetGuildInfo("player"), GetRealmName()
			if self.guildName and self.guildRealm then
				self.guildId = format("%s-%s", self.guildName, self.guildRealm):lower()
			end
		end
		if self.guildId then
			if not self.db.char[self.guildId] then
				self.db.char[self.guildId] = {
					amount = 0;
				}
			end
			self:PrintGeneralInfo()
		end
	else
		self.guildId = nil
	end
end

--------------------------------------------------------------------------------
function GuildTaxes:UpdatePlayerMoney(value)
	if not value then
		value = GetMoney()
	end
	self.playerMoney = value
end

--------------------------------------------------------------------------------
function GuildTaxes:AccrueTaxes(income, tax)
	self:Debug("Accrue taxes with " .. tax)
	self.db.char[self.guildId].amount = self.db.char[self.guildId].amount + tax
	self:PrintTransaction(income, tax)
end

--------------------------------------------------------------------------------
function GuildTaxes:ReduceTaxes(tax)
	self:Debug("Reduce taxes with " .. tax)
	self.db.char[self.guildId].amount = self.db.char[self.guildId].amount - tax
end

--------------------------------------------------------------------------------
function GuildTaxes:PayTaxes()
	self:Debug("Paying taxes")
	if not self.isBankOpened then
		self:Print(GT_CHAT_OPEN_BANK)
		return
	end
	self.isPayingTax = true
	self:PrintPayingTaxes(self.db.char[self.guildId].amount)
	DepositGuildBankMoney(self.db.char[self.guildId].amount)
end

--------------------------------------------------------------------------------
function GuildTaxes:PurgeOldData()
	-- TODO: purge old guild info, if guild chnaged
	-- TODO: purge old history records
	-- TODO: purge player's data that left guild
end


--------------------------------------------------------------------------------
-- Slash commands
--------------------------------------------------------------------------------
GuildTaxes.commands = {
	[""]    = "OnPrintTaxesCommand";
	--["gui"] = "OnGUICommand";
}

--------------------------------------------------------------------------------
function GuildTaxes:OnPrintTaxesCommand()
	self:PrintTaxes()
end

function GuildTaxes:OnGUICommand()
	self.GUI:Toggle()
end

--------------------------------------------------------------------------------
function GuildTaxes:OnSlashCommand(input, val)
	local cmd = {}
	for word in input:gmatch("%S+") do
		table.insert(cmd, word)
	end

	local idx, operation = next(cmd)
	if operation == nil then
		operation = ""
	end

	if self.commands[operation] then
		self[self.commands[operation]](self)
	else
		self:Debug("Unknown command: " .. operation)
	end
end


--------------------------------------------------------------------------------
-- Communication events
--------------------------------------------------------------------------------
GuildTaxes.CommEvents = {}

function GuildTaxes:OnCommReceived(prefix, message, distribution, sender)
	self:Debug("Communication message recieved")
end


--------------------------------------------------------------------------------
-- Hyperlink chat handler
--------------------------------------------------------------------------------
function GuildTaxes:ChatFrame_OnHyperlinkShow(chat, link, text, button)
	local command = strsub(link, 1, 4);
	if command == "item" then
		local _, addonName = strsplit(":", link)
		if addonName == "GuildTaxes" then
			local amount = floor(self.db.char[self.guildId].amount)
			if amount > 0 then
				self:PayTaxes()
			else
				self:PrintNothingToPay()
			end
		end
	end
end


--------------------------------------------------------------------------------
-- WoW events handlers
--------------------------------------------------------------------------------
function GuildTaxes:PLAYER_ENTERING_WORLD( ... )
	self:Debug("Player entered world")
	self:UpdatePlayerMoney()
	self:UpdateGuildInfo()
end

--------------------------------------------------------------------------------
function GuildTaxes:PLAYER_MONEY( ... )

	local newPlayerMoney = GetMoney()
	local delta = newPlayerMoney - self.playerMoney

	self:Debug("Player money, delta=" .. tostring(delta))

	if delta > 0 then
		if not self.guildId then
			self:Debug("Not in guild, transaction ignored")
		elseif self.isMailOpened then
			self:Debug("Mailbox is open, transaction ignored")
		elseif self.isBankOpened then
			self:Debug("Guild bank is open, transaction ignored")
		else
			self:AccrueTaxes(delta, delta * self.db.char.rate)
		end

	elseif self.isBankOpened and self.isPayingTax then
		self:ReduceTaxes(-delta)
		self.isPayingTax = false
		self:PrintTaxes()
	else
		self:Debug("Ignoring withdraw")
	end

	self:UpdatePlayerMoney(newPlayerMoney)
end

--------------------------------------------------------------------------------
function GuildTaxes:GUILDBANKFRAME_OPENED( ... )
	self:Debug("Guild bank opened")
	self.isBankOpened = true

	local amount = floor(self.db.char[self.guildId].amount)
	if amount >= 1 and self.db.profile.autopay then
		self:PayTaxes()
	else
		self:PrintTaxes()
	end

end

--------------------------------------------------------------------------------
function GuildTaxes:GUILDBANKFRAME_CLOSED( ... )
	if self.isBankOpened then
		self:Debug("Guild bank closed")
		self.isBankOpened = false
		self.isPayingTax = false
	end
end

--------------------------------------------------------------------------------
function GuildTaxes:MAIL_SHOW( ... )
	self:Debug("Mailbox opened")
	self.isMailOpened = true
end

--------------------------------------------------------------------------------
function GuildTaxes:MAIL_CLOSED( ... )
	if self.isMailOpened then
		self:Debug("Mailbox closed")
		self.isMailOpened = false
	end
end

--------------------------------------------------------------------------------
function GuildTaxes:PLAYER_GUILD_UPDATE(event, unit)
	if unit == "player" then
		self:Debug("Player guild info updated")
		self:UpdateGuildInfo()
	end
end


--------------------------------------------------------------------------------
-- Register events & commands
--------------------------------------------------------------------------------
GuildTaxes:Hook("ChatFrame_OnHyperlinkShow", true)

GuildTaxes:RegisterComm(MESSAGE_PREFIX)

GuildTaxes:RegisterChatCommand(SLASH_COMMAND, "OnSlashCommand")

GuildTaxes:RegisterEvent("PLAYER_ENTERING_WORLD")
GuildTaxes:RegisterEvent("PLAYER_MONEY")
GuildTaxes:RegisterEvent("GUILDBANKFRAME_OPENED")
GuildTaxes:RegisterEvent("GUILDBANKFRAME_CLOSED")
GuildTaxes:RegisterEvent("MAIL_SHOW")
GuildTaxes:RegisterEvent("MAIL_CLOSED")
GuildTaxes:RegisterEvent("PLAYER_GUILD_UPDATE")
