--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

local Type, Version = "GuildTaxesMembersTable", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local _G = _G
local CreateFrame, UIParent, Ambiguate = CreateFrame, UIParent, Ambiguate


--------------------------------------------------------------------------------
-- Methods
--------------------------------------------------------------------------------
local function MoneyString(value)
	if value then
		return GetCoinTextureString(floor(value / 100 / 100) * 100 * 100)
	end
	return "-"
end

local function CreateRow(self, parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetHeight(self.rowHeight)
	row.cols = {}
	for i, r in pairs(self.columns) do
		local col = CreateFrame("Button", nil, row)
		col:SetHeight(self.rowHeight)
		col.textString = col:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		col.textString:SetAllPoints()
		col.textString:SetJustifyH(r[3])
		row.cols[#row.cols + 1] = col
	end
	return row
end

local function LayoutCols(self, row)
	local width = row:GetWidth()
	local height = row:GetHeight()

	local total = 0
	for i=1, #row.cols, 1 do
		total = total + self.columns[i][4]
	end
	local left = 0
	for i, col in pairs(row.cols) do
		local width = (self.columns[i][4] / total) * width
		col:SetWidth(width)
		col:SetHeight(height)
		col:SetPoint("TOPLEFT", left, 0)
		left = left + width
	end
end

local function PrepareData(self)
	local prepared = {}
	local onlineOnly = self.onlineOnly

	for i, v in ipairs(self.data) do
		if not onlineOnly or v.online then
			prepared[#prepared + 1] = v
		end
	end

	return prepared
end

local function Layout(self)
	local fullWidth = self.frame:GetWidth()
	local fullHeight = self.frame:GetHeight()

	self.headerLine:Show()
	self.headerLine:ClearAllPoints()
	self.headerLine:SetPoint("TOPLEFT", 0, 0)
	self.headerLine:SetPoint("TOPRIGHT", -(self.scrollWidth + self.scrollSpace), 0)
	LayoutCols(self, self.headerLine)

	self.scrollBar:ClearAllPoints()
	self.scrollBar:SetPoint("TOPRIGHT", self.frame, -1, -(self.headerHeight + self.headerSpace + 16))
	self.scrollBar:SetPoint("BOTTOMRIGHT", self.frame, -1, 15)

	self.content:ClearAllPoints()
	self.content:SetPoint("TOPLEFT", 0, -(self.headerHeight + self.headerSpace))
	self.content:SetPoint("BOTTOMRIGHT", -(self.scrollWidth + self.scrollSpace), 0)

	self.numRows = max(floor((self.frame:GetHeight() - self.headerHeight) / self.rowHeight), 0)

	while #self.rows < self.numRows do
		self.rows[#self.rows + 1] = CreateRow(self, self.content)
	end

	for i, row in pairs(self.rows) do
		if i > self.numRows then
			row:Hide()
		else
			row:Show()
			row:SetHeight(self.rowHeight)
			row:SetPoint("TOPLEFT", 0, -(i - 1) * self.rowHeight)
			row:SetPoint("TOPRIGHT", 0, -(i - 1) * self.rowHeight)
			LayoutCols(self, row)
		end
	end

	self:RefreshRows()
end

local methods = {
	["OnAcquire"] = function(self)
	end,

	["SetData"] = function(self, data)
		self.data = data
		self:RefreshRows()
	end,

	["SetOnlineOnly"] = function(self, onlineOnly)
		self.onlineOnly = onlineOnly
		self:RefreshRows()
	end,

	["OnWidthSet"] = function(self, width)
		Layout(self)
	end,

	["OnHeightSet"] = function(self, height)
		Layout(self)
	end,

	["RefreshRows"] = function(self)
		if not self.data then return end

		local data = PrepareData(self)

		FauxScrollFrame_Update(self.scroll, #data, self.numRows, self.rowHeight)
		local offset = FauxScrollFrame_GetOffset(self.scroll)

		for i=1, self.numRows do
			if i > #data then
				self.rows[i]:Hide()
			else
				self.rows[i]:Show()
				local rowData = data[i + offset]
				if not rowData then break end
				self.rows[i].cols[1].textString:SetText(Ambiguate(rowData.fullName, "guild"))
				self.rows[i].cols[2].textString:SetText(rowData.rank)
				if rowData.version == nil then
					self.rows[i].cols[3].textString:SetText("")
					self.rows[i].cols[4].textString:SetText("")
					self.rows[i].cols[5].textString:SetText("")
					self.rows[i].cols[6].textString:SetText("")
					self.rows[i].cols[7].textString:SetText("")
				else
					self.rows[i].cols[3].textString:SetText(MoneyString(rowData.tax))
					self.rows[i].cols[4].textString:SetText(MoneyString(rowData.months[1]))
					self.rows[i].cols[5].textString:SetText(MoneyString(rowData.months[2]))
					self.rows[i].cols[6].textString:SetText(MoneyString(rowData.months[3]))
					self.rows[i].cols[7].textString:SetText(MoneyString(rowData.total))
				end
			end
		end
	end,
}


--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------
local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", ("GuildTaxesMembersTable%d"):format(num), UIParent)

	local monthNames = {
			GT_GUI_MONTH_1,
			GT_GUI_MONTH_2,
			GT_GUI_MONTH_3,
			GT_GUI_MONTH_4,
			GT_GUI_MONTH_5,
			GT_GUI_MONTH_6,
			GT_GUI_MONTH_7,
			GT_GUI_MONTH_8,
			GT_GUI_MONTH_9,
			GT_GUI_MONTH_10,
			GT_GUI_MONTH_11,
			GT_GUI_MONTH_12,
	}

	months = {}
	local _, month, _, _ = CalendarGetDate()
	for i=1, 3 do
		months[i] = monthNames[month]
		month = month - 1
		if month == 0 then month = 12 end
	end

	local widget = {
		type = Type,
		frame = frame,
		columns = {
			{"name", GT_GUI_COL_NAME, "LEFT", 1},
			{"name", GT_GUI_COL_RANK, "LEFT", 1},
			{"name", GT_GUI_COL_TAX, "RIGHT", 0.5},
			{"name", months[1], "RIGHT", 0.5},
			{"name", months[2], "RIGHT", 0.5},
			{"name", months[3], "RIGHT", 0.5},
			{"name", GT_GUI_COL_TOTAL, "RIGHT", 0.5},
		},
		numRows = 0,
		rowHeight = 16,
		headerHeight = 16,
		headerSpace = 4,
		scrollWidth = 16,
		scrollSpace = 6,
		thumbHeight = 50,
		rows = {},
		data = {},
		onlineOnly = true
	}

	widget.headerLine = CreateRow(widget, frame)
	for i, col in pairs(widget.headerLine.cols) do
		col.textString:SetText(widget.columns[i][2])
	end

	widget.content = CreateFrame("Frame", nil, frame)

	widget.scroll = CreateFrame("ScrollFrame", frame:GetName() .. "ScrollFrame", frame, "FauxScrollFrameTemplate")
	widget.scroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, widget.rowHeight, function() widget:RefreshRows() end)
	end)

	local scrollBar = _G[widget.scroll:GetName() .. "ScrollBar"]
	scrollBar:SetWidth(widget.scrollWidth)
	widget.scrollBar = scrollBar

	local thumb = scrollBar:GetThumbTexture()
	thumb:SetPoint("CENTER")
	thumb:SetHeight(widget.thumbHeight)
	thumb:SetWidth(widget.scrollWidth)

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
