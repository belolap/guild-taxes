--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

local Type, Version = "GuildTaxesTableRow", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local _G = _G
local CreateFrame, UIParent = CreateFrame, UIParent


--------------------------------------------------------------------------------
-- Methods
--------------------------------------------------------------------------------
local methods = {
	["OnAcquire"] = function(self)
		self:SetHeight(24)
		self:SetWidth(200)
	end,

	["SetFullName"] = function(self, fullName)
		self.fullName:SetText(fullName)
	end,
}


--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------
local function Constructor()

	local name = Type .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent)
	--frame:Hide()

	local fullName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	fullName:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -4)
	fullName:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -4)
	fullName:SetJustifyH("LEFT")
	fullName:SetText(ACCEPT)
	fullName:SetHeight(10)

	local widget = {
		type = Type,
		frame = frame,
		fullName = fullName,
	}

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
