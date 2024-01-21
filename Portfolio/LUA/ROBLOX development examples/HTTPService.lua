local HTTPServiceModule = {}
local HTTPService = game:GetService("HttpService")
local gsProxyUrl = "https://script.google.com/macros/s/AKfycbz2JaprZNy4y3zx6WAZ7qxutPsdcgpZfV4wMHLU-bfM89EL1Nuff5J4JFYV3S7WtARLqw/exec"
function HTTPServiceModule.SendWebhook(embeddedMessage, discordWebhookUrl)

	local payload = {
		embeddedMessage = embeddedMessage,
		discordWebhookUrl = discordWebhookUrl
	}

	local success, result = pcall(function()
		local jsonData = HTTPService:JSONEncode(payload)
		return HTTPService:PostAsync(gsProxyUrl, jsonData, Enum.HttpContentType.ApplicationJson, false)
	end)

	if success then
		print("Webhook sent successfully.")
	else
		warn("Failed to send webhook to Google Apps Script: " .. tostring(result))
	end
end

return HTTPServiceModule