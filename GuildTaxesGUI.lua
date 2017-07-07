--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

local AceGUI = LibStub("AceGUI-3.0")

local GUI = {
	frame = nil,
	status = "-",
	data = {},
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
	self.frame:SetStatusText(self.status)
	--self.frame.frame:SetScript("PLAYER_LOGIN", )

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
	self.table:SetOnlineOnly(GuildTaxes.db.profile.onlineOnly)
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
	self.onlineCheckBox:SetValue(GuildTaxes.db.profile.onlineOnly)
	self.filterGroup:AddChild(self.onlineCheckBox)
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
function GUI:OnOnlineValueChanged(event, value)
	GuildTaxes.db.profile.onlineOnly = value
	GUI.table:SetOnlineOnly(value)
end

--------------------------------------------------------------------------------
function GUI:UpdatePayedStatus()
	local guild = GuildTaxes.guildName
	local tax = GuildTaxes:GetTax()
	local rate = GuildTaxes:GetRate()
	if floor(tax) > 0 then
		self.status = format(GT_GUI_TAX, GuildTaxes:FormatMoney(tax))
	else
		self.status = GT_GUI_ALL_PAYED
	end
	self.status = self.status .. format(GT_GUI_GENERAL_INFO, rate * 100, guild)
	if self:IsShown() then
		GUI.frame:SetStatusText(self.status)
	end
end

--------------------------------------------------------------------------------
function GUI:RefreshTable()
	self.data = {}

	local statusDB = GuildTaxes:GetStatusDB()
	local historyDB = GuildTaxes:GetHistoryDB()

	for index = 1, GuildTaxes.numberMembers, 1 do
		local r = {}
		r.fullName, r.rank, r.rankIndex, _, _, _, _, _, r.online, _, _, _, _, _, _, _ = GetGuildRosterInfo(index)

		local shortName = Ambiguate(r.fullName, "guild")

		local userStatus = statusDB[shortName]
		if userStatus ~= nil then
			r.timestamp = userStatus.timestamp
			r.version = userStatus.version
			r.tax = userStatus.tax
			r.rate = userStatus.rate
		end

		r.months = {}
		local userHistory = historyDB[shortName]
		if userHistory ~= nil then
			local _, month, _, year = CalendarGetDate()
			for i=1, 3 do
				r.months[i] = userHistory[GuildTaxes:HistoryKey(year, month)]
				month = month - 1
				if month == 0 then
					month = 12
					year = year - 1
				end
			end
			r.total = userHistory.total
		end

		self.data[#self.data + 1] = r
	end

	self.table:SetData(self.data)
end
