--!native
--!optimize 2

--[[
	@Dev_Bas
	ProcessReceipt v1.0.0:
	A module serve MarketplaceService.ProcessReceipt callback simulate centralized.
	To fix the problem where sometimes have another system integration to MarketplaceService.ProcessReceipt collision.
	Which by default roblox offer you only can use one callback, for all in game monetization from devproduct.
]]--

local ProcessReceipt = {}

ProcessReceipt._Processes = {}

export type ReceiptInfo = {
	CurrencySpent: number,
	CurrencyType: typeof(Enum.CurrencyType),
	PlaceIdWherePurchased: number,
	PlayerId: number,
	ProductId: number,
	PurchaseId: string,
}

function ToValues <T, K, V> (tbl: T & {[K]: V}): T & {V}
	local Values = {}
	for _, V in pairs(tbl) do
		table.insert(Values, V)
	end
	return Values
end

function ProcessReceiptEndpoint(ReceiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision?
	local PriorityList = ToValues(ProcessReceipt._Processes)
	--@Descending // Highest to Lowest
	table.sort(PriorityList, function(v1, v2) return v1.Priority > v2.Priority end)
	for _, ProcessReceiptObject in ipairs(PriorityList) do
		local Callback = ProcessReceiptObject.Callback
		if (type(Callback) == "function") then
			local IsPurchaseGranted = Callback(ReceiptInfo)
			if (IsPurchaseGranted == Enum.ProductPurchaseDecision.PurchaseGranted) then
				return IsPurchaseGranted
			end
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local ProcessReceiptObject = {}
ProcessReceiptObject.__index = ProcessReceiptObject

type ProcessReceiptObject = typeof(ProcessReceiptObject)

--[[
	A method for cleanup ProcessReceiptObject.
	<em>Also get auto-cleanup object like
		- Maid
		- Janitor
		- Trove</em>
]]--
function ProcessReceiptObject:Destroy()
	if (type(self.Callback) == "function") then
		ProcessReceipt._Processes[self.Callback] = nil	
		self.Callback = nil	
	end
	setmetatable(self, nil)
	table.clear(self)
end

--[[
	A method for cleanup ProcessReceiptObject.
	<em>Also get auto-cleanup object like
		- Maid
		- Janitor
		- Trove</em>
]]--
function ProcessReceiptObject:Disconnect()
	self:Destroy()
end

--[[
	A callback process receipts of developer product purchases.
	With use of <strong>@Priority</strong> that be able to set simulate multiple callback.
	
	<strong>- Parameters -</strong>
	<strong>@Priority</strong>: number <em>--Descending // Highest to Lowest</em>
	<strong>@Callback</strong>: (<strong>@ReceiptInfo</strong>: ReceiptInfo) -> (Enum.ProductPurchaseDecision?) <em></em>
]]--
function ProcessReceipt.Register(Priority: number, Callback: (ReceiptInfo: ReceiptInfo) -> Enum.ProductPurchaseDecision?): ProcessReceiptObject?
	if (type(Callback) == "function") then
		local ProcessReceiptObject = setmetatable({
			Priority = Priority,
			Callback = Callback,
		}, ProcessReceiptObject)
		ProcessReceipt._Processes[Callback] = ProcessReceiptObject
		return ProcessReceiptObject
	end
	return nil
end

--[[
	A method for cleanup all ProcessReceiptObject.
]]--
function ProcessReceipt.DisconnectAll()
	table.clear(ProcessReceipt._Processes)
end

-- @OneEndpoint
if game:GetService("RunService"):IsServer() then
	game.MarketplaceService.ProcessReceipt = ProcessReceiptEndpoint
end

return ProcessReceipt