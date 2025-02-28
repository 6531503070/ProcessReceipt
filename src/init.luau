--[[
	@Dev_Bas
	ProcessReceipt v1.0.0:
	A typed roblox module for MarketplaceService.ProcessReceipt provided callback simulate centralized
]]

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local ProcessReceipt = {}
ProcessReceipt._Processes = {}

export type ReceiptInfo = {
	CurrencySpent: number,
	CurrencyType: typeof(Enum.CurrencyType),
	PlaceIdWherePurchased: number,
	PlayerId: number,
	ProductId: number,
	PurchaseId: string,
	ProductPurchaseChannel: typeof(Enum.ProductPurchaseChannel),
}

local function toValues <T, K, V> (tbl: T & {[K]: V}): T & {V}
	local values = {}
	
	for _, V in pairs(tbl) do
		table.insert(values, V)
	end
	
	return values
end

function ProcessReceiptEndpoint(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision?
	local priorityList = toValues(ProcessReceipt._Processes)
	
	--@Descending // Highest to Lowest
	table.sort(priorityList, function(v1, v2) return v1.Priority > v2.Priority end)
	
	for _, processReceiptObject in ipairs(priorityList) do
		local callback = processReceiptObject.Callback
		
		if type(callback) == "function" then
			local isPurchaseGranted = callback(receiptInfo)
			
			if isPurchaseGranted == Enum.ProductPurchaseDecision.PurchaseGranted then
				return isPurchaseGranted
			end
		end
	end
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local ProcessReceiptObject = {}
ProcessReceiptObject.__index = ProcessReceiptObject

type ProcessReceiptObject = typeof(ProcessReceiptObject)

--[=[
	A method for cleanup ProcessReceiptObject.
	<em>Also get auto-cleanup object like
		- Maid
		- Janitor
		- Trove</em>
]=]
function ProcessReceiptObject:Destroy()
	if type(self.Priority) == "function" then
		ProcessReceipt._Processes[self.Priority] = nil	
		self.Priority = nil	
	end
	
	setmetatable(self, nil)
	table.clear(self)
end

--[=[
	A method for cleanup ProcessReceiptObject.
	<em>Also get auto-cleanup object like
		- Maid
		- Janitor
		- Trove</em>
]=]
function ProcessReceiptObject:Disconnect()
	self:Destroy()
end

--[=[
	A callback process receipts of developer product purchases.
	With use of <strong>@Priority</strong> that be able to set simulate multiple callback.
	
	<strong>- Parameters -</strong>
	<strong>@Priority</strong>: number <em>--Descending // Highest to Lowest</em>
	<strong>@Callback</strong>: (<strong>@ReceiptInfo</strong>: ReceiptInfo) -> (Enum.ProductPurchaseDecision?) <em></em>
]=]
function ProcessReceipt.Register(priority: number, callback: (receiptInfo: ReceiptInfo) -> Enum.ProductPurchaseDecision?): ProcessReceiptObject?
	if type(callback) == "function" then
		if type(ProcessReceipt._Processes[priority]) == "table" then
			warn(`[`, script, `]: Priority value = {priority} existed. Try for another value.`)
		else
			local ProcessReceiptObject = setmetatable({
				Priority = priority,
				Callback = callback,
			}, ProcessReceiptObject)
			
			ProcessReceipt._Processes[priority] = ProcessReceiptObject
			
			return ProcessReceiptObject
		end
	end
	return nil
end

--[=[
	A method for cleanup all ProcessReceiptObject.
]=]
function ProcessReceipt.DisconnectAll()
	table.clear(ProcessReceipt._Processes)
end

-- @OneEndpoint
if RunService:IsServer() then
	MarketplaceService.ProcessReceipt = ProcessReceiptEndpoint
end

return ProcessReceipt