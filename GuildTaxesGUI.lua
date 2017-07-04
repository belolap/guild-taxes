--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

local AceGUI = LibStub("AceGUI-3.0")

local GUI = {
	rowScale = {1, 1, 0.5, 0.5, 0.5, 0.5, 0.5},
	frame = nil,
	table = nil,
	filterGroup = nil,
	onlineCheckBox = nil,
}
GuildTaxes.GUI = GUI


-- Register fake layout
AceGUI:RegisterLayout("Static", function(content, children) end);


--------------------------------------------------------------------------------
function GUI:Create()
	-- Main frame
	self.frame = AceGUI:Create("Frame")
	self.frame:Hide()
	self.frame:SetTitle(GT_GUI_TITLE)
	self.frame:SetLayout("Static")

	-- Frame width
	local width = 500
	if GuildTaxes.db.profile.mainFrameWidth ~= nil then
		width = GuildTaxes.db.profile.mainFrameWidth
	end
	self.frame:SetWidth(width)

	-- Frame height
	local height = 600
	if GuildTaxes.db.profile.mainFrameHeight ~= nil then
		height = GuildTaxes.db.profile.mainFrameHeight
	end
	self.frame:SetHeight(height)

	-- Save frame size
	self.frame.frame:SetScript("OnSizeChanged", function()
		GuildTaxes.db.profile.mainFrameWidth = GUI.frame.frame:GetWidth()
		GuildTaxes.db.profile.mainFrameHeight = GUI.frame.frame:GetHeight()
	end)

	-- OnClose event
	self.frame:SetCallback("OnClose", function (self) AceGUI:Release(self) end)

	-- Members table
	self.table = AceGUI:Create("GuildTaxesMembersTable")
	self.table:SetPoint("TOPLEFT", self.frame.content)
	self.table:SetPoint("BOTTOMRIGHT", self.frame.content, "BOTTOMRIGHT", 0, 50)
	self.frame:AddChild(self.table)

	-- Filter group
	self.filterGroup = AceGUI:Create("SimpleGroup")
	self.filterGroup:SetLayout("Flow")
	self.filterGroup:SetPoint("BOTTOMLEFT", self.frame.content, "BOTTOMLEFT", 0, 10)
	self.filterGroup:SetPoint("BOTTOMRIGHT", self.frame.content, "BOTTOMRIGHT", 0, 10)
	self.frame:AddChild(self.filterGroup)

	-- Online checkbox
	self.onlineCheckBox = AceGUI:Create("CheckBox")
	self.onlineCheckBox:SetLabel(GT_GUI_ONLINE_ONLY)
	self.onlineCheckBox:SetValue(GuildTaxes.db.profile.onlineOnly)
	self.onlineCheckBox:SetCallback("OnValueChanged", self.OnOnlineValueChanged)
	self.filterGroup:AddChild(self.onlineCheckBox)

	-- Load data
	GUI:LoadData()
end

--------------------------------------------------------------------------------
function GUI:Toggle()
	if GUI.frame:IsShown() then
		GUI.frame:Hide()
	else
		GUI:Create()
		GUI.frame:Show()
	end
end

--------------------------------------------------------------------------------
function GUI:IsShown()
	local shown = false
	if GUI.frame ~= nil then
		shown = GUI.frame:IsShown()
	end
	return shown
end

--------------------------------------------------------------------------------
function GUI:LoadData()
	self:SetOnlineCheckBox()
	self:SetPayedStatus()
	if GuildTaxes.numberMembers == nil then
		GuildTaxes:UpdateGuildRoster()
	else
		self:RefreshTable()
	end
end

--------------------------------------------------------------------------------
function GUI:SetOnlineCheckBox()
	self.onlineCheckBox:SetValue(GuildTaxes.db.profile.onlineOnly)
end

--------------------------------------------------------------------------------
function GUI:OnOnlineValueChanged(event, value)
	GuildTaxes.db.profile.onlineOnly = value
end

--------------------------------------------------------------------------------
function GUI:SetPayedStatus()
	local taxes = GuildTaxes:GetTaxes()
	local status
	if floor(taxes) > 0 then
		status = format(GT_GUI_TAX, GetCoinTextureString(taxes))
	else
		status = GT_GUI_ALL_PAYED
	end
	status = status .. format(GT_GUI_GENERAL_INFO, GuildTaxes:GetRate() * 100, GuildTaxes.guildName)
	self.frame:SetStatusText(status)
end

--------------------------------------------------------------------------------
function GUI:RefreshTable()
	local data = {}

	for index = 1, GuildTaxes.numberMembers, 1 do
		local r = {}
		r.fullName, r.rank, r.rankIndex, _, _, _, _, _, r.online, _, _, _, _, _, _, _ = GetGuildRosterInfo(index)
		data[#data + 1] = r
	end

	self.table:SetData(data)
end
