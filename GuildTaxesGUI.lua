--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

local AceGUI = LibStub("AceGUI-3.0")

local GUI = {
	["db"] = GuildTaxes.db;
}

GuildTaxes.GUI = GUI

-- Create layout
GUI.frame = AceGUI:Create("Frame")
GUI.frame:SetTitle("Hello, world!")

--------------------------------------------------------------------------------
function GUI:Toggle()
	if self.frame:IsShown() then
		self.frame:Hide()
	else
		self.frame:Show()
	end
end

--------------------------------------------------------------------------------
function GUI:OnClose(widget)

end


--------------------------------------------------------------------------------
-- Set callbacks
--------------------------------------------------------------------------------
GUI.frame:SetCallback("OnClose", GUI.OnClose)
