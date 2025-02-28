# ProcessReceipt

A type roblox module for MarketplaceService.ProcessReceipt provided callback simulate centralized.

To fix the problem where sometimes have another system integration to MarketplaceService.ProcessReceipt collision.
Which by default roblox offer you only can use one callback, for all in game monetization from devproduct.

# Exmaple
```lua
local ProcessReceipt = require(script.ProcessReceipt)

-- Script1
local GameProcessReceiptObject = ProcessReceipt.Register(1337, function(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision? 
	-- GameLogic DevProduct Management
	-- ...
end)

-- Script2
local DonationProcessReceiptObject = ProcessReceipt.Register(-math.huge, function(receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision? 
	-- Donation DevProduct Management
	-- ...
end)
```
