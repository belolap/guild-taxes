--
-- GuildTaxes - keep your guild bank full
-- Author: Неогик@Галакронд
--

GuildTaxesConfig = {}

GuildTaxesConfig.AceConfig = {
	name = GT_CONFIG_TITLE;
	handler = nil;
	type = "group";
	args = {
		taxGroup = {
			type = "header";
			name = GT_CONFIG_TAXES_TITLE;
			order = 100;
		};
		rate = {
			type = "range";
			name = GT_CONFIG_TAXES_RANGE;
			desc = GT_CONFIG_TAXES_RANGE_DESC;
			descStyle = "inline";
			min = 0;
			max = 1;
			step = 0.05;
			set = function(info, val) GuildTaxes.db.char.rate = val end;
			get = function(info) return GuildTaxes.db.char.rate end;
			isPercent = true;
			order = 101;
		};
		autopay = {
			type = "toggle";
			name = GT_CONFIG_TAXES_AUTOPAY;
			desc = GT_CONFIG_TAXES_AUTOPAY_DESC;
			descStyle = "inline";
			set = function(info, val) GuildTaxes.db.profile.autopay = val end;
			get = function(info) return GuildTaxes.db.profile.autopay end;
			width = "full";
			order = 102;
		};
		direct = {
			type = "toggle";
			name = GT_CONFIG_TAXES_DIRECT;
			desc = GT_CONFIG_TAXES_DIRECT_DESC;
			descStyle = "inline";
			set = function(info, val) GuildTaxes.db.profile.direct = val end;
			get = function(info) return GuildTaxes.db.profile.direct end;
			width = "full";
			order = 102;
		};
		loggingGroup = {
			type = "header";
			name = GT_CONFIG_LOGGING_TITLE;
			order = 200;
		};
		logging = {
			type = "toggle";
			name = GT_CONFIG_LOGGING_LOG;
			desc = GT_CONFIG_LOGGING_LOG_DESC;
			descStyle = "inline";
			set = function(info, val) GuildTaxes.db.profile.logging = val end;
			get = function(info) return GuildTaxes.db.profile.logging end;
			width = "full";
			order = 201;
		};
		verbose = {
			type = "toggle";
			name = GT_CONFIG_VERBOSE_LOG;
			desc = GT_CONFIG_VERBOSE_LOG_DESC;
			descStyle = "inline";
			set = function(info, val) GuildTaxes.db.profile.verbose = val end;
			get = function(info) return GuildTaxes.db.profile.verbose end;
			width = "full";
			order = 202;
		};
		debug = {
			type = "toggle";
			name = GT_CONFIG_DEBUG_LOG;
			desc = GT_CONFIG_DEBUG_LOG_DESC;
			descStyle = "inline";
			set = function(info, val) GuildTaxes.db.profile.debug = val end;
			get = function(info) return GuildTaxes.db.profile.debug end;
			width = "full";
			order = 203;
		};
	}
}

GuildTaxesConfig.AceOptionsTable = LibStub("AceConfig-3.0")
GuildTaxesConfig.AceOptionsTable:RegisterOptionsTable("GuildTaxes", GuildTaxesConfig.AceConfig)

GuildTaxesConfig.AceConfigDialog = LibStub("AceConfigDialog-3.0")
GuildTaxesConfig.AceConfigDialog:AddToBlizOptions("GuildTaxes", GT_CONFIG_TITLE);
