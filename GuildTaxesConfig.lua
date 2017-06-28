GuildTaxesConfig = {}

GuildTaxesConfig.AceConfig = {
	name = GT_CONFIG_TITLE;
	handler = nil;
	type = "group";
	args = {
		loggingGroup = {
			type = "header";
			name = GT_CONFIG_LOGGING_TITLE;
			order = 100;
		};
		logging = {
			type = "toggle";
			name = GT_CONFIG_LOGGING_LOG;
			desc = GT_CONFIG_LOGGING_LOG_DESC;
			set = function(info, val) GuildTaxes.db.profile.logging = val end;
			get = function(info) return GuildTaxes.db.profile.logging end;
			order = 101;
		};
		verbose = {
			type = "toggle";
			name = GT_CONFIG_VERBOSE_LOG;
			desc = GT_CONFIG_VERBOSE_LOG_DESC;
			set = function(info, val) GuildTaxes.db.profile.verbose = val end;
			get = function(info) return GuildTaxes.db.profile.verbose end;
			order = 102;
		}
	}
}

GuildTaxesConfig.AceOptionsTable = LibStub("AceConfig-3.0")
GuildTaxesConfig.AceOptionsTable:RegisterOptionsTable("GuildTaxes", GuildTaxesConfig.AceConfig)

GuildTaxesConfig.AceConfigDialog = LibStub("AceConfigDialog-3.0")
GuildTaxesConfig.AceConfigDialog:AddToBlizOptions("GuildTaxes", GT_CONFIG_TITLE);
