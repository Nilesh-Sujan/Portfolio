local Settings = {}
local MarketplaceService = game:GetService("MarketplaceService")

-- General Information about the Place
Settings.placeId = game.PlaceId
Settings.placeName = MarketplaceService:GetProductInfo(Settings.placeId).Name
Settings.placeIcon = "https://cdn.discordapp.com/attachments/520353404875440141/1196024578447777822/Png.png?ex=65b61fb0&is=65a3aab0&hm=870f54f01549706b2b0210a949550d634d1e9feadaac2e1f4955bb033d98196b&"
Settings.placeThumbnail = "https://cdn.discordapp.com/attachments/520353404875440141/1195606490568990820/Png.png?ex=65b49a50&is=65a22550&hm=2eff82cf4f6596fa9016434e331b78125daf436b29bb85e0281483600a712f19&"
Settings.placeURL = "https://www.roblox.com/games/15850259220/FZ-Athens-Ruins-II"

-- Group Information
Settings.groupId = 33643398
Settings.groupDecal = "https://cdn.discordapp.com/attachments/737258427960524870/762005186335735848/8431cba368c22545180e9ecdb65c062e.png"
Settings.groupName = "Athenist"

-- Announcer Customization
Settings.Announcer = {
	Name = "SYSTEM",
	Color = Color3.fromRGB(232, 186, 200),
	Font = Enum.Font.SourceSans,
}

-- Base prefloodable
Settings.Prefloodable = true

-- Minimum Players for Preflood Webhook
Settings.minimumPlayers = 6

-- Webhook URLs
Settings.webhooks = {
	preflood = "https://discord.com/api/webhooks/1192272156172750950/voicrB1OSVmBMhQ7lNb4gewBsS5BoPJn9c4nYh9Xh77e0URl-ocVeWkNvfM8pBdKdUfk",
	attendancelogger = "https://discord.com/api/webhooks/1194420542908940329/hknaUKOCAi1ErLn97Ktx0CCf8z5EAO1rvHOltHANsNb9U658XutVzYOQvgxGFabHEvWM",
}

-- Webhook Color
Settings.webhookColor = 16741850

-- Custom ChatTags
Settings.ChatTags = {
	[88746825] = { -- UserID e.g. labi
		ChatColor = Color3.fromRGB(255, 170, 255), -- Chat Color
		Tags = {
			{
				TagText = "labii", -- Tag Text
				TagColor = Color3.fromRGB(255, 85, 255), -- Tag Color
			}
		}
	},
	[34503948] = { -- rihannza
		ChatColor = Color3.fromRGB(249, 226, 255),
		Tags = {
			{
				TagText = "riri",
				TagColor = Color3.fromRGB(255, 197, 249),
			}
		}
	},
	[678008720] = { -- gabbie
		ChatColor = Color3.fromRGB(255, 89, 211),
		Tags = {
			{
				TagText = "gabbie",
				TagColor = Color3.fromRGB(255,0,127),
			}
		}
	},
	[44391513] = { -- nathan
		ChatColor = Color3.fromRGB(255,0,0),
		Tags = {
			{
				TagText = "DEV",
				TagColor = Color3.fromRGB(255,0,127),
			}
		}
	},
	[261702036] = { -- ellie
		ChatColor = Color3.fromRGB(255,0,0),
		Tags = {
			{
				TagText = "ellie",
				Color3.fromRGB(255,0,127),
			}
		}
	},
}

return Settings