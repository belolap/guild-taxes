--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

local AceGUI = LibStub("AceGUI-3.0")

local GUI = {
	frame = nil,
	header = nil,
	tableGroup = nil,
	tableScroll = nil,
	filterGroup = nil,
	onlineCheckBox = nil,
}
GuildTaxes.GUI = GUI

--------------------------------------------------------------------------------
function GUI:Create()
	if self.frame ~= nil then
		return
	end

	-- Main frame
	self.frame = AceGUI:Create("Frame")
	self.frame:SetTitle(GT_GUI_TITLE)
	self.frame:SetLayout("List")
	self.frame.frame:SetScript("OnSizeChanged", GUI.SetTableHeight)

	-- Header
	self.header = AceGUI:Create("GuildTaxesTableRow")
	self.frame:AddChild(self.header)

	-- Table with data
	self.tableGroup = AceGUI:Create("SimpleGroup")
	self.tableGroup:SetFullWidth(true)
	self.tableGroup:SetLayout("Fill")
	self.frame:AddChild(self.tableGroup)

	self.tableScroll = AceGUI:Create("ScrollFrame")
	self.tableScroll:SetLayout("List")
	self.tableGroup:AddChild(self.tableScroll)

	-- Filter group
	self.filterGroup = AceGUI:Create("SimpleGroup")
	self.filterGroup:SetLayout("Flow")
	self.frame:AddChild(self.filterGroup)

	-- Online checkbox
	self.onlineCheckBox = AceGUI:Create("CheckBox")
	self.onlineCheckBox:SetLabel(GT_GUI_ONLINE_ONLY)
	self.filterGroup:AddChild(self.onlineCheckBox)
	self.onlineCheckBox:SetCallback("OnValueChanged", self.OnOnlineCheckBoxClicked)

	-- Adjust table height
	GUI:SetTableHeight()

	-- OnClose event
	self.frame:SetCallback("OnClose", GUI.Destroy)

	-- Fill data
	self:SetOnlineCheckBox()
	self:SetPayedStatus()
	self:RefreshTable()
end

--------------------------------------------------------------------------------
function GUI:SetTableHeight()
	if GUI.frame ~= nil then
		local height = GUI.frame.content.height - GUI.header.frame.height - GUI.filterGroup.frame.height - 3
		GUI.tableGroup:SetHeight(height)
	end
end

--------------------------------------------------------------------------------
function GUI:Destroy()
	AceGUI:Release(self)
	GUI.frame = nil
	GUI.heade = nil
	GUI.tableGroup = nil
	GUI.tableScroll = nil
	GUI.filterGroup = nil
	GUI.onlineCheckBox = nil
end

--------------------------------------------------------------------------------
function GUI:Toggle()
	if self.frame ~= nill then
		self.frame:Hide()
	else
		self:Create()
	end
end

--------------------------------------------------------------------------------
function GUI:IsShown()
	return self.frame ~= nill
end

--------------------------------------------------------------------------------
function GUI:SetOnlineCheckBox()
	self.onlineCheckBox:SetValue(GuildTaxes.db.profile.onlineOnly)
end

--------------------------------------------------------------------------------
function GUI:OnOnlineCheckBoxClicked()
	GuildTaxes.db.profile.onlineOnly = GUI.onlineCheckBox:GetValue()
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
	GuildTaxes:Debug("Refreshing table")
	--[[
	GuildTaxes:Debug("Num of members: " .. GuildTaxes.numberMembers .. "(" .. GuildTaxes.numberMembersOnline .. " online)")

	for index = 1, GuildTaxes.numberMembers do
		local fullName, rank, rankIndex, _, _, _, _, _, _, _, _, _, _, _, _, _ = GetGuildRosterInfo(index)

		local memberRow = AceGUI:Create("GuildTaxesTableRow")
		self.tableScroll:AddChild(memberRow)
	end
	--]]
end

