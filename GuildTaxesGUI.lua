--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

local _G = _G

local AceGUI = LibStub("AceGUI-3.0")

local GUI = {}
GuildTaxes.GUI = GUI

-- Create layout
GUI.mainFrame = AceGUI:Create("Frame")
GUI.mainFrame:Hide()

GUI.mainFrame:SetTitle(GT_GUI_TITLE)
GUI.mainFrame:SetLayout("Flow")

--------------------------------------------------------------------------------
function GUI:Toggle()
	if self.mainFrame:IsShown() then
		self.mainFrame:Hide()
	else
		self.mainFrame:Show()
	end
end

--------------------------------------------------------------------------------
function GUI:UpdatePayedStatus()
	local taxes = GuildTaxes:GetTaxes()
	local status
	if floor(taxes) > 0 then
		status = format(GT_GUI_TAX, GetCoinTextureString(taxes))
	else
		status = GT_GUI_ALL_PAYED
	end
	GuildTaxes:Debug(GuildTaxes.db.char.rate)
	status = status .. format(GT_GUI_GENERAL_INFO, GuildTaxes:GetRate() * 100, GuildTaxes.guildName)
	self.mainFrame:SetStatusText(status)
end


--------------------------------------------------------------------------------
-- Main frame events
--------------------------------------------------------------------------------
function GUI.mainFrame:OnShow( ... )
	GuildTaxes:Debug("Main frame showed")
	GUI:UpdatePayedStatus()
end

--------------------------------------------------------------------------------
function GUI.mainFrame:OnClose( ... )
	GuildTaxes:Debug("Main frame closed")
	AceGUI:Release(self)
end


--------------------------------------------------------------------------------
-- Set callbacks
--------------------------------------------------------------------------------
GUI.mainFrame:SetCallback("OnClose", GUI.mainFrame.OnClose)
GUI.mainFrame:SetCallback("OnShow", GUI.mainFrame.OnShow)
